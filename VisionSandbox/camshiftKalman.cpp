/****
* TJ Wilkason 2009 science fair project to track video objects
* Goal: Track video objects as the move through occlusions
*/
#include "camshift.h"
#include "clsKalman.h"
#include "tmplDetector.h"
IplImage *imgProcess = 0, 
  *imgHSV = 0, *imgHSVPlanes[3], *imgCurrentMask=0,*lbpImage=0, 
  *imgTargetMask = 0, *imgBackProjection = 0, *imgHistRaw=0,*imgLBPTarget=0,
  *imgLBPBG=0, *imgHistTarget = 0,*imgHistBG=0, *imgContour=0, *lbpGray=0;
CvHistogram *histTarget = 0,*histTargetOrig = 0, *histBG=0, *histCandidate = 0, *histBGtemp=0;
// Program Settings
int defFlip= 0;
int defCapture=0;
int defOcclusion=0;                              // 0 = None, 1 = Wood Track, 2 = Cement Track
int defTrackBoxMin = 10;
int defUseKalman=1;
int defUseTemplate=1;
int defLogfile=0;
int defDebugGraphics=1;
double defMinArea=2000.0;                        // Any smaller boxTrack data is invalid
double winFactor =2.0;
double fps=30.0;
double GF = 1.0;                                // Increase search window size
double defMinAreaFactor = 0.5;
TrackType TrackMode = NOTRACK;
// Mode Settings
int modeBackProjection = 0;
int modeSelectObject = 0;
int modeShowHistogram = 1;
// Histogram
#define MAXHUE 180
#define LBPBINS 36
#define LBPSIZE 36  //max possible values of LBP
#define LBPOS 5     //default offset for LBP operation (4/5 works for lbp36)
int histSize[] = {32, 16, LBPBINS};
float hranges_arr[] = {0,MAXHUE};
float sranges_arr[] = {0,255};
float vranges_arr[] = {0,LBPSIZE-1};
#if DEPTH == 1
float* hranges[] = {hranges_arr};
#elif DEPTH ==2
float* hranges[] = {hranges_arr, sranges_arr};
#else
float* hranges[] = {hranges_arr, sranges_arr, vranges_arr};
#endif


int adjVmin = 10, adjVmax = 256, adjSmin = 100, adjSmax=MAXHUE;
CvFont font;
CvScalar fontColor = CV_RGB(0,0,0);
CvPoint ptOrigin;
CvRect rectSel;
CvRect rectCamSW;
CvBox2D boxTrack;
CvConnectedComp compTrack;
//
// Automatically adjust the limits for the Sat/Lum
//
void adjustLimits(IplImage *imgHSV);
void initHistogram(CvHistogram *histT, CvHistogram *histB,IplImage **imgHSVPlanes, IplImage *imgTM,CvRect useRectSel,double threshold);
void on_mouse( int event, int x, int y, int flags, void* param );
void radialGradient(IplImage *image);
float framesPerSecond(CvCapture *capture);


