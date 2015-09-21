#include "clsKalman.h"
#include "cv.h"

clsKalman::clsKalman(int MD)
{
   matPred = cvCreateMat( MD, 1, CV_32FC2 );
   matMeas = cvCreateMat( MD, 1, CV_32FC1 );
   objKalman = cvCreateKalman(MD*2, MD, 0);
   init(0,0,1,1,1);
};

clsKalman::~clsKalman()
{
   cvReleaseKalman(&objKalman);
};

// Look at running these as predict then correct then pull the state_post
void clsKalman::correct()
{
   cvKalmanCorrect(objKalman, matMeas); // returns post

};
void clsKalman::predict()
{
   matPred = cvKalmanPredict(objKalman,0);   // gets
   // Compute all the relavent data
   KD.x  = cvmGet(matPred,0,0);
   KD.vX = cvmGet(matPred,1,0);
   KD.y  = cvmGet(matPred,2,0);
   KD.vY = cvmGet(matPred,3,0);
   KD.len = sqrt(KD.x*KD.x + KD.y*KD.y);
   KD.vel = sqrt(KD.vX*KD.vX + KD.vY*KD.vY);
   KD.lenAngle = atan2(KD.y,KD.x);
   KD.velAngle = atan2(KD.vY,KD.vX);
};
void clsKalman::freeRun()
{
   cvmSet(matMeas,0,0,cvmGet(matPred,0,0)); // X 
   cvmSet(matMeas,1,0,cvmGet(matPred,2,0)); // Y 
};
void clsKalman::pX(double X)
{
   cvmSet(matMeas,0,0,X);
}
void clsKalman::pY(double Y)
{
   cvmSet(matMeas,1,0,Y);
}
// Get the prediction
void clsKalman::updateXY(double X, double Y)
{
   cvmSet(matMeas,0,0,X);
   cvmSet(matMeas,1,0,Y);
}
double clsKalman::pX()
{
   return cvmGet(matPred,0,0);
}
double clsKalman::vX()
{
   return cvmGet(matPred,1,0);
}
double clsKalman::pY()
{
   return cvmGet(matPred,2,0);
};
double clsKalman::vY()
{
   return cvmGet(matPred,3,0);
};
void clsKalman::init(double X, double Y, double tau, double sProcess, double sMeasurement)
{
   double dt = 1.0;                              // 1.0;    // higher the faster, maneuver time  // time interval between executions... 1 for "one run"...
   double dt2 = dt*dt;
   double dt3 = dt*dt*dt;
   //double tau=30.0;                              // frames per second
   //fprintf(stdout,"\nInitializing Kalman Matricies\n");
   // set up transition matrix A
   // time correlated velocity... will slow down with time
   // and have mostly stopped at time tau = "maneuvering time"
   CvMat *A = objKalman->transition_matrix;
   cvSetZero(A);
   int md = A->rows/2;
   for ( int i = 0; i < md; i++ )
   {
      int o = i*2;                               // origin of submatrix
      cvmSet(A, o  , o, 1);  cvmSet(A, o  , o+1, 1);
      cvmSet(A, o+1, o, 0);  cvmSet(A, o+1, o+1, 1);
   }
   //debugDumpMatrix(A,"Transition Matrix A");

   // set up posMeas matrix H 
   CvMat *H = objKalman->measurement_matrix;
   cvSetZero(H);
   for ( int i = 0; i < md; i++ )
   {
      cvmSet(H, i, i*2, 1); cvmSet(H, i, i*2+1, 0);
   }
   //cvSetIdentity( H, cvRealScalar(1) );
   //debugDumpMatrix(H,"Measurement Matrix H");

   // set up process noise matrix Q 
   // using Taylor series approximations only...
   double c = 2*sProcess*sProcess/tau;
   CvMat *Q = objKalman->process_noise_cov;
   cvSetZero(Q);
   for ( int i = 0; i < md; i++ )
   {
      int o = i*2;                               // origin of submatrix
      cvmSet(Q, o  , o, c*dt3/3);  
      cvmSet(Q, o  , o+1, c*dt2/2);
      cvmSet(Q, o+1, o, c*dt2/2);  
      cvmSet(Q, o+1, o+1, c*dt);
   }
   //debugDumpMatrix(Q,"Process Noise Matrix Q");

   // set up posMeas noise R
   CvMat *R = objKalman->measurement_noise_cov;
   cvSetZero(R);
   for ( int i = 0; i < md; i++ )
   {
      cvmSet(R, i, i, sMeasurement*sMeasurement);
   }
   //debugDumpMatrix(R,"Measurement Noise Matrix R");

   // here, the initial error is estimated to the process noise...
   cvCopy(objKalman->process_noise_cov, objKalman->error_cov_post);
   // Initialize the matrix to some position
   cvSetZero(objKalman->state_post);
   CvMat *P = objKalman->state_pre;
   cvSetZero(P);
   cvmSet(P,0,0,X);
   cvmSet(P,1,0,0);
   if ( A->rows > 2 )
   {
      cvmSet(P,2,0,Y);
      cvmSet(P,3,0,0);
   }

}