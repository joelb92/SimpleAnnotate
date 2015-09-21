#pragma once

#include "ImageRepresentation.h"
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

class Patches
{
public:

	Patches();
	Patches(int num);
	virtual ~Patches(void);

	virtual Rect2 getRect(int index);
	virtual Rect2 getSpecialRect(const char* what);
	virtual Rect2 getSpecialRect(const char* what, Size2 patchSize2);

	virtual Rect2 getROI();
	virtual int getNum(void){return num;};

	int checkOverlap(Rect2 rect);
	
    virtual bool isDetection(Rect2 eval, unsigned char *labeledImg, int imgWidth);
	virtual int getNumPatchesX(){return numPatchesX;}; 
	virtual int getNumPatchesY(){return numPatchesY;};

protected:

	void setCheckedROI(Rect2 imageROI, Rect2 validROI);

	Rect2* patches;
	int num;
	Rect2 ROI;
	int numPatchesX; 
	int numPatchesY;
};

class PatchesRegularScan : public Patches
{
public:

	PatchesRegularScan(Rect2 imageROI, Size2 patchSize2, float relOverlap);
	PatchesRegularScan(Rect2 imageROI, Rect2 validROI, Size2 patchSize2, float relOverlap);
	virtual ~PatchesRegularScan (void);

	Rect2 getSpecialRect(const char* what);
	Rect2 getSpecialRect(const char* what, Size2 patchSize2);
	Size2 getPatchGrid(){return m_patchGrid;};

private:

	void calculatePatches(Rect2 imageROI, Rect2 validROI, Size2 patchSize2, float relOverlap);

	Rect2 m_rectUpperLeft;
	Rect2 m_rectUpperRight;
	Rect2 m_rectLowerLeft;
	Rect2 m_rectLowerRight;
	Size2 m_patchGrid;

};

class PatchesRegularScaleScan : public Patches
{
public:

	PatchesRegularScaleScan (Rect2 imageROI, Size2 patchSize2, float relOverlap, float scaleStart, float scaleEnd, float scaleFactor);
	PatchesRegularScaleScan (Rect2 imageROI, Rect2 validROI, Size2 patchSize2, float relOverlap, float scaleStart, float scaleEnd, float scaleFactor);
	virtual ~PatchesRegularScaleScan();

	Rect2 getSpecialRect (const char* what);
	Rect2 getSpecialRect (const char* what, Size2 patchSize2);
	
private:

	void calculatePatches (Rect2 imageROI, Rect2 validROI, Size2 patchSize2, float relOverlap, float scaleStart, float scaleEnd, float scaleFactor);

};

class PatchesFunctionScaleScan : public Patches
{
public:
	
	typedef float (*GetScale)(int, int);

	PatchesFunctionScaleScan (Rect2 imageROI, Size2 patchSize2, float relOverlap, GetScale getScale);
	PatchesFunctionScaleScan (Rect2 imageROI, Rect2 validROI, Size2 PatchSize2, float relOverlap, GetScale getScale);
	PatchesFunctionScaleScan (Rect2 imageROI, Size2 patchSize2, float relOverlap, float coefY, float coef1, float minScaleFactor=1.0f);
	PatchesFunctionScaleScan (Rect2 imageROI, Rect2 validROI, Size2 patchSize2, float relOverlap, float coefY, float coef1, float minScaleFactor = 1.0f);
	virtual ~PatchesFunctionScaleScan();

	Rect2 getSpecialRect (const char* what);
	Rect2 getSpecialRect (const char* what, Size2 patchSize2);
	
private:

	void calculatePatches (Rect2 imageROI, Rect2 validROI, Size2 patchSize2, float relOverlap, GetScale getScale);
	void calculatePatches (Rect2 imageROI, Rect2 validROI, Size2 patchSize2, float relOverlap, float coefY, float coef1, float minScaleFactor);

	Rect2 rectUpperLeft;
	Rect2 rectUpperRight;
	Rect2 rectLowerLeft;
	Rect2 rectLowerRight;
};

class PatchesManualSet : public Patches
{
public:

	PatchesManualSet(int numPatches, Rect2* patches);
	PatchesManualSet(int numPatches, Rect2* patches, Rect2 ROI);
	virtual ~PatchesManualSet (void);

	Rect2 getSpecialRect (const char* what){return Rect2(-1,-1,-1,-1);} ;
	Rect2 getSpecialRect (const char* what, Size2 patchSize2){return Rect2(-1,-1,-1,-1);};

private:


};