float timeNow=0;
int waitMS=0;
int main( int argc, char** argv )
{
   results myResults;
   myResults.camCycles=0;
   myResults.totFrames=0;
   myResults.cumKalamError=0.0;
   myResults.Occluded=0;
   cvInitFont(&font,CV_FONT_VECTOR0, 0.6, 0.6, 0.0, 2);
   CvCapture* capture = 0;
   double skMeasurementNoise =30.0 /2.0;
   double acqThreshold = -0.25;
   char imgText[255];
   int wait=20;
   double histCorr=0;   // histogram correlation
   CvScalar avgHSV, stdHSV;
   int useOffset=0;
   /****
   Parameters:
   1 Input File
   2 Log File
   3 Process Noise
   4 Measurement Noise
   5 wait period, < 0 = none
   6 nthFrame (frame skipping)
   ******/
   if ( argc == 1 || (argc >= 2 && strlen(argv[1]) == 1 && isdigit(argv[1][0])) )
   {
      capture = cvCaptureFromCAM( argc == 2 ? argv[1][0] - '0' : 0 );
      if ( capture )
      {
         defFlip = 1;
         wait=1;
         fps = framesPerSecond(capture);
      }
   }
   else if ( argc >= 2 )
   {
      fprintf(stdout,"Input File: %s\n",argv[1]);
      capture = cvCaptureFromAVI( argv[1] );
      fps =cvGetCaptureProperty(capture,CV_CAP_PROP_FPS);
      fprintf(stdout,"Frame rate=%f fps\n",fps);
   }
   // fdLog file
   char logFile[255]; 
   sprintf(logFile, "%s", "");
   if ( argc > 2 )
   {
      if ( strlen(argv[2]) > 0 )
      {
         defLogfile=1;                           // 0 = None, 1 =yes
         sprintf(logFile, "%s", argv[2]);
      }
   }

   double noiseProcess = 8.0;
   if ( argc > 3 )
      noiseProcess=atof(argv[3]);

   double noiseMeas = 3.0;
   if ( argc > 4 )
      noiseMeas=atof(argv[4]);
   if ( noiseMeas < 0 || noiseMeas > 100 )
      noiseMeas=3.0;

   if ( argc > 5 )
      wait=atoi(argv[5]);

   //  frames to skip
   unsigned int nthFrame=1;
   if ( argc > 6 )
      nthFrame=atoi(argv[6]);
   fps /=(double)nthFrame;

   // Enable occlusion
   if ( argc > 7 )
      defOcclusion=atoi(argv[7]);                // 0 = None, 1 = Wood Track, 2 = Cement Track
   // Video capture file name
   char* AVIFilename_Char = new char[255];
   sprintf(AVIFilename_Char, "%s", "vidCapture.avi");
   if ( argc > 8 )
   {
      if ( strlen(argv[8]) > 0 )
      {
         defCapture=1;                           // 0 = None, 1 =yes
         sprintf(AVIFilename_Char, "%s", argv[8]);
      }
   }
   // Use non-Kalman data if either 0
   if ( noiseMeas <= 0.0 )
      defUseKalman = 0;
   else if ( noiseProcess <= 0.0 )
   {
      defFlip = 0;                               // Denote live video or less checks for occlusion
      noiseProcess = -noiseProcess;
   }
   if ( noiseProcess < 0 || noiseProcess > 100 )
      noiseProcess=8.0;

   // If live video then relax the occlusion detection parameters
   if ( defFlip )
   {
      skMeasurementNoise/=5.0;
      GF*=1.2;
      acqThreshold*=4.0;
      defMinAreaFactor=0.1;
      defDebugGraphics=0;
   }

   /***** Kalman Stuff ****/
   // Kalman Add
   CvBox2D boxPred;
   // Fast Tracker
   clsKalman posKal(MD);
   // Slow (area) Tracker
   clsKalman areaKal(MD);
   // Slow tracker
   clsKalman slowKal(MD);
   // Slow size tracker
   clsKalman slowSizeKal(MD);
   OccludedType Occluded=NO;
   double trackAngle=0;
   double ACQ=0.0, A2CQ=0.0;
   CvScalar track_color;
   // Kalman End
   CvVideoWriter *AVIWriter=0;
   IplImage *imgOcclusion=0; 
   cvWaitKey(1);

   if ( wait >= 0 )
   {
      printf( "Hot keys: \n"
              "\tESC - quit the program\n"
              "\tc - stop the tracking\n"
              "\tb - switch to/from backprojection view\n"
              "\th - show/hide object histogram\n"
              "\td - show/hide Debug Graphics\n"
              "\ts - Toggle Single Step Mode\n"
              "\tw - Write current frame to file with Frame Number\n"
              "To initialize tracking, select the object with mouse\n" );

      //cvNamedWindow( "Debug", 1 );
      cvNamedWindow( "Mask", 1 );
      cvNamedWindow( "CamShiftWindow", 1 );
      cvSetMouseCallback( "CamShiftWindow", on_mouse, 0 );
      if ( modeShowHistogram )
      {
         cvNamedWindow( "Target Histogram", 1 );
         cvNamedWindow( "Background Histogram", 1 );
         cvNamedWindow( "Target LBP Histogram", 1 );
         cvNamedWindow( "Background LBP Histogram", 1 );
      }

      //cvCreateTrackbar( "Vmin", "CamShiftWindow", &adjVmin, 256, 0 );
      //cvCreateTrackbar( "Vmax", "CamShiftWindow", &adjVmax, 256, 0 );
      //cvCreateTrackbar( "Smin", "CamShiftWindow", &adjSmin, 256, 0 );
      //cvCreateTrackbar( "Smax", "CamShiftWindow", &adjSmax, 256, 0 );
   }
   detector d;
   // Load the database of images in subfolder Template
   d.loadDataBasePath("Template");
   CvRect rectRes;
   unsigned long ofc=0, tfc=0;
   unsigned long fc=0;


   //**************** E N D  A R G U M E N T S ***************************
   IplImage *OccMask=0;
   if ( !capture )
   {
      fprintf(stderr,"Could not initialize capturing...%d\n",argc);
      return -1;
   }
   if ( defOcclusion )
   {
      if ( defOcclusion == 1 )                   // wood top
      {
         imgOcclusion = cvLoadImage("WoodTop.png",1);
      }
      else if ( defOcclusion == 2 )              // Cement Top
      {
         imgOcclusion = cvLoadImage("CementTop.png",1);
      }
      else if ( defOcclusion == 3 )              // wood side
      {
         imgOcclusion = cvLoadImage("WoodSide.png",1);
      }
      // Check if sucessful
      if ( ! imgOcclusion )
      {
         fprintf(stderr,"Could not initialize capturing...\n");
         defOcclusion = 0;
      }
      else
      {
         OccMask = cvCreateImage( cvGetSize(imgOcclusion), 8, 1 );
         cvCvtColor(imgOcclusion, OccMask, CV_RGB2GRAY);
      }
   }
   // Log File (if running in logger mode)
   FILE* fdLog = 0;
   if ( defLogfile )
   {
      fdLog=fopen(logFile,"w");
      if ( fdLog )
      {
         fprintf(fdLog,"Input=%s, Process Noise=%f, Measurement Noise=%f\n",
                 argv[1], noiseProcess, noiseMeas);
         fprintf(fdLog,"Ticks\tCycles\tOccluded\tKFx\tKFy\tAx\tAy\tAw\tAh\tKSx\tKSy\tArea\tKAreaV\tKArea\tFVx\tFVy\tSVx\tSVy\ttbAngle\n");
      }
      else
         fprintf(stderr,"Could not open log file for writing\n");
   }
   // ********************** TOP OF LOOP *******************************
   for ( ;; )
   {
      IplImage* imgFrame = 0;
      int c;
      int64 startTime = cvGetTickCount();
      ofc++;
      imgFrame = cvQueryFrame( capture );
      if ( ofc % nthFrame!=0 && ofc > nthFrame )
         continue;
      if ( imgFrame==NULL )
         break;
      tfc++;
      if ( imgProcess==NULL )
      {
         /* allocate all the buffers */
         if ( defCapture )
         {
            AVIWriter = cvCreateAVIWriter(AVIFilename_Char, CV_FOURCC('D','I','V','X'), fps, cvGetSize(imgFrame));
         }

         imgProcess = cvCreateImage( cvGetSize(imgFrame), 8, 3 );
         imgProcess->origin = imgFrame->origin;
         imgHSV = cvCreateImage( cvGetSize(imgFrame), 8, 3 );
         imgHSVPlanes[0] = cvCreateImage( cvGetSize(imgFrame), 8, 1 );
         imgHSVPlanes[1] = cvCreateImage( cvGetSize(imgFrame), 8, 1 );
         imgHSVPlanes[2] = cvCreateImage( cvGetSize(imgFrame), 8, 1 );
         lbpImage = cvCreateImage( cvGetSize(imgFrame), 8, 1 );
         lbpGray = cvCreateImage( cvGetSize(imgFrame), 8, 1 );
         cvZero(lbpImage);
         //imgCurrentMask = cvCreateImage( cvGetSize(imgFrame), 8, 1 );
         imgTargetMask = cvCreateImage( cvGetSize(imgFrame), 8, 1 );

         imgBackProjection = cvCreateImage( cvGetSize(imgFrame), 8, 1 );
         cvZero(imgBackProjection);

         histTarget = cvCreateHist( DEPTH, histSize, CV_HIST_ARRAY, hranges, 1 );
         histTargetOrig = cvCreateHist( DEPTH, histSize, CV_HIST_ARRAY, hranges, 1 );
         histBG = cvCreateHist( DEPTH, histSize, CV_HIST_ARRAY, hranges, 1 );
         histCandidate = cvCreateHist( DEPTH, histSize, CV_HIST_ARRAY, hranges, 1 );
         histBGtemp = cvCreateHist( DEPTH, histSize, CV_HIST_ARRAY, hranges, 1 );

         imgHistTarget = cvCreateImage( cvSize(320,200), 8, 3 );
         imgHistBG = cvCreateImage( cvSize(320,200), 8, 3 );
         imgLBPTarget = cvCreateImage( cvSize(320,200), 8, 3 );
         imgLBPBG = cvCreateImage( cvSize(320,200), 8, 3 );
         //imgHistRaw = cvCreateImage( cvSize(320,200), 8, 3 );
         //cvZero( imgHistRaw );
         cvZero( imgHistTarget );
         cvZero( imgHistBG );

      }
      if ( defFlip )
      {
         cvFlip( imgFrame, imgProcess, 1 );      // copies and flips LR like a mirror
      }
      else
      {
         cvCopy( imgFrame, imgProcess, 0 );
      }

      if ( defUseTemplate && tfc < 3 )
      {
         // Locate initial position
         double peakVal=d.compareToDatabase(imgProcess,&rectRes);
         if ( peakVal > 0.90 )
         {
            fprintf(stdout,"Peak= %f, X=%d, Y=%d W=%d H=%d\n",peakVal,rectRes.x,rectRes.y, rectRes.width,rectRes.height);
            cvRectangle( imgProcess , 
                         cvPoint(rectRes.x, rectRes.y),
                         cvPoint(rectRes.x + rectRes.width, rectRes.y + rectRes.height) , 
                         CV_RGB(255,0,0), 1, 8, 0 ); 
            // Init data, enable tracking just like if the mouse did it
            rectSel=  rectRes;

            // Simulator mouse being unclicked after rectSel
            TrackMode=INITIALTRACK;
            defUseTemplate=0;
         }
      }
      // Create imgHSV for use by back propagation
      if ( defOcclusion )
      {
         cvCopy(imgOcclusion, imgProcess, OccMask);
      }
#if 0
      // Low pass filter search window to help camshift reacquire
      if ( TrackMode == FULLTRACK && Occluded != NO )
      {
         cvSetImageROI( imgProcess, rectCamSW );
         cvSmooth(imgProcess, imgProcess, CV_BLUR, 5, 5, 1, 1 );
         //cvSmooth(imgProcess, imgProcess, CV_MEDIAN, 3, 3, 1, 1 );
         cvResetImageROI( imgProcess );
      }
#endif
      if ( TrackMode==INITIALTRACK || TrackMode==FULLTRACK )
      {
         fc++;
         // Process Hue and image mask
         cvCvtColor( imgProcess, imgHSV, CV_BGR2HSV );

         //cvCvtColor( imgProcess, imgHSV, CV_BGR2YCrCb );
         // After mouse selects the region compute and draw the histogram
         if ( TrackMode==INITIALTRACK )
         {
            fc=0;
            defMinArea=2000;
            // Auto compute slider values
            cvSetImageROI( imgHSV, rectSel );
            adjustLimits(imgHSV);
            cvResetImageROI( imgHSV );
            // Reprocess HSV and mask with new limits
            imgToHue(imgHSV, imgTargetMask, imgHSVPlanes);
            cvAvgSdv(imgHSVPlanes[2],&avgHSV,&stdHSV);

            fprintf(stdout,"Avg=%f, StdDev=%f\n",avgHSV.val[0],stdHSV.val[0]);
            // 1/12 of stddev for the offset
            useOffset = (int)(stdHSV.val[0] / 12.0);
            //useOffset=LBPOS;
            LBP8(imgHSVPlanes[2], lbpImage,LBPSIZE,useOffset);
            cvCopy(lbpImage,imgHSVPlanes[2]);

            initHistogram(histTarget, histBG, imgHSVPlanes,imgTargetMask,rectSel,0.05);

            // Save a references
            cvCopyHist(histTarget,&histTargetOrig);
            // Draw the histogram
            showHistogram (histBG, imgHistBG);
            showHistogram (histTarget, imgHistTarget);
            // Show the target mask
            cvSetImageROI( imgTargetMask, rectSel );
            cvShowImage( "Mask", imgTargetMask);
            cvResetImageROI( imgTargetMask );


            rectCamSW = rectSel;

            posKal.init(
                       rectSel.x+rectSel.width/2,
                       rectSel.y+rectSel.height/2,
                       fps,                      // del t, 
                       noiseProcess,             // process noise (pixels), higher the more reactive the filter is
                       noiseMeas                 // measurement noise (pixels), higher the slower the filter is, lower the more the measurement is trusted
                       );

            areaKal.init(
                        rectSel.width*rectSel.height*150,
                        rectSel.width*rectSel.height,   // don't use this
                        fps,                     // del t
                        5,                       // process noise (pixels) 2
                        2                        // measurement noise (pixels) 2
                        );
            //acqThreshold = -.20;
            // Non-maneuver, don't slow down velocity
            slowKal.init(
                        rectSel.x+rectSel.width/2,
                        rectSel.y+rectSel.height/2,
                        fps,                     // del t 
                        noiseProcess,            // process noise (pixels) 8
                        skMeasurementNoise       // measurement noise (due to occlusion)
                        );
            // Non-maneuver, don't slow down search window width/height
            slowSizeKal.init(
                            rectSel.width,
                            rectSel.height,
                            fps,                 // del t 
                            noiseProcess,        // process noise (pixels) 8
                            skMeasurementNoise   // measurement noise (due to occlusion)
                            );
            // Indicated tracking for later
            TrackMode = FULLTRACK;
            // 20/ 1.3
         }
         // Image to view and write graphics onto
         if ( modeBackProjection )
         {
            cvCvtColor( imgBackProjection, imgProcess, CV_GRAY2BGR );
         }
         if ( TrackMode == FULLTRACK )
         {
            // Compute the back projection based on histogram
            // This maps the imgProcess values to the histogram lookup values
            // and puts the result in the imgBackProjection imgProcess
            // This makes it much easier for the camshift to center over the target mass
/************************ B A C K  P R O J E C T I O N **************************/
            imgToHue(imgHSV,imgTargetMask,imgHSVPlanes);
            // Convert gray scale plan into LBP image and use for back projection
            LBP8(imgHSVPlanes[2], lbpImage,LBPSIZE,useOffset);
            cvCopy(lbpImage,imgHSVPlanes[2]);
//cvEqualizeHist( lbpImage, lbpImage );
//cvShowImage( "Debug", lbpImage);
//VAR8(imgHSVPlanes[1], lbpImage);
//cvCopy(lbpImage,imgHSVPlanes[1]);
           cvCalcBackProject( imgHSVPlanes, imgBackProjection, histTarget );
            //cvShowImage( "Debug", imgBackProjection );
#if LIMIT == 1
            // Mask out undesired S/V values
            cvAnd( imgBackProjection, imgTargetMask, imgBackProjection, 0 );
#endif
/************************ C A M  S H I F T **************************/
            // CAMShift Function
            int turns=cvCamShift (
                                 imgBackProjection, 
                                 rectCamSW,      // x,y,width,height, cvrect, window to search over
                                 cvTermCriteria( CV_TERMCRIT_EPS | CV_TERMCRIT_ITER, 20, 1 ),   //criteria
                                 &compTrack,     // x,y, width, height
                                 &boxTrack       // cvbox2d newly resized box, criteria for next imgFrame (as updated by tracker), center, size and angle
                                 ); 
            // If origon not at upper left adjust track box angle
            if ( !imgProcess->origin )
               boxTrack.angle = -boxTrack.angle;
/************************  C H E C K   O C C L U S I O N  **************************/
            //isOccluded(boxTrack);
            if ( compTrack.area < defMinArea || ACQ < acqThreshold )
            {
               if ( Occluded == NO )
               {
                  Occluded = INITIAL;
                  //setKalmanMeasCovariance(posKalman,30.0);
               }
               else if ( Occluded == INITIAL )
               {
                  Occluded = YES;
               }
               myResults.Occluded++;
               defMinArea*=.98;
           }
            else
            {
               if ( Occluded != NO )
               {
                  // Just reacquired the target, reset the fast kalman
                  // todo, can we set the velocity as well?
                  posKal.init (
                              boxTrack.center.x,
                              boxTrack.center.y,
                              fps,               // del t, 
                              noiseProcess,      // process noise (pixels), higher the more reactive the filter is
                              noiseMeas          // measurement noise (pixels), higher the slower the filter is, lower the more the measurement is trusted
                              );
               }
               else                              // still not occluded
               {
                  //double ctArea=compTrack.rect.height*compTrack.rect.width;
                  defMinArea = compTrack.area*defMinAreaFactor;
                  initHistogram(histCandidate, histBG,
                                imgHSVPlanes, imgTargetMask, compTrack.rect, 0.05);

                  histCorr=cvCompareHist(histCandidate,histTarget,CV_COMP_BHATTACHARYYA);
                  // Blend in updated target histogram
                  if (histCorr < 0.5)
                  {
                     blendHistogram(histTargetOrig, histTarget,histCandidate, .95);
                     showHistogram (histTarget, imgHistTarget);
                     showHistogram (histBG, imgHistBG);
                     show1DHistogram(histTarget,imgLBPTarget);
                     show1DHistogram(histBG,imgLBPBG);
                  }
               }
               Occluded = NO;
            }
            // 1) fast kalman accuracy imgFrame to imgFrame, adjust fast kalman for different tests cases
            //     include cum cycles to converge and cum error
            // 2) slow kalman accuracy when under the occlusion. 
            //  Can take a run with and without occlusions and plot accuracy
            // 3) graph how the occlusions are detected based on the area rate of change 
            if ( fdLog )
            {
               fprintf(fdLog,"%u\t%u\t%u\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n"
                       ,tfc
                       ,turns
                       ,Occluded
                       ,posKal.KD.x
                       ,posKal.KD.y
                       ,boxTrack.center.x
                       ,boxTrack.center.y
                       ,boxTrack.size.width
                       ,boxTrack.size.height
                       ,slowKal.KD.x
                       ,slowKal.KD.y
                       ,compTrack.area
                       ,areaKal.KD.vX
                       ,areaKal.KD.x
                       ,posKal.KD.vX
                       ,posKal.KD.vY
                       ,slowKal.KD.vX
                       ,slowKal.KD.vY
                      );
            }
            // Cum results for logging
            if ( tfc > 5 )
            {
               myResults.totFrames++;
               myResults.cumKalamError += rms(boxTrack.center.x-posKal.KD.x, boxTrack.center.y-posKal.KD.y);
               myResults.camCycles += turns;

            }
/************************ K A L M A N  U P D A T E **************************/
            if ( Occluded==NO )
            {
               // Good track, update with actual measurements
               // TODO, can crash here if initial selection is tiny, need to troubleshoot
               posKal.updateXY(boxTrack.center.x,boxTrack.center.y);
               areaKal.updateXY(compTrack.area,compTrack.rect.height*compTrack.rect.width);
               slowKal.updateXY(boxTrack.center.x,boxTrack.center.y);
               slowSizeKal.updateXY(compTrack.rect.width,compTrack.rect.height);
               track_color = CV_RGB(0,255,0);
            }
            else
            {
               // If Camshift is lost, no area returned (lost track)
               // Free run estimators using prior tracker data
               posKal.freeRun();
               slowKal.freeRun();
               slowSizeKal.freeRun();
               areaKal.updateXY(compTrack.area, compTrack.rect.height*compTrack.rect.width);
               track_color = CV_RGB(255,0,0);
            }

            // Update estimators
            posKal.correct();
            areaKal.correct();
            slowKal.correct();
            slowSizeKal.correct();
/************************ K A L M A N  P R E D I C T **************************/
            // Predict (for next cycle)
            posKal.predict();
            areaKal.predict();
            slowKal.predict();
            slowSizeKal.predict();

/************************ T E X T  D I S P L A Y **************************/
            if ( compTrack.area > 0 )            // Area rate of change was X
            {
               ACQ =areaKal.KD.vX/abs(areaKal.KD.x);
               A2CQ=areaKal.KD.vY/abs(areaKal.KD.y);
            }
            else
            {
               ACQ=0;
               A2CQ=0;
            }
            sprintf(imgText,"Frame: %d, Conv:%2d, Ang:%+06.1f Vel:%4.1f ACQ:%+05.1f%% BH:%3.2f"
                    , tfc
                    , turns
                    , trackAngle
                    , posKal.KD.vel
                    , ACQ*100.0
                    , histCorr
                   );
            drawText(imgProcess,imgText,20,&font,fontColor);
            // Slow filter graphics
            if ( defDebugGraphics )
            {
               double lf=3.0;
               CvScalar sfColor = CV_RGB(255,255,0);
               plot_crosshairs(imgProcess,cvPoint(slowKal.KD.x,slowKal.KD.y),2,5,sfColor);
               cvArrow(imgProcess,               // conect with a line
                       cvPoint((int)slowKal.KD.x                  , (int)slowKal.KD.y),
                       cvPoint((int)(slowKal.KD.x+lf*slowKal.vX()), (int)(slowKal.KD.y+lf*slowKal.vY())),
                       sfColor,2,4
                      );
            }

/************************  H A N D L E   O C C L U S I O N  **************************/
            if ( Occluded==NO )
            {
              //compTrack.rect.width =  slowSizeKal.KD.x;
              //compTrack.rect.height =  slowSizeKal.KD.y;
               // Enlarge box by velocity in that direction
               boxPred.size.width = (float)max(compTrack.rect.width,defTrackBoxMin)*GF+abs(posKal.KD.vX); 
               boxPred.size.height = (float)max(compTrack.rect.height,defTrackBoxMin)*GF+abs(posKal.KD.vY);
               // Kalman for predictor box
               boxPred.center.x = (float)max(posKal.KD.x,0);   // slow or fast
               boxPred.center.y = (float)max(posKal.KD.y,0);
               // 
               // Velocity (pixels per update)
               // Sign is ptOrigin dependent, - for upper left
               if ( posKal.KD.vel >= 1.0 )
                  trackAngle = posKal.KD.velAngle * rad2deg;
               else
                  trackAngle=0;

               rectCamSW.x=xBOXm(boxPred);
               rectCamSW.y=yBOXm(boxPred);
               rectCamSW.width = (int)boxPred.size.width;
               rectCamSW.height = (int)boxPred.size.height;
               limitXY(&rectCamSW, imgProcess, defTrackBoxMin);

               cvArrow(imgProcess,               // conect with a line
                       cvPoint((int)boxTrack.center.x,                   (int)boxTrack.center.y),
                       cvPoint((int)(boxPred.center.x+posKal.KD.vX*3.0), (int)(boxPred.center.y+posKal.KD.vY*3.0)),
                       track_color,2,8
                      );
               if ( boxTrack.size.height > 0 && boxTrack.size.width > 0 )
               {
                  cvRotRect( imgProcess, boxTrack, track_color, 2, CV_AA);
               }
            }
            else                                 // Occluded
            {
/************************  A D J U S T  S E A R C H  W I N D O W  **************************/
               float maxWin = max(rectSel.width,rectSel.height);
               // todo: win size related to target size and velocity before occlusion
               float maxX=RoundUp(slowKal.KD.vX*winFactor);   // factor adjusts for decreasing speed
               float maxY=RoundUp(slowKal.KD.vY*winFactor);
               double gFactor=2.0;
               boxPred.center.x+=maxX/gFactor;
               boxPred.center.y+=maxY/gFactor;
               // Shift window in direction of tracking
               if ( Occluded == INITIAL )
               {
                  // Window is very small at this point, reset it to rectSel size
                  float xx=(boxPred.size.width-maxWin)/2.0;
                  float yy=(boxPred.size.height-maxWin)/2.0;
                  boxPred.size.width = maxWin;
                  boxPred.size.height = maxWin;
                  // Offset the center due to the initial new width
                  boxPred.center.x+=xx * -abs(maxX)/maxX;
                  boxPred.center.y+=yy * -abs(maxY)/maxY;
               }
               // Grow box by last velocity (+ 20%)
               boxPred.size.width  += abs(maxX)*1.2;
               boxPred.size.height += abs(maxY)*1.2;
               rectCamSW.width = (int)boxPred.size.width;
               rectCamSW.height = (int)boxPred.size.height;
               unsigned int pX = xBOXm(boxPred);
               unsigned int pY = yBOXm(boxPred);
               rectCamSW.x =pX; 
               rectCamSW.y =pY; 
               limitXY( &rectCamSW,imgProcess, defTrackBoxMin );
               if ( boxTrack.size.height > 0 && boxTrack.size.width > 0 )
               {
                  cvRotRect( imgProcess, boxTrack, CV_RGB(255,0,0), 2, CV_AA);
                  //cvEllipseBox( imgProcess, boxTrack, CV_RGB(255,0,0), 2, CV_AA, 0 );
               }
            }
            if ( defDebugGraphics )
            {
               cvRectangle( imgProcess ,         // posKalman posPred
                            cvPoint(xBOXm(boxPred),yBOXm(boxPred)),
                            cvPoint(xBOXp(boxPred),yBOXp(boxPred)), 
                            track_color, 1, 8, 0 ); 
            }
            // If not using Kalamn, just use the last track box
            if ( defUseKalman == 0 )
            {
               rectCamSW = compTrack.rect;
            }
         }                                       // TrackMode== ON
      }                                          // TrackMode== ON or INITIALTRACK
      // If selecting, reverse color of rectSel region
      if ( modeSelectObject && rectSel.width > 0 && rectSel.height > 0 )
      {

         cvRectangle( imgProcess , 
                      cvPoint(rectSel.x, rectSel.y),
                      cvPoint(rectSel.x + rectSel.width, rectSel.y + rectSel.height) , 
                      CV_RGB(0,0,255), 2, 8, 0 ); 
      }
      if ( defCapture && AVIWriter )
         cvWriteToAVI(AVIWriter, imgProcess);
      // 30ms ~ 33 fps (playback only, if not playback wait min time)
      if ( wait >= 0 )
      {
         cvShowImage( "CamShiftWindow", imgProcess );
         cvShowImage( "Target Histogram", imgHistTarget );
         cvShowImage( "Background Histogram", imgHistBG );
         cvShowImage( "Target LBP Histogram", imgLBPTarget );
         cvShowImage( "Background LBP Histogram", imgLBPBG );
         // Compute how long to wait based on frame rate
         int64 dTime = cvGetTickCount()-startTime;
         dTime=dTime/(1000*cvGetTickFrequency());   // time to process this frame
         dTime=min(max(1,1.0/fps*1000.-dTime),100);   // additional time to wait for proper frame rate
         if ( wait == 0 )
            dTime=wait;
         c = cvWaitKey(dTime);
         // Get any key pressed in the HighGUI windows and act accordingly.
         if ( (char) c == 27 )
            break;
         switch ( (char) c )
         {
            case 'b':
               modeBackProjection ^= 1;
               if ( modeBackProjection )
                  fontColor = CV_RGB(255,255,255);
               else
                  fontColor = CV_RGB(0,0,0);
               break;
            case 'd':
               defDebugGraphics ^= 1;
               break;
            case 'w':
               // write image to file
               writeFrame(tfc, imgProcess, "cap");
               cvEqualizeHist( lbpImage, lbpImage );
               writeFrame(tfc, lbpImage, "LBP");
               writeFrame(tfc, imgHSVPlanes[0], "Hue");
               writeFrame(tfc, imgHSVPlanes[1], "Sat");
               writeFrame(tfc, imgBackProjection, "BProj");
               break;
            case 'c':
               TrackMode = NOTRACK;
               cvZero( imgHistTarget );
               break;
            case 's':
               // Toggle single step
               if ( wait == 0 )
                  wait = 10;
               else
                  wait = 0;
               break;
            case 'g':
               if ( compTrack.area > 0 )
               {
                  // Auto compute slider values
                  cvSetImageROI( imgHSV, compTrack.rect );
                  adjustLimits(imgHSV);
                  cvResetImageROI( imgHSV );
                  // Reprocess HSV and mask with new limits
                  imgToHue(imgHSV, imgTargetMask, imgHSVPlanes);
                  LBP8(imgHSVPlanes[2], lbpImage, LBPSIZE,useOffset);
                  cvCopy(lbpImage,imgHSVPlanes[2]);
//VAR8(imgHSVPlanes[1], lbpImage);
//cvCopy(lbpImage,imgHSVPlanes[1]);

                  initHistogram(histTarget, histBG, imgHSVPlanes, imgTargetMask, compTrack.rect, 0.05);
                  cvCopyHist(histTarget, &histTargetOrig);
                  // Draw the histogram
                  //showHistogram (histTarget, imgHistTarget);
                  //showHistogram (histBG, imgHistBG);
                  //show1DHistogram(histTarget,imgLBPTarget);
                  //show1DHistogram(histBG,imgLBPBG);

               }
               break;
            case 'h':
               modeShowHistogram ^= 1;
               if ( !modeShowHistogram )
               {
                  cvDestroyWindow( "Target Histogram" );
                  cvDestroyWindow( "Background Histogram" );
                  cvDestroyWindow( "Target LBP Histogram" );
                  cvDestroyWindow( "Background LBP Histogram" );
               }
               else
               {
                  cvNamedWindow( "Target Histogram", 1 );
                  cvNamedWindow( "Background Histogram", 1 );
                  cvNamedWindow( "Target LBP Histogram", 1 );
                  cvNamedWindow( "Background LBP Histogram", 1 );
               }
               break;
            default:
               ;
         }
         // Debugging break points
         switch ( Occluded )
         {
            case INITIAL:
               Occluded=Occluded;
               break;
            case YES:
               Occluded=Occluded;
               break;
            case NO:
               Occluded=Occluded;
               break;
         }
      }
   }

   if ( defCapture && AVIWriter )
      cvReleaseVideoWriter(&AVIWriter);
   cvReleaseCapture( &capture );
   cvDestroyWindow("CamShiftWindow");
   cvDestroyWindow("Target Histogram");
   cvDestroyWindow("Target LBP Histogram");
   cvDestroyWindow("Background Histogram");

   if ( fdLog )
   {
      fprintf(fdLog,"\nFrames\t%d\tCum Cycles\t%d\tCum Kalman Error\t%f"
              ,myResults.totFrames
              ,myResults.camCycles
              ,myResults.cumKalamError
             );
      fclose(fdLog);
   }
   if ( wait < 0 )
   {
      // Spin open in case of collision
      FILE* fdSumLog=0;
      while ( fdSumLog == 0 )
         fdSumLog=fopen("summary.txt","a+");
      if ( fdSumLog )
      {
         fprintf(fdSumLog,"%s\t%f\t%f\t%d\t%d\t%d\t%f\t%d\n"
                 ,argv[1]
                 ,noiseProcess
                 ,noiseMeas
                 ,nthFrame
                 ,myResults.totFrames
                 ,myResults.camCycles
                 ,myResults.cumKalamError
                 ,myResults.Occluded
                );

         fclose(fdSumLog);
      }
   }
   fprintf(stdout,"\nFile: %s\t%f\t%f\t%d\tFrames\t%d\tCum Cycles\t%d\tCum Kalman Error\t%f\tOccluded\t%d"
           ,argv[1]
           ,noiseProcess
           ,noiseMeas
           ,nthFrame
           ,myResults.totFrames
           ,myResults.camCycles
           ,myResults.cumKalamError
           ,myResults.Occluded
          );
   return 0;
};



