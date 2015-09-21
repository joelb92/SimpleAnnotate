/****
* TJ Wilkason 2009 science fair project to track video objects
* Goal: Track video objects as the move through occlusions
* Various histogram related functions
*/
#include "camshift.h"
#define HS(hst,d) hst->mat.dim[d].size
/*
   External inputs
   imgHSV: Full image frame
   useRectSel: Selection Region
*/
void initHistogram(CvHistogram *histT, CvHistogram *histB, 
                   IplImage **imgip ,IplImage *imgtm, CvRect useRectSel, double threshold)
{
   /*
      First compute the histogram of the region of interest
      Put it into histT
      Create a mask of selection region only (for histograms)
   */
   int idx=0;
   int planes = 3;
   IplImage *imgrm = cvCreateImage( cvGetSize(imgip[0]), 8, 1 );
   cvZero(imgrm);
   cvSetImageROI( imgrm, useRectSel );
   cvSet(imgrm, cvScalar(255));

   // Set ROI on image planes and image mask based on passed in rectangle
   setRoi(imgip, planes, imgtm, useRectSel, 1);
   // Compute center weighted histogram of selection within ROI
   cvWeightHist(imgip, histT, imgtm);

   // Reset so full images are available
   cvResetImageROI( imgrm );
   setRoi(imgip, planes, imgtm, useRectSel, 0);
   /*
      Second, compute a histogram of a region outside the selection
      This will be the background histogram
      Do this by inverting the first mask, then setting a larger ROI
      Put it into histB
   */
   cvThreshold(imgrm, imgrm, 128, 255, CV_THRESH_BINARY_INV);
   // Use some, but not all of the background (2x), use 3X inside area per Comaniciu
   CvRect lgRectSel = useRectSel;
   lgRectSel.height*=2.0;
   lgRectSel.width*=2.0;
   setRoi(imgip, planes, imgrm, lgRectSel, 1);
   // Compute BG histogram
   // Todo: Weight this so farthest pixels have higher weight
   cvCalcHist( imgip, histB, 0, imgrm );
   setRoi(imgip, planes, imgrm, lgRectSel, 0);
   /*
      Third, compute a ratio histogram that weights the values
      in the target histogram more heavily if they are unique,
      values that occur
      in both histograms will get less weight
      Put it into histT
   */
   cvNormalizeHist(histT,maxHistVal);
   cvNormalizeHist(histB,maxHistVal);
   ratioHistogram (histT, histB);
   /*
      Forth, scale the resulting ratio histogram from 0-255 to represent high values (255) as
      the high probability pixels.
   */
   scaleHistogram(histT,maxHistVal,threshold);
   cvReleaseImage(&imgrm);
}

int histogramLength(CvHistogram *hist)
{
   int length = 1;
   for ( int i=0; i < hist->mat.dims; i++ )
      length *= hist->mat.dim[i].size;
   return length;
}
/*
    Ratio histogram, alter target based on background
    J. G. Allen, R. Y. D. Xu, and J. S. Jin. Object track-
    ing using camshift algorithm and multiple quantized
    feature spaces, 3.6.2
*/

void ratioHistogram (CvHistogram *histT, CvHistogram *histB)
{
   float bgmin=1000000.0;
   float weight=0.0;
   int length = histogramLength(histB);
   // Find minimum non-zero value first
   for ( int i=0; i < length;i++ )
   {
      float bg = cvQueryHistValue_1D(histB, i);
      if ( bg > 0 && bg < bgmin )
         bgmin = bg;
   }
   // Divide foreground by background by weighting
   // foreground by bgmin/bg value
   for ( int i=0; i < length;i++ )
   {
      float bg=cvQueryHistValue_1D(histB, i);
      float *fg=cvGetHistValue_1D(histT, i);
      if ( bg > 0 )
         weight = bgmin/bg;
      else
         weight = 1.0;
      *fg *= weight;
   }

}
/* 
   Center weighted histogram using a mask base on Epanechnikov kernal
   Accumulates a histogram based descreasining smaller reigons
   J. G. Allen, R. Y. D. Xu, and J. S. Jin. Object track-
   ing using camshift algorithm and multiple quantized
   feature spaces, 3.6.1
   Comaniciu et al., 1996 is original reference
*/
void cvWeightHist( IplImage** img, CvHistogram* hist, IplImage* mask)
{
   CvRect myROI = cvGetImageROI(img[0]);
   CvRect saveROI = myROI;
   cvClearHist(hist);
   // Stack up smaller and smaller regions based on Epanechnikov (x=sqrt(1-y))
   // This is the same as weigthing the center pixels since they will be counted
   // multiple times
   for ( float y=0.001; y < 1; y+=0.2f )
   {
      float Epa=sqrt(1-y);
      myROI.width=saveROI.width * Epa;
      myROI.height=saveROI.height * Epa;
      for ( int idx=0; idx < 3; idx++ )
         cvSetImageROI( img[idx], myROI );
      cvSetImageROI( mask, myROI );
      // Accumulate all three planes at once
      cvCalcHist( img, hist, 1, mask );          // accumulate
   }
   // Restore ROI
   for ( int idx=0; idx < 3; idx++ )
      cvSetImageROI( img[idx], saveROI );
   cvSetImageROI( mask, saveROI );
}
/* 
   Adjust relative weighting to improve backprojection 
   A Comparison of Mean Shift Tracking Methods
   Nicole M. Artner
*/
void blendHistogram(CvHistogram* hstTargetOrig, CvHistogram* hstTarget,CvHistogram* hstCandidate, double alpha1)
{
   double B =0.45;
   double alpha2 = (1.0 - alpha1)*B;             //candidate
   double alpha3 = (1.0 - alpha1) - alpha2;      // orig
   //double check = alpha1 + alpha2 + alpha3;
   int length = histogramLength(hstTargetOrig);
   for ( int i=0; i < length;i++ )
   {
      float canBinVal=cvQueryHistValue_1D(hstCandidate, i);
      float origBinVal=cvQueryHistValue_1D(hstTargetOrig, i);
      float *targBinVal=cvGetHistValue_1D(hstTarget, i);
      *targBinVal = (*targBinVal * alpha1 + alpha2*canBinVal + alpha3*origBinVal);
   }
}
/*
   Adjust the scale so the histogram has a peak value of 255 (normalize)
*/
void scaleHistogram (CvHistogram *hist, double value, double threshold)
{
   float max_val = 0.f;
   cvGetMinMaxHistValue( hist, 0, &max_val, 0, 0 );
   if ( max_val > 0 )
   {
      // Limit histogram to a dominant colors (top 90%)
      cvThreshHist(hist, max_val*threshold);
      // Scale from 0 to 255 (for masking)
      cvConvertScale( hist->bins, hist->bins, max_val ? value / max_val : 0., 0 );
   }

}
// Display a 2d histogram
void showHistogram (CvHistogram *hstShow, IplImage *imgShow)
{
   float max_val;
   cvGetMinMaxHistValue( hstShow, 0, &max_val, 0, 0 );
   cvZero( imgShow );
   if ( max_val > 0 )
   {
      double xscl = imgShow->width/HS(hstShow,0);
      double yscl = imgShow->height/HS(hstShow,1);
      // First dim is outer loop (largest step size)
      for ( int h = 0; h < HS(hstShow,0); h++ )
      {
         for ( int s = 0; s < HS(hstShow,1); s++ )
         {
            float bin_val=0;
            // add across all values for intensity (z plane)
#if DEPTH == 3
            for ( int v = 0; v < HS(hstShow,2); v++ )
            {
               bin_val += cvQueryHistValue_3D( hstShow, h, s , v);
            }
#else
            bin_val += cvQueryHistValue_2D( hstShow, h, s);
#endif
            // Get the color from hue and scale it by intensity
            double intensity = bin_val / max_val;
            CvScalar color = hsv2rgb((h*180.0)/HS(hstShow,0));
            for ( int jj = 0; jj < 3; jj++ )
               color.val[jj]*=intensity;

            cvRectangle( imgShow, cvPoint( h*xscl, s*yscl ),
                         cvPoint( (h+1)*xscl - 1, (s+1)*yscl - 1 ),
                         color,
                         CV_FILLED );
         }
      }
   }
}
/*
   Show 1D histogram for inner channel
*/
void show1DHistogram (CvHistogram *hist, IplImage *imgHistogram)
{
   float max_val=0;
   float bin_val=0;
   for ( int v = 0; v < HS(hist,2); v++ )
   {
      for ( int h = 0; h < HS(hist,0); h++ )
      {
         for ( int s = 0; s < HS(hist,1); s++ )
         {
            bin_val+= cvQueryHistValue_3D( hist, h, s , v);
         }
      }
      if (bin_val > max_val)
         max_val=bin_val;
      bin_val=0;
   }
   

   if ( max_val > 0 )
   {
      max_val*=1.1;
      // Draw the histogram
      cvZero( imgHistogram );
      //double xscl = imgHistogram->width/HS(hist,0);
      //double yscl = imgHistogram->height/HS(hist,1);
      double bin_w = imgHistogram->width/HS(hist,2);
      // First dim is outer loop (largest step size)
      // add across all values for intensity (z plane)
      for ( int v = 0; v < HS(hist,2); v++ )
      {
         bin_val=0;
         for ( int h = 0; h < HS(hist,0); h++ )
         {
            for ( int s = 0; s < HS(hist,1); s++ )
            {
               bin_val+= cvQueryHistValue_3D( hist, h, s , v);
            }
         }
         int val = cvRound( bin_val*imgHistogram->height/max_val );
         cvRectangle( imgHistogram, 
                      cvPoint(v*bin_w, imgHistogram->height),
                      cvPoint((v+1)*bin_w, imgHistogram->height - val),
                      CV_RGB(0,0,255), -1, 8, 0 );
      }
   }
}
/*
   Compute Saturation and Luminence limts for thresholding
*/

void setRoi(IplImage **imgip, int planes, IplImage *imgMask, CvRect roi, int how)
{
   if ( how )
   {
      cvSetImageROI( imgMask, roi );
      for ( int idx=0; idx<planes ;idx++ )
         cvSetImageROI( imgip[idx], roi );
   }
   else
   {
      cvResetImageROI( imgMask );
      for ( int idx=0; idx<planes; idx++ )
         cvResetImageROI( imgip[idx] );
   }

}

