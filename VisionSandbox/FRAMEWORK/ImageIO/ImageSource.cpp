#include "ImageSource.h"

ImageSource::ImageSource()
{
    curImage = NULL;
    m_copyImg = NULL;
}


ImageSource::~ImageSource()
{
}

void ImageSource::getIplImage()
{
    return;
}

void ImageSource::getIplImage(const std::string& fileName)
{
    return;
}

void ImageSource::injectImage(cv::Mat img)
{
    curImageNoPointer = IplImage(img.clone());
    curImage = &curImageNoPointer;
    
    if (curImage->origin == 1)
    {
        cvFlip(curImage, curImage, 0);
        curImage->origin = 0;
    }
    
    if (m_copyImg != NULL)
    {
        cvReleaseImage(&m_copyImg);
    }
    
    m_copyImg = cvCloneImage(curImage);
}

void ImageSource::reloadIplImage()
{
    curImage = cvCloneImage(m_copyImg);
}

Size2 ImageSource::getImageSize2()
{
    Size2 imageSize2;

    if (curImage != NULL)
    {
        imageSize2.height = curImage->height;
    	imageSize2.width = curImage->width;
    }
    else
    {
        imageSize2.height = -1;
    	imageSize2.width = -1;
    }

    return imageSize2;
}


CvSize ImageSource::getImageCvSize()
{
    CvSize imageSize2;

    if (curImage != NULL)
    {
        imageSize2.height = curImage->height;
    	imageSize2.width = curImage->width;
    }
    else
    {
        imageSize2.height = -1;
    	imageSize2.width = -1;
    }

    return imageSize2;
}



bool ImageSource::isImageAvailable()
{
	if(curImage == NULL)
    {
		return false;
    }
	else
    {
		return true;
    }
}

const char* ImageSource::getFilename(int idx)
{
	return "";
}
