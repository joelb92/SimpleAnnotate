#include "SemiBoostingTracker.h"


SemiBoostingTracker::SemiBoostingTracker(ImageRepresentation* image, Rect2 initPatch, Rect2 validROI, int numBaseClassifier)
{
	int numWeakClassifier = 100;
	bool useFeatureExchange = true;
	int iterationInit = 50;
	Size2 patchSize2;
	patchSize2 = initPatch;

	this->validROI = validROI;

//	classifierOff = new StrongClassifierDicv::RectSelection(numBaseClassifier, numBaseClassifier*10, patchSize2, useFeatureExchange, iterationInit);
	classifierOff = new StrongClassifierStandardSemi(numBaseClassifier, numWeakClassifier, patchSize2, useFeatureExchange, iterationInit);
	classifier = new StrongClassifierStandardSemi(numBaseClassifier, numWeakClassifier, patchSize2, useFeatureExchange, iterationInit);  

	detector = new Detector (classifier);

	trackedPatch = initPatch;
	Rect2 trackingROI = getTrackingROI(2.0f);
	Size2 trackedPatchSize2;
	trackedPatchSize2 = trackedPatch;
	Patches* trackingPatches = new PatchesRegularScan(trackingROI, validROI, trackedPatchSize2, 0.99f);

	iterationInit = 50;
	for (int curInitStep = 0; curInitStep < iterationInit; curInitStep++)
	{
		printf ("\rinit tracker... %3.0f %% ", ((float)curInitStep)/(iterationInit-1)*100);	
		classifier->updateSemi (image, trackingPatches->getSpecialRect ("UpperLeft"), -1);
		classifier->updateSemi (image, trackedPatch, 1);
		classifier->updateSemi (image, trackingPatches->getSpecialRect ("UpperRight"), -1);
		classifier->updateSemi (image, trackedPatch, 1);
		classifier->updateSemi (image, trackingPatches->getSpecialRect ("LowerLeft"), -1);
		classifier->updateSemi (image, trackedPatch, 1);
		classifier->updateSemi (image, trackingPatches->getSpecialRect ("LowerRight"), -1);
		classifier->updateSemi (image, trackedPatch, 1);
	}
	printf (" done.\n");
	
	//one (first) shot learning
	iterationInit = 50;
	for (int curInitStep = 0; curInitStep < iterationInit; curInitStep++)
	{
		printf ("\rinit detector... %3.0f %% ", ((float)curInitStep)/(iterationInit-1)*100);
		
		classifierOff->updateSemi (image, trackedPatch, 1);
		classifierOff->updateSemi (image, trackingPatches->getSpecialRect ("UpperLeft"), -1);
		classifierOff->updateSemi (image, trackedPatch, 1);
		classifierOff->updateSemi (image, trackingPatches->getSpecialRect ("UpperRight"), -1);
		classifierOff->updateSemi (image, trackedPatch, 1);
		classifierOff->updateSemi (image, trackingPatches->getSpecialRect ("LowerLeft"), -1);
		classifierOff->updateSemi (image, trackedPatch, 1);
		classifierOff->updateSemi (image, trackingPatches->getSpecialRect ("LowerRight"), -1);
	}

	delete trackingPatches;
	
	confidence = -1;
	priorConfidence = -1;
	
}

SemiBoostingTracker::~SemiBoostingTracker(void)
{
	delete detector;
	delete classifier;
}

bool SemiBoostingTracker::track(ImageRepresentation* image, Patches* patches)
{
	//detector->classify(image, patches);
	detector->classifySmooth(image, patches);

	//move to best detection
	if (detector->getNumDetections() <=0 )
	{
		confidence = 0;
		priorConfidence = 0;
		return false;
	}

	trackedPatch = patches->getRect (detector->getPatchIdxOfBestDetection ());
	confidence = detector->getConfidenceOfBestDetection ();

	float off;

	//updates
	/*int numUpdates = 10;
	cv::Rect tmp;
	for (int curUpdate = 0; curUpdate < numUpdates; curUpdate++)
	{
		tmp = patches->getSpecialRect ("Random");
		off = classifierOff->eval(image, tmp)/classifierOff->getSumAlpha();
		classifier->updateSemi (image, tmp, off);
	
		priorConfidence = classifierOff->eval(image, trackedPatch)/classifierOff->getSumAlpha();
		classifier->updateSemi (image, trackedPatch, priorConfidence);

	}*/

	Rect2 tmp = patches->getSpecialRect ("UpperLeft");
	off = classifierOff->eval(image, tmp)/classifierOff->getSumAlpha();
	classifier->updateSemi (image, tmp, off);
		
	priorConfidence = classifierOff->eval(image, trackedPatch)/classifierOff->getSumAlpha();
	classifier->updateSemi (image, trackedPatch, priorConfidence);

	tmp = patches->getSpecialRect ("LowerLeft");
	off = classifierOff->eval(image, tmp)/classifierOff->getSumAlpha();
	classifier->updateSemi (image, tmp, off);
		
	priorConfidence = classifierOff->eval(image, trackedPatch)/classifierOff->getSumAlpha();
	classifier->updateSemi (image, trackedPatch, priorConfidence);

	tmp = patches->getSpecialRect ("UpperRight");
	off = classifierOff->eval(image, tmp)/classifierOff->getSumAlpha();
	classifier->updateSemi (image, tmp, off);	

	priorConfidence = classifierOff->eval(image, trackedPatch)/classifierOff->getSumAlpha();
	classifier->updateSemi (image, trackedPatch, priorConfidence);
	
	tmp = patches->getSpecialRect ("LowerRight");
	off = classifierOff->eval(image, tmp)/classifierOff->getSumAlpha();
	classifier->updateSemi (image, tmp, off);

	priorConfidence = classifierOff->eval(image, trackedPatch)/classifierOff->getSumAlpha();
	classifier->updateSemi (image, trackedPatch, priorConfidence);
		
	return true;
}

Rect2 SemiBoostingTracker::getTrackingROI(float searchFactor)
{
	Rect2 searchRegion;
	
	searchRegion = trackedPatch*(searchFactor);
	//check
	if (searchRegion.upper+searchRegion.height > validROI.height)
		searchRegion.height = validROI.height-searchRegion.upper;
	if (searchRegion.left+searchRegion.width > validROI.width)
		searchRegion.width = validROI.width-searchRegion.left;

	return searchRegion;
}

float SemiBoostingTracker::getConfidence()
{
	return confidence/classifier->getSumAlpha();
}

float SemiBoostingTracker::getPriorConfidence()
{
	return priorConfidence;
}

Rect2 SemiBoostingTracker::getTrackedPatch()
{
	return trackedPatch;
}

Point2D SemiBoostingTracker::getCenter()
{
	Point2D center;
	center.row = trackedPatch.upper + trackedPatch.height/2 ;
	center.col = trackedPatch.left +trackedPatch.width/2 ;
	return center;
}
