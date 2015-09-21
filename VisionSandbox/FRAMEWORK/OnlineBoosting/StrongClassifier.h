#pragma once

#include "ImageRepresentation.h"
#include "BaseClassifier.h"
#include "EstimatedGaussDistribution.h"
#include <stdio.h>

class StrongClassifier  
{
public:

	StrongClassifier( int numBaseClassifier, 
		              int numWeakClassifier, 
		              Size2 patchSize2, 
					  bool useFeatureExchange = false, 
					  int iterationInit = 0);

	~StrongClassifier();

	virtual float eval(ImageRepresentation *image, Rect2 ROI);

	virtual bool update(ImageRepresentation *image, Rect2 ROI, int target, float importance = 1.0f);
	virtual bool updateSemi(ImageRepresentation *image, Rect2 ROI, float priorConfidence);

	Size2 getPatchSize2(){return patchSize2;};
	int getNumBaseClassifier(){return numBaseClassifier;};
	int getIdxOfSelectedClassifierOfBaseClassifier (int baseClassifierIdx=0){return baseClassifier[baseClassifierIdx]->getIdxOfSelectedClassifier();};
	virtual float getSumAlpha(int toBaseClassifier = -1);
	float getAlpha(int idx){return alpha[idx];};

	float getFeatureValue(ImageRepresentation *image, Rect2 ROI, int baseClassifierIdx);
	float getImportance(ImageRepresentation *image, Rect2 ROI, int traget, int numBaseClassifiers = -1);
	
	WeakClassifier** getReferenceWeakClassifier(){return baseClassifier[0]->getReferenceWeakClassifier();};

	void resetWeightDistribution();

protected:

	int numBaseClassifier;
	int numAllWeakClassifier;

	BaseClassifier** baseClassifier;
	float* alpha;
	Size2 patchSize2;
	
	bool useFeatureExchange;

};
