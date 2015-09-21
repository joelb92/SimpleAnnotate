/****
* TJ Wilkason 2009 science fair project to track video objects
*/
#include "camshift.h"
void initKalman (CvKalman *posKalman, int X, int Y, double tau, double sProcess, double sMeasurement)
{
   double dt = 1.0;                              // 1.0;    // higher the faster, maneuver time  // time interval between executions... 1 for "one run"...
   double dt2 = dt*dt;
   double dt3 = dt*dt*dt;
   //double tau=30.0;                              // frames per second
   //fprintf(stdout,"\nInitializing Kalman Matricies\n");
   // set up transition matrix A
   // time correlated velocity... will slow down with time
   // and have mostly stopped at time tau = "maneuvering time"
   CvMat *A = posKalman->transition_matrix;
   cvSetZero(A);
   int md = A->rows/2;
#ifdef MANUVER
   for ( int i = 0; i < md; i++ )
   {
      int o = i*2;                               // origin of submatrix
      cvmSet(A, o  , o, 1);  cvmSet(A, o  , o+1, (1-exp(-dt/tau))*tau);
      cvmSet(A, o+1, o, 0);  cvmSet(A, o+1, o+1,    exp(-dt/tau));
   }
#else
   for ( int i = 0; i < md; i++ )
   {
      int o = i*2;                               // origin of submatrix
      cvmSet(A, o  , o, 1);  cvmSet(A, o  , o+1, 1);
      cvmSet(A, o+1, o, 0);  cvmSet(A, o+1, o+1, 1);
   }
#endif
   debugDumpMatrix(A,"Transition Matrix A");

   // set up posMeas matrix H 
   CvMat *H = posKalman->measurement_matrix;
   cvSetZero(H);
   for ( int i = 0; i < md; i++ )
   {
      cvmSet(H, i, i*2, 1); cvmSet(H, i, i*2+1, 0);
   }
   //cvSetIdentity( H, cvRealScalar(1) );
   debugDumpMatrix(H,"Measurement Matrix H");

   // set up process noise matrix Q 
   // using Taylor series approximations only...
   double c = 2*sProcess*sProcess/tau;
   CvMat *Q = posKalman->process_noise_cov;
   cvSetZero(Q);
   for ( int i = 0; i < md; i++ )
   {
      int o = i*2;                               // origin of submatrix
      cvmSet(Q, o  , o, c*dt3/3);  
      cvmSet(Q, o  , o+1, c*dt2/2);
      cvmSet(Q, o+1, o, c*dt2/2);  
      cvmSet(Q, o+1, o+1, c*dt);
   }
   debugDumpMatrix(Q,"Process Noise Matrix Q");

   // set up posMeas noise R
   CvMat *R = posKalman->measurement_noise_cov;
   cvSetZero(R);
   for ( int i = 0; i < md; i++ )
   {
      cvmSet(R, i, i, sMeasurement*sMeasurement);
   }
   debugDumpMatrix(R,"Measurement Noise Matrix R");

   // here, the initial error is estimated to the process noise...
   cvCopy(posKalman->process_noise_cov, posKalman->error_cov_post);
   // Initialize the matrix to some position
   cvSetZero(posKalman->state_post);
   CvMat *P = posKalman->state_pre;
   cvSetZero(P);
   cvmSet(P,0,0,X);
   cvmSet(P,1,0,0);
   if ( A->rows > 2 )
   {
      cvmSet(P,2,0,Y);
      cvmSet(P,3,0,0);
   }
}
void setKalmanMeasCovariance (CvKalman *posKalman, double M)
{
   // set up posMeas noise R
   CvMat *R = posKalman->measurement_noise_cov;
   cvSetZero(R);
   for ( int i = 0; i < R->rows; i++ )
   {
      cvmSet(R, i, i, M*M);
   }

}
void initKalmanSimple (CvKalman *posKalman, int X, int Y, double dt, double sProcess, double sMeasurement)
{
   CvMat *A = posKalman->transition_matrix;
   cvSetZero(A);
   int md = A->rows/2;
   for ( int i = 0; i < md; i++ )
   {
      int o = i*2;                               // origin of submatrix
      cvmSet(A, o  , o, 1);  cvmSet(A, o  , o+1, dt);
      cvmSet(A, o+1, o, 0);  cvmSet(A, o+1, o+1, dt);
   }
   debugDumpMatrix(A,"Transition Matrix A");

   // set up posMeas matrix H 
   CvMat *H = posKalman->measurement_matrix;
   cvSetZero(H);
   for ( int i = 0; i < md; i++ )
   {
      cvmSet(H, i, i*2, 1); 
      cvmSet(H, i, i*2+1, 0);
   }
   //cvSetZero(H);
   //cvSetIdentity( H, cvRealScalar(1) );
   debugDumpMatrix(H,"Measurement Matrix H");

   // set up process noise matrix Q 
   // using Taylor series approximations only...
   double c = sProcess*sProcess;
   CvMat *Q = posKalman->process_noise_cov;
   cvSetZero(Q);
   for ( int i = 0; i < md; i++ )
   {
      int o = i*2;                               // origin of submatrix
      cvmSet(Q, o  , o, c);  
      cvmSet(Q, o  , o+1, c);
      cvmSet(Q, o+1, o, c);  
      cvmSet(Q, o+1, o+1, c);
   }
   debugDumpMatrix(Q,"Process Noise Matrix Q");

   // set up posMeas noise R
   CvMat *R = posKalman->measurement_noise_cov;
   cvSetZero(R);
   for ( int i = 0; i < md; i++ )
   {
      cvmSet(R, i, i, sMeasurement*sMeasurement);
   }
   debugDumpMatrix(R,"Measurement Noise Matrix R");

   // here, the initial error is estimated to the process noise...
   cvCopy(posKalman->process_noise_cov, posKalman->error_cov_post);
   // Initialize the matrix to some position
   cvSetZero(posKalman->state_post);
   CvMat *P = posKalman->state_pre;
   cvSetZero(P);
   cvmSet(P,0,0,X);
   cvmSet(P,1,0,0);
   if ( A->rows > 2 )
   {
      cvmSet(P,2,0,Y);
      cvmSet(P,3,0,0);
   }
}


