#pragma once

#include "EstimatedGaussDistribution.h"
#include "ImageRepresentation.h"
#include <math.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

class FeatureHaar
{

public:

	FeatureHaar(Size2 patchSize2);
	virtual ~FeatureHaar();

	void getInitialDistribution(EstimatedGaussDistribution *distribution);

	bool eval(ImageRepresentation* image, Rect2 ROI, float* result);
	
	float getResponse(){return m_response;};

	int getNumAreas(){return m_numAreas;};
	int* getWeights(){return m_weights;};
	Rect2* getAreas(){return m_areas;};
	
private:

	char m_type[20];
	int m_numAreas;
	int* m_weights;
	float m_initMean;
	float m_initSigma;

	void generateRandomFeature(Size2 imageSize2);
	Rect2* m_areas;     // areas within the patch over which to compute the feature
	Size2 m_initSize2;   // size of the patch used during training
	Size2 m_curSize2;    // size of the patches currently under investigation
	float m_scaleFactorHeight;  // scaling factor in vertical direction
	float m_scaleFactorWidth;   // scaling factor in horizontal direction
	Rect2* m_scaleAreas;// areas after scaling
	float* m_scaleWeights; // weights after scaling
	float m_response;

};
