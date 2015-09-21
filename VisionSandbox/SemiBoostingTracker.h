#pragma once

#include "ImageRepresentation.h"
#include "Patches.h"
#include "StrongClassifier.h"
#include "StrongClassifierDirectSelection.h"
#include "StrongClassifierStandardSemi.h"
#include "Detector.h"

class SemiBoostingTracker
{
public:
	SemiBoostingTracker(ImageRepresentation* image, Rect2 initPatch, Rect2 validROI, int numBaseClassifier);
	virtual ~SemiBoostingTracker();

	bool track(ImageRepresentation* image, Patches* patches);

    Rect2 getTrackingROI(float searchFactor);
	float getConfidence();
	float getPriorConfidence();
    Rect2 getTrackedPatch();
	Point2D getCenter();
	
private:
	StrongClassifier* classifierOff;
	StrongClassifierStandardSemi* classifier;
	Detector* detector;
    Rect2 trackedPatch;
    Rect2 validROI;
	float confidence;
	float priorConfidence;
};
