#include "WeakClassifier.h"

WeakClassifier::WeakClassifier()
{
}

WeakClassifier::~WeakClassifier()
{
}


bool WeakClassifier::update(ImageRepresentation* image, Rect2 ROI, int target)
{
	return true;
}

int WeakClassifier::eval(ImageRepresentation* image, Rect2  ROI)
{
	return 0;
}

int WeakClassifier::getType ()
{
	return 0;
}

float WeakClassifier::getValue (ImageRepresentation* image, Rect2  ROI)
{
	return 0;
}
