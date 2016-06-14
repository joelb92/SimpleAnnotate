#ifndef IMAGE_HANDLER_H
#define IMAGE_HANDLER_H

#include <iostream>
#include <string>

#include "opencv2/opencv.hpp"
#include "opencv2/legacy/legacy.hpp"

#include "ImageSource.h"
#include "Regions.h"

class ImageHandler
{
public:

	ImageHandler(ImageSource* imgSrc);
	virtual ~ImageHandler(void);

	bool getImage();
	bool getImage(const std::string& fileName);
    bool injectImage(cv::Mat image);
	void reloadImage();
	Size2 getImageSize2();
    CvSize getImageCvSize();

	void viewImage(char* name = "", int autoReSize2 = CV_WINDOW_AUTOSIZE);
    void viewImage(char* name, int autoresize, int width, int height);
		
	void saveImage(char* filename);

	IplImage* getIplImage();
	IplImage* getIplGrayImage();

    unsigned char* getGrayImage();
    unsigned char* getR_Channel();
    unsigned char* getG_Channel();
    unsigned char* getB_Channel();

    double* getGrayImageDb();
    double* getGrayImageDb2();
    unsigned char* getRGBImage();

	void paintRectangle(CvRect rect, Color2 color = Color2(255,255,0), int thickness = 1, bool filled = false);
    void paintRectangle(Rect2 rect, Color2 color = Color2(255,255,0), int thickness = 1, bool filled = false);
	void paintCenter(Rect2 rect, Color2 color = Color2(255,255,0), int thickness = 2);
	void paintLine(Point2D p1, Point2D p2, Color2 color = Color2(255,255,0), int thickness = 2);
	void paintCircle(Point2D center, int radius, Color2 color = Color2(255,255,0), int thickness = 1);
	void paintPoint(Point2D center, Color2 color = Color2(255,255,0), int thickness = 1);
	void putTextOnImage(char* text, Point2D org, Color2 color = Color2(255, 255, 0), float fontSize2 = 0.5);

	void saveROIofGrayImage(Rect2 rect, char* filename);
	unsigned char* getPatch(Rect2 rect);

	const char* getFilename(int idx=-1);

private:

 	ImageSource *m_imgSrc;
    char *m_windowName;

    IplImage *m_grayImage;
    IplImage *m_rgbImage;
    IplImage m_rgbImageNoPointer;
    IplImage m_grayImageNoPointer;
};

#endif //IMAGE_HANDLER_H