// Mouse callback to set rectSel manually
void on_mouse( int event, int x, int y, int flags, void* param )
{
   if ( !imgProcess )
      return;

   if ( imgProcess->origin )
      y = imgProcess->height - y;
   // mouse is down or just relased
   if ( modeSelectObject != 0 )
   {
      rectSel.x = MIN(x,ptOrigin.x);
      rectSel.y = MIN(y,ptOrigin.y);
      rectSel.width = rectSel.x + CV_IABS(x - ptOrigin.x);
      rectSel.height = rectSel.y + CV_IABS(y - ptOrigin.y);

      rectSel.x = MAX( rectSel.x, 0 );
      rectSel.y = MAX( rectSel.y, 0 );
      rectSel.width = MIN( rectSel.width, imgProcess->width );
      rectSel.height = MIN( rectSel.height, imgProcess->height );
      rectSel.width -= rectSel.x;
      rectSel.height -= rectSel.y;
   }

   switch ( event )
   {
      case CV_EVENT_LBUTTONDOWN:
         ptOrigin = cvPoint(x,y);
         rectSel = cvRect(x,y,0,0);
         modeSelectObject = 1;
         break;
      case CV_EVENT_LBUTTONUP:
         modeSelectObject = 0;
         if ( rectSel.width > 0 && rectSel.height > 0 )
            TrackMode=INITIALTRACK;
         break;
   }
}
/*
   Limit the HSV channels and split out the resulting Hue channel
 */