void plot_crosshairs(IplImage *image, CvPoint point, int thickness, int size,CvScalar color)
{
   CvPoint endpoint1, endpoint2;
   endpoint1.x = point.x - size/2;
   endpoint1.y = point.y;
   endpoint2.x = point.x + size/2;
   endpoint2.y = point.y;
   cvLine(image, endpoint1, endpoint2, color, thickness);
   endpoint1.y = point.y - size/2;
   endpoint1.x = point.x;
   endpoint2.y = point.y + size/2;
   endpoint2.x = point.x;
   cvLine(image, endpoint1, endpoint2, color, thickness);
}

CvScalar hsv2rgb( float hue )
{
   int rgb[3], p, sector;
   static const int sector_data[][3]=
   {{0,2,1}, {1,2,0}, {1,0,2}, {2,0,1}, {2,1,0}, {0,1,2}};
   hue *= 0.033333333333333333333333333333333f;
   sector = cvFloor(hue);
   p = cvRound(255*(hue - sector));
   p ^= sector & 1 ? 255 : 0;

   rgb[sector_data[sector][0]] = 255;
   rgb[sector_data[sector][1]] = 0;
   rgb[sector_data[sector][2]] = p;

   return cvScalar(rgb[2], rgb[1], rgb[0],0);
}
// Limit rectangle such that the x+wid fits in the 0 640 / 0 480 box
// (pass in min window size, and adjust for that)
void limitXY(CvRect *val, IplImage *image, int vmin)
{
   // Min width/height
   if ( val->width < vmin )
   {
      val->width=image->width;
      val->x=0;
   }
   if ( val->height < vmin )
   {
      val->height = image->height;
      val->y=0;
   }

   // If box > right hand side, shift x left
   if ( val->x + val->width > image->width )
      val->x = image->width-val->width;
   // if too far left, move to 0 and reduce with
   if ( val->x < 0 )
      val->x=0;
   if ( val->x + val->width >= image->width )
      val->width=image->width-val->x;

   // If box > right hand side, shift y left
   if ( val->y + val->height > image->height )
      val->y = image->height-val->height;
   // if too far left, move to 0 and reduce with
   if ( val->y < 0 )
      val->y=0;
   if ( val->y + val->height >= image->height )
      val->height=image->height-val->y;

}

void drawText(IplImage *image, const char *str, int X, CvFont *font, CvScalar color) 
{
   cvPutText(image,str,cvPoint(1,X),font, color);
}

