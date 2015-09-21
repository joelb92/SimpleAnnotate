#pragma once

#include "ImageRepresentation.h"

class WeakClassifier  
{

public:

	WeakClassifier();
	virtual ~WeakClassifier();

	virtual bool update(ImageRepresentation* image, Rect2 ROI, int target);

	virtual int eval(ImageRepresentation* image, Rect2 ROI);

	virtual float getValue (ImageRepresentation* image, Rect2  ROI);

	virtual int getType();

};
