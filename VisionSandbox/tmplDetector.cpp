/****
* Template Detection to find initial position of robot
* TJ Wilkason 2009
*/
#include "tmplDetector.h"
#include "FindFile.h"
float abs_(float v)
{
   return v<0?-v:v;
}


double detector::compareToDatabase(IplImage *srchImage, CvRect *Res)
{
   CvSize pSize = cvGetSize(srchImage);
   double peak=0;
   for ( unsigned int i=0; i < dataBase.size(); i++ )
   {
      // prepare image for result
      CvSize tmplSize = cvGetSize(dataBase.at(i));

      // Image to hold result
      IplImage * result = cvCreateImage(
                                       cvSize(pSize.width-tmplSize.width+1,pSize.height-tmplSize.height+1), 
                                       IPL_DEPTH_32F,
                                       1);

      CvPoint pmin,pmax;
      double min,max;
      // Importortant Line in this Function:CV_TM_SQDIFF_NORMED CV_TM_CCORR_NORMED CV_TM_CCOEFF_NORMED
      cvMatchTemplate(srchImage, dataBase.at(i) , result, CV_TM_CCOEFF_NORMED);
      cvMinMaxLoc(result, &min, &max, &pmin, &pmax);
      // Find min value (for sqdiff, cor methods use max value)
      if ( max > peak )
      {
         peak = max;
         Res->x = pmax.x;
         Res->y = pmax.y;
         Res->width = tmplSize.width;
         Res->height = tmplSize.height;
         //int shrinkage = Res->width/4+2;
         //scaleRect(Res,shrinkage); // not needed if thresholding histogram
      }
      // destroy result image here
      cvReleaseImage(&result);

#if 0
      cout << endl << "Size of db-Image: " << tmplSize.width << " " << tmplSize.height << endl;
      cout << "min: " << min << endl;
      cout << "max: " << max << endl;
      cout << "pmin: x:" << pmin.x << " y: " << pmin.y << endl;
      cout << "pmax: x:" << pmax.x << " y: " << pmax.y << endl;
#endif
   }
   cout << "peak:" << peak<< endl;
   return peak;
}

void detector::loadDataBase(char imFile[][30])
{
   IplImage *dbI;
   for ( int i=0; i < REFIM; i++ )
   {
      dbI = cvLoadImage(imFile[i], 1);
      if ( dbI )
      {
         dataBase.push_back(dbI);
      }
   }
}
void detector::loadDataBasePath(char *path)
{
   FindFileOptions_t opts;
   opts.excludeDir = "";
   opts.excludeFile = "";
   opts.filter = "*.png;*.jpg";
   opts.location = path;
   opts.recursive = false;
   opts.returnFolders = false;
   opts.terminateValue = NULL;

   FindFile find(opts);
   find.search();
   //int nfiles = (int) find.filelist.size();
   //int size = find.listsize;


   IplImage *dbI;
   for ( int i = 0; i < (int) find.filelist.size(); i++ )
   {
      string fullname = FindFile::combinePath(
         find.filelist[i].path,
         find.filelist[i].fileinfo.cFileName
      );
      dbI = cvLoadImage(fullname.c_str(), 1);
      if ( dbI )
      {
         dataBase.push_back(dbI);
      }
   }
}
void detector::scaleRect(CvRect *Res, int Shrinkage)
{
   Res->x += Shrinkage;
   Res->y += Shrinkage;
   Res->width -= Shrinkage*2;
   Res->height -= Shrinkage*2;
}


