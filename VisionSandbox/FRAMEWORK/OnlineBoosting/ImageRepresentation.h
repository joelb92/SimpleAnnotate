#pragma once

#include <memory.h>
#include <math.h>
#include "Regions.h"

class ImageRepresentation  
{
public:

    ImageRepresentation(unsigned char* image, Size2 imagSize2);
	ImageRepresentation(unsigned char* image, Size2 imagSize2, Rect2 imageROI);
    void defaultInit(unsigned char* image, Size2 imageSize2);
	virtual ~ImageRepresentation();

	int getSum(Rect2 imageROI);
	float getMean(Rect2 imagROI);
	unsigned int getValue(Point2D position);
	Size2 getImageSize2(void){return m_imageSize2;};
	Rect2 getImageROI(void){return m_ROI;};
	void setNewImage(unsigned char* image);
	void setNewROI(Rect2 ROI);
	void setNewImageSize2( Rect2 ROI );
	void setNewImageAndROI(unsigned char* image, Rect2 ROI);
	float getVariance(Rect2 imageROI);
	long getSqSum(Rect2 imageROI);
	bool getUseVariance(){return m_useVariance;};
	void setUseVariance(bool useVariance){ this->m_useVariance = useVariance; };


private:

	bool m_useVariance;
	void createIntegralsOfROI(unsigned char* image);

	Size2 m_imageSize2;
        __uint32_t* intImage;
        __uint64_t* intSqImage;
	Rect2 m_ROI;
	Point2D m_offset;
};