void imgToHue(IplImage *imghsv, IplImage *imgtm, IplImage **imgip)
{
cvSplit( imgHSV, imgip[0], imgip[1], imgip[2], 0 );
#if LIMIT==1
   cvInRangeS(
             imghsv,                             // ROI
             // Hue         Sat     Luminence
             cvScalar(0      ,   adjSmin, adjVmin,0),   // lower value array
             cvScalar(256,       adjSmax, adjVmax,0),   // upper value array
             imgtm                       // imgTargetMask  
             );
#else
   cvSet(imgtm, cvScalar(255));
#endif
}
void adjustLimits(IplImage *imgHSV)
{
   CvScalar avgHSV, stdHSV;
   cvAvgSdv(imgHSV,&avgHSV,&stdHSV);
#if LIMIT==1
   adjSmin = max(  0,  avgHSV.val[1] - stdHSV.val[1]/0.9);
   adjSmax = min(255,  avgHSV.val[1] + stdHSV.val[1]/1.0);
   adjVmin = max(  0,  avgHSV.val[2] - stdHSV.val[2]/0.5);
   adjVmax = 256;
   // temp, open wide up
   //cvSetTrackbarPos( "Vmin", "CamShiftWindow", adjVmin);
   //cvSetTrackbarPos( "Vmax", "CamShiftWindow", adjVmax);
   //cvSetTrackbarPos( "Smin", "CamShiftWindow", adjSmin);
   //cvSetTrackbarPos( "Smax", "CamShiftWindow", adjSmax);
#endif
}

void getTime(char *str)
{
   SYSTEMTIME access_st;
   LPSYSTEMTIME lpSystemTime = &access_st;

   GetLocalTime(lpSystemTime) ;
   sprintf(str,"%04d-%02d-%02d %02d-%02d-%02d.%04d"
      ,lpSystemTime->wYear
      ,lpSystemTime->wMonth
      ,lpSystemTime->wDay
      ,lpSystemTime->wHour
      ,lpSystemTime->wMinute
      ,lpSystemTime->wSecond
      ,lpSystemTime->wMilliseconds
      );   
}
int writeFrame(int tfc, IplImage *imgProcess, const char *type)
{
   char outFileName[255];
   char ts[30];
   getTime(ts);
   sprintf(outFileName,"Frames\\%s-Capture-%04d-%s.png",ts,tfc,type);
   if ( cvSaveImage(outFileName,imgProcess) )
   {
      fprintf(stdout,"Saved: %s\n",outFileName);
      return 1;
   }
   else
   {
      fprintf(stdout,"Could not save: %s\n",outFileName);
      return 0;
   }
}