void debugDumpMatrix (CvMat *A,const char *Title)
{
#if DEBUG==1
   fprintf(stdout,"%s\n",Title);
   for ( int i=0; i < A->rows;i++ )
   {
      for ( int j=0; j < A->cols;j++ )
      {
         fprintf(stdout,"%5.3f  ",cvmGet(A,i,j));
      }
      fprintf(stdout,"\n");
   }
#endif
}
// Compute earth movers distance to find how close histograms are
// 0 means the same (no change needed)
float emDistance(CvHistogram *hist1,CvHistogram *hist2, int bins)
{
   CvMat* sig[2];
   sig[0] = cvCreateMat(bins, 2, CV_32FC1);
   sig[1] = cvCreateMat(bins, 2, CV_32FC1);
   //fill it
   for ( int h = 0; h < bins; h++ )
   {
      float bvh1 = cvQueryHistValue_1D( hist1, h);
      float bvh2 = cvQueryHistValue_1D( hist2, h);
      cvSet2D(sig[0],h,0 ,cvScalar(bvh1));   //Value
      cvSet2D(sig[0],h,1 ,cvScalar(h));      //Index
      cvSet2D(sig[1],h,0 ,cvScalar(bvh2));   //Value
      cvSet2D(sig[1],h,1 ,cvScalar(h));      //Index
   }
   float emd= cvCalcEMD2(sig[0],sig[1],CV_DIST_L2);
   cvReleaseMat(&sig[0]);
   cvReleaseMat(&sig[1]);
   return emd;
}
double rms(double x, double y)
{
   return sqrt((x)*(x)+(y)*(y));
}
float rms(float x, float y)
{
   return sqrt((x)*(x)+(y)*(y));
}
//y' = x cos f - y sin f
//x' = y cos f + x sin f
CvPoint rotatePoint(CvPoint i, double angle)
{
   CvPoint o;
   o.y = i.x*cos(angle) - i.y*sin(angle);
   o.x = i.y*cos(angle) + i.x*sin(angle);
   return o;
}
// Rotated rectangle, like the rotated ellipse
void cvRotRect( CvArr* imgProcess, CvBox2D bt, CvScalar track_color, int thickness,int line_type)
{
   CvPoint ur;
   CvPoint lr;
   CvPoint ul;
   CvPoint ll;
   double radAng = bt.angle * deg2rad;
   // Rotate
   ur = rotatePoint(cvPoint( + bt.size.width/2.0 , - bt.size.height/2.0),radAng);
   lr = rotatePoint(cvPoint( + bt.size.width/2.0 , + bt.size.height/2.0),radAng);
   ul = rotatePoint(cvPoint( - bt.size.width/2.0 , - bt.size.height/2.0),radAng);
   ll = rotatePoint(cvPoint( - bt.size.width/2.0 , + bt.size.height/2.0),radAng);
   // Add offset
   ur.x+= bt.center.x;
   ur.y+= bt.center.y;
   lr.x+= bt.center.x;
   lr.y+= bt.center.y;
   ul.x+= bt.center.x;
   ul.y+= bt.center.y;
   ll.x+= bt.center.x;
   ll.y+= bt.center.y;
   // New Rectangle
   cvLine(imgProcess,ul,ur, track_color,thickness,line_type);
   cvLine(imgProcess,ur,lr, track_color,thickness,line_type);
   cvLine(imgProcess,lr,ll, track_color,thickness,line_type);
   cvLine(imgProcess,ll,ul, track_color,thickness,line_type);
   // Cross Hair
   CvPoint t;
   CvPoint b;
   CvPoint l;
   CvPoint r;
   // Mid point
   t = rotatePoint(cvPoint( + 0 , - bt.size.height/2.0),radAng);
   b = rotatePoint(cvPoint( + 0 , + bt.size.height/2.0),radAng);
   l = rotatePoint(cvPoint( - bt.size.width/2.0 , - 0),radAng);
   r = rotatePoint(cvPoint( + bt.size.width/2.0 , + 0),radAng);
   // Add offset
   t.x+= bt.center.x;
   t.y+= bt.center.y;
   b.x+= bt.center.x;
   b.y+= bt.center.y;
   l.x+= bt.center.x;
   l.y+= bt.center.y;
   r.x+= bt.center.x;
   r.y+= bt.center.y;
   // New Cross Lines
   cvLine(imgProcess,t,b, track_color,1,line_type);
   cvLine(imgProcess,l,r, track_color,1,line_type);
}
//
// Draw a line with an arrow head
void cvArrow(CvArr* frame1, CvPoint p, CvPoint q,
             CvScalar line_color, int line_thickness = 1,
             int line_type = 8)
{
   double angle = atan2( (double) p.y - q.y, (double) p.x - q.x );

   cvLine( frame1, p, q, line_color, line_thickness, CV_AA, 0 );
   /* Now draw the tips of the arrow.  I do some scaling so that the
    * tips look proportional to the main line of the arrow.
    */
   double al = 6.0;
   p.x = (int) (q.x + al * cos(angle + CV_PI / 4));
   p.y = (int) (q.y + al * sin(angle + CV_PI / 4));
   cvLine( frame1, p, q, line_color, line_thickness, CV_AA, 0 );
   p.x = (int) (q.x + al * cos(angle - CV_PI / 4));
   p.y = (int) (q.y + al * sin(angle - CV_PI / 4));
   cvLine( frame1, p, q, line_color, line_thickness, CV_AA, 0 );
}
// Return the camera frame rate (for webcams)
// Take two seconds of frames and see how long it takes
float framesPerSecond(CvCapture *capture)
{
   int64 startTime = cvGetTickCount();
   int64 elapTime = 0;
   int64 tickTime = 1000000*cvGetTickFrequency();
   IplImage *frame = 0;
   int i;
   for (i=1; i <= 100; i++)
   {
      frame = cvQueryFrame(capture);
      elapTime = ((cvGetTickCount()- startTime))/tickTime;
      if (elapTime >= 2.0)
         break; 
   }
   if (elapTime > 0)
      return (float)i/elapTime;
   else
      return 30;
}
// Get tick count in ms
float getNowMS(void)
{
   int64 startTime = cvGetTickCount();
   int64 elapTime = 0;
   int64 tickTime = 1000000*cvGetTickFrequency();
   IplImage *frame = 0;
   elapTime = (float)startTime/tickTime;
   return elapTime;
}

