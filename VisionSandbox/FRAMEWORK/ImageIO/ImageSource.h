#ifndef IMAGE_SOURCE_H
#define IMAGE_SOURCE_H

#include <string>
#include <opencv2/opencv.hpp>
//#include "opencv2/legacy/legacy.hpp"
#include "Regions.h"

class ImageSource
{
public:

	enum InputDevice {AVI, USB, DIRECTORY};

	IplImage *curImage;
    IplImage curImageNoPointer;
    IplImage *m_copyImg;
	ImageSource();
    ~ImageSource();

    void getIplImage();
    void getIplImage(const std::string& fileName);
    void injectImage(cv::Mat img);
    
    void reloadIplImage();
    const char* getFilename(int idx=-1);

	Size2 getImageSize2();
	CvSize getImageCvSize();

	bool isImageAvailable();
    void reset();

protected:

	char aviFilename[255 + 1];


};

#endif //IMAGE_SOURCE_H
