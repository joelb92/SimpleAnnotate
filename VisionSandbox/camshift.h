/****
* TJ Wilkason 2009 science fair project to track video objects
*/
#ifndef CAMSHIFT
#define CAMSHIFT
#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include "opencv2/opencv.hpp"
#include "opencv2/legacy/legacy.hpp"
#define SQ(x) ((x)*(x))
#define RMS(x,y)  sqrt((x)*(x)+(y)*(y))
#define SIGN(x,y) (x/abs(x))*(y/abs(y))
#define xBOXm(box)   (unsigned int)(box.center.x - box.size.width/2.0)
#define yBOXm(box)   (unsigned int)(box.center.y - box.size.height/2.0)
#define xBOXp(box)   (unsigned int)(box.center.x + box.size.width/2.0)
#define yBOXp(box)   (unsigned int)(box.center.y + box.size.height/2.0)
#define RoundUp(x) x > 0 ? ceil(x) : floor(x)
#define DEBUG 0
#define MD 2   // matrix dim
#define SD 4   // matrix dim (2 x MD)
#define maxHistVal 255
#define DEPTH 3
#define LIMIT 1

static const double PI = CV_PI;
static const double deg2rad = PI/180.0;
static const double rad2deg = 180.0/CV_PI;

enum OccludedType {NO, INITIAL, YES};
enum TrackType {NOTRACK, INITIALTRACK, FULLTRACK};
void plot_crosshairs(IplImage *image, CvPoint point, int thickness, int size,CvScalar color);
void debugDumpMatrix (CvMat *A,const char *Title);
void on_mouse( int event, int x, int y, int flags, void* param );
CvScalar hsv2rgb( float hue );
void limitXY(CvRect *val, IplImage *image, int vmin);
void drawText(IplImage *image, const char *str, int X, CvFont *font,CvScalar color);
// copy src to dst with with the given offset
void copy(IplImage* src, IplImage* dst, CvPoint offset);
void initKalman (CvKalman *posKalman, int X, int Y, double dt, double sProcess, double sMeasurement);
void initKalmanSimple (CvKalman *posKalman, int X, int Y, double dt, double sProcess, double sMeasurement);
void setKalmanMeasCovariance (CvKalman *posKalman, double M);
void copyALL(IplImage* src, IplImage* dst, CvPoint offset);	
float emDistance(CvHistogram *hist1,CvHistogram *hist2, int bins);
void cvWeightHist( IplImage** img, CvHistogram* hist, IplImage* mask);
void setRoi(IplImage **imgip, int planes, IplImage *imgMask, CvRect roi, int how);
void imgToHue(IplImage *imghsv, IplImage *imgtm, IplImage **imgHSVPlanes);
void scaleHistogram (CvHistogram *hist, double value, double threshold);
void ratioHistogram (CvHistogram *histT, CvHistogram *histB);
void blendHistogram(CvHistogram* hstTargetOrig, CvHistogram* hstTarget,CvHistogram* hstCandidate, double factor);
void showHistogram (CvHistogram *hstShow, IplImage *imgShow);
void show1DHistogram (CvHistogram *hstShow, IplImage *imgShow);

double rms(double x, double y);
float rms(float x, float y);
void cvRotRect( CvArr* imgProcess, CvBox2D bt, CvScalar track_color, int thickness CV_DEFAULT(1),int line_type CV_DEFAULT(8));
void cvArrow(CvArr* frame1, CvPoint p, CvPoint q,
             CvScalar line_color, int line_thickness,
             int line_type);
float framesPerSecond(CvCapture *capture);
float getNowMS(void);
void adjustHistogram(CvHistogram* hstShow);
void LBP8(IplImage *input, IplImage *output,int size, int os=0);
void VAR8(IplImage *input, IplImage *output);
int writeFrame(int tfc, IplImage *imgProcess, const char *type);


struct results
{
   long camCycles;
   long totFrames;
   long Occluded;
   double cumKalamError;
};
#include "Coord.h"
#include "SampleStat.h"
CvConDensation* initCondensation ( CvMat** indexMat, int nSample, int maxWidth, int maxHeight );
coord updateCondensation ( CvConDensation* ConDens, coord Measurement, float * stdDX_ptr, float * stdDY_ptr);
void updateProcessProbDens ( CvConDensation* ConDens, coord Measurement, float * stdDX_ptr, float * stdDY_ptr);
coord getCondensation ( CvConDensation* ConDens);
void condenShow(IplImage *imgProcess, CvConDensation *ConDes);

#endif