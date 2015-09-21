#ifndef CLSKALMAN
#define CLSKALMAN
#include <stdio.h>
#include "opencv2/opencv.hpp"
#include "opencv2/legacy/legacy.hpp"
struct dRect {
   double x;
   double y;
   double len;
   double lenAngle;
   double vX;
   double vY;
   double vel;
   double velAngle;
};

class clsKalman 
{

public:
   virtual ~clsKalman();  
   clsKalman(int md=1);
   void init(double X=0, double Y=0, double tau=1, double sProcess=1, double sMeasurement=1);
   void correct();
   void predict();
   void pX(double X);
   void pY(double Y);
   void updateXY(double X, double Y);
   double pX();
   double pY();
   double vX();
   double vY();
   void freeRun();
   dRect KD;

private:
   const CvMat* matPred;
   CvMat* matMeas;
   CvKalman* objKalman;
};
#endif // CLSKALMAN
