#ifndef _SAMPLESTAT_H
#define _SAMPLESTAT_H

/*! \file Coord.h
 *
 *
 * 
 *
 *
 *  \author Copyright (C) 2005-2006 by Iacopo Masi <iacopo.masi@gmail.com>
 *   		 	and Nicola Martorana <martorana.nicola@gmail.com>
 *			and Marco Meoni <meonimarco@gmail.com>
 * 			This  code is distributed under the terms of <b>GNU GPL v2</b>
 *
 *  \version $Revision: 0.1 $
 *  \date 2007/02/02 
 * 
 *
 *
 */

class sampleStat
{
private: 
   float* sampleSet ; 
   int N;
   float Sum;
   float sum()
   {
      Sum = 0;
      for ( int i=0; i<N; i++ )
         Sum += sampleSet[i];
      return Sum;
   }

   float sqm()
   {
      float Mean, Sqm=0;
      Mean = getMean();
      for ( int i=0; i<N; i++ )
      {
         Sqm+=(sampleSet[i]-Mean)*(sampleSet[i]-Mean);
      }
      return Sqm; 
   }
public: 
   void setValue (float x, int i)
   {
      sampleSet[i]=x;
   }

   sampleStat(int n)
   {
      N = n; 
      sampleSet = new float[N];  
   }

   float getMean()
   {

      return sum()/N;
   }

   float getVariance()
   {
      float Sqm;
      Sqm = sqm();
      return Sqm/(N-1);
   }

   float getStdDeviation()
   {
      return sqrt(getVariance());
   }
};
#endif

