/*******
*  tj Wilkason, class for template files
*/
#ifndef TMPLDETECTOR
#define TMPLDETECTOR
#include <iostream>
#include <vector>
#include "opencv2/opencv.hpp"
#include "opencv2/legacy/legacy.hpp"
#define REFIM 12 // templates

using namespace std;

struct detector
{

   IplImage* mean;

   vector<IplImage*> dataBase;

   void loadDataBase(char imfile[][30]);
   void loadDataBasePath(char *path);
   double compareToDatabase(IplImage* patch, CvRect *Res);
   void scaleRect(CvRect *Res, int Shrinkage);
};
#endif 