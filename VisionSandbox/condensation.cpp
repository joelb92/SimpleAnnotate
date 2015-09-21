/*! \file condensation.cpp
 *
 *  \brief <b>This file contains the functions that implement the Condensation</b>
 *
 *
 *  \author Copyright (C) 2005-2006 by Iacopo Masi <iacopo.masi@gmail.com>
 *   		 	and Nicola Martorana <martorana.nicola@gmail.com>
 *			and Marco Meoni <meonimarco@gmail.com>
 * 			This  code is distributed under the terms of <b>GNU GPL v2</b>
 *
 *  \version $Revision: 0.1 $
 *  \date 2006/10/27 
 *
 */

#include "camshift.h" 
#include <stdio.h>
CvConDensation* initCondensation ( CvMat** indexMat, int nSample, int maxWidth, int maxHeight )
{

   /*
      A=[1,0,1,0;0,1,0,1;0,0,1,0;0,0,0,1]
      Bu=[0;0;0;0]
   */

   indexMat[0] = cvCreateMat(4,4, CV_32FC1 );
   // State Matrix
   double aMat[] = {1,0,1,0, 0,1,0,1, 0,0,1,0, 0,0,0,1};
   for (int i= 0; i < 16;i++)
   {
      indexMat[0]->data.fl[i] = aMat[i];
   }
   indexMat[1] = cvCreateMat(4,1, CV_32FC1 );   // B (Measurement)
   indexMat[2] = cvCreateMat(2,4, CV_32FC1 );   // H State
   int DP = indexMat[0]->cols;                   //! number of state vector dimensions */
   int MP = indexMat[2]->rows;                   //! number of measurement vector dimensions */

   CvConDensation* ConDens = cvCreateConDensation( DP, MP, nSample );
   CvMat* lowerBound;
   CvMat* upperBound;
   lowerBound = cvCreateMat(DP, 1, CV_32F);
   upperBound = cvCreateMat(DP, 1, CV_32F);
   // Locations
   cvmSet( lowerBound, 0, 0, 0.0 ); 
   cvmSet( upperBound, 0, 0, maxWidth/3 );

   cvmSet( lowerBound, 1, 0, 0.0 ); 
   cvmSet( upperBound, 1, 0, maxHeight/3 );
   // Velocities
   cvmSet( lowerBound, 2, 0, -10.0 ); 
   cvmSet( upperBound, 2, 0, 10.0 );

   cvmSet( lowerBound, 3, 0, -10.0 ); 
   cvmSet( upperBound, 3, 0, 10.0 );
   //ConDens->DynamMatr = &indexMat[0]; fa il set della matrice del sistema


   for ( int i=0;i<DP*DP;i++ )
   {
     ConDens->DynamMatr[i]= indexMat[0]->data.fl[i];
   }

   cvConDensInitSampleSet(ConDens, lowerBound, upperBound);

   CvRNG rng_state = cvRNG(0xffffffff);

   for ( int i=0; i < nSample; i++ )
   {
      ConDens->flSamples[i][0] = (cvRandInt( &rng_state ) % maxWidth) ;   //0 represent the widht (x coord)
      ConDens->flSamples[i][1] = (cvRandInt( &rng_state ) % maxHeight);   //1 represent the height (y coord)
   }


   //ConDens->DynamMatr=(float*)indexMat[0];
   //ConDens->State[0]=maxWidth/2;
   //ConDens->State[1]=maxHeight/2;
   //ConDens->State[2]=0;
   //ConDens->State[3]=0;

   return ConDens;
}

coord updateCondensation ( CvConDensation* ConDens, coord Measurement, float * stdDX_ptr, float * stdDY_ptr)
{
   coord prediction;
   //ConDens->State[0] = Measurement.cX;
   //ConDens->State[1] = Measurement.cY;
   for (int i = 0; i < 1; i++)
   {
      updateProcessProbDens(ConDens, Measurement, stdDX_ptr, stdDY_ptr);
      cvConDensUpdateByTime(ConDens);
   }
   prediction.set(ConDens->State[0], ConDens->State[1]);
   return prediction;   
}

coord getCondensation ( CvConDensation* ConDens)
{
   coord prediction;
   cvConDensUpdateByTime(ConDens);
   prediction.set(ConDens->State[0], ConDens->State[1]);
   return prediction;   
}
void condenShow(IplImage *imgProcess, CvConDensation *ConDens)
{
   for ( int i = 0; i < ConDens->SamplesNum; i++ )
   {
      double X = ConDens->flSamples[i][0];
      double Y = ConDens->flSamples[i][1];
      cvCircle (imgProcess, cvPoint (X, Y), 2, CV_RGB (0, 0, 255), -1);
   }  
}
void updateProcessProbDens ( CvConDensation* ConDens, coord Measurement, float * stdDX_ptr, float * stdDY_ptr)
{

   float ProbX, ProbY, stdDevX, stdDevY , varianceX, varianceY;
   
   ProbX=1; ProbY=1;
   sampleStat* statSampleX = new sampleStat (ConDens->SamplesNum);
   sampleStat* statSampleY = new sampleStat (ConDens->SamplesNum);

   //float stdev = sqrt(var/ConDens->SamplesNum);
   for ( int i = 0; i < ConDens->SamplesNum; i++ )
   {
      statSampleX->setValue(ConDens->flSamples[i][0],i);
      statSampleY->setValue(ConDens->flSamples[i][1],i);
   }  

   varianceX = statSampleX->getVariance();
   varianceY = statSampleY->getVariance();
   stdDevX = sqrt(varianceX);
   stdDevY = sqrt(varianceY);
   int max = 0;  
   double totProb=0;
   for ( int i = 0; i < ConDens->SamplesNum; i++ )
   {
      double flX = Measurement.cX - ConDens->flSamples[i][0];
      double flY = Measurement.cY - ConDens->flSamples[i][1];
      ProbX = (float) exp( -10. * flX*flX / (2*varianceX) );
      ProbY = (float) exp( -10. * flY*flY / (2*varianceY) );

      //ProbX = sqrt(1/abs(flX));
      //ProbY = sqrt(1/abs(flY));
      ConDens->flConfidence[i] = ProbX*ProbY;
      totProb+=ProbX*ProbY;
      // should sum of all probabilities be set =1 (normalized) then applied?
      if ( ConDens->flConfidence[max] < ConDens->flConfidence[i] )
         max = i;
   }
   // Normalize (not necessary)
   for ( int i = 0; i < ConDens->SamplesNum; i++ )
   {
      ConDens->flConfidence[i] /= totProb;
   }
//fprintf(stdout,"meas=%f std=%f mean=%f best=%f\n",Measurement.cX,stdDevX, statSampleX->getMean(),ConDens->flSamples[max][0]);

   *stdDX_ptr = stdDevX;
   *stdDY_ptr = stdDevY;
   //printf("\nstdDXcondens:%f\nstdDYcondens:%f",stdDevX,stdDevY);
}

