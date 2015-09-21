#include "Patches.h"

Patches::Patches(void)
{
	this->num = 1;
	patches = new Rect2;
	ROI.height = 0;
	ROI.width = 0;
	ROI.upper = 0;
	ROI.left = 0;
}

Patches::Patches(int num)
{
	this->num = num;
	patches = new Rect2[num];
	ROI.height = 0;
	ROI.width = 0;
	ROI.upper = 0;
	ROI.left = 0;
}

Patches::~Patches(void)
{
	delete[] patches;
}

Rect2 Patches::getRect(int index)
{
	if (index >= num)
		return Rect2(-1, -1, -1, -1);
	if (index < 0) 
		return Rect2(-1, -1, -1, -1);

	return patches[index];
}

int Patches::checkOverlap(Rect2 rect)
{
	//loop over all patches and return the first found overap
	for (int curPatch = 0; curPatch< num; curPatch++)
	{
		Rect2 curRect = getRect (curPatch);
		int overlap = curRect.checkOverlap(rect);
		if (overlap > 0)
			return overlap;
	}
	return 0;
}


bool Patches::isDetection (Rect2 eval, unsigned char *labeledImg, int imgWidth)
{
    bool isDet = false;
    Rect2 curRect;
    
	for (int curPatch = 0; curPatch < num; curPatch++)
	{
        curRect = getRect (curPatch);
		isDet = curRect.isDetection(eval, labeledImg, imgWidth);

        if (isDet)
        {
            break;
        }
	}

	return isDet;
}

Rect2 Patches::getSpecialRect (const char* what)
{
	Rect2 r;
	r.height = -1;
	r.width = -1;
	r.upper = -1;
	r.left = -1;
	return r;
}

Rect2 Patches::getSpecialRect (const char* what, Size2 patchSize2)
{
	Rect2 r;
	r.height = -1;
	r.width = -1;
	r.upper = -1;
	r.left = -1;
	return r;
}

Rect2 Patches::getROI()
{
	return ROI;
}

void Patches::setCheckedROI(Rect2 imageROI, Rect2 validROI)
{
	int dCol, dRow;
	dCol = imageROI.left - validROI.left;
	dRow = imageROI.upper - validROI.upper;
	ROI.upper = (dRow < 0) ? validROI.upper : imageROI.upper;
	ROI.left = (dCol < 0) ? validROI.left : imageROI.left;
	dCol = imageROI.left+imageROI.width - (validROI.left+validROI.width);
	dRow = imageROI.upper+imageROI.height - (validROI.upper+validROI.height);
	ROI.height = (dRow > 0) ? validROI.height+validROI.upper-ROI.upper : imageROI.height+imageROI.upper-ROI.upper; 
	ROI.width = (dCol > 0) ? validROI.width+validROI.left-ROI.left : imageROI.width+imageROI.left-ROI.left; 
}


//-----------------------------------------------------------------------------
PatchesRegularScan::PatchesRegularScan(Rect2 imageROI, Size2 patchSize2, float relOverlap)
{
	calculatePatches (imageROI, imageROI, patchSize2, relOverlap);
}

PatchesRegularScan::PatchesRegularScan (Rect2 imageROI, Rect2 validROI, Size2 patchSize2, float relOverlap)
{
	calculatePatches (imageROI, validROI, patchSize2, relOverlap);
}

void PatchesRegularScan::calculatePatches(Rect2 imageROI, Rect2 validROI, Size2 patchSize2, float relOverlap)
{
	if ((validROI == imageROI))
		ROI = imageROI;
	else
		setCheckedROI(imageROI, validROI);
	
	int stepCol = floor((1-relOverlap) * patchSize2.width+0.5);
	int stepRow = floor((1-relOverlap) * patchSize2.height+0.5);
	if (stepCol <= 0) stepCol = 1;
	if (stepRow <= 0) stepRow = 1;
	
	m_patchGrid.height = ((int)((float)(ROI.height-patchSize2.height)/stepRow)+1);
	m_patchGrid.width = ((int)((float)(ROI.width-patchSize2.width)/stepCol)+1);

	num = m_patchGrid.width * m_patchGrid.height;
	patches = new Rect2[num];
	int curPatch = 0;

	m_rectUpperLeft = m_rectUpperRight = m_rectLowerLeft = m_rectLowerRight = patchSize2;
	m_rectUpperLeft.upper = ROI.upper;
	m_rectUpperLeft.left = ROI.left;
	m_rectUpperRight.upper = ROI.upper;
	m_rectUpperRight.left = ROI.left+ROI.width-patchSize2.width;
	m_rectLowerLeft.upper = ROI.upper+ROI.height-patchSize2.height;
	m_rectLowerLeft.left = ROI.left;
	m_rectLowerRight.upper = ROI.upper+ROI.height-patchSize2.height;
	m_rectLowerRight.left = ROI.left+ROI.width-patchSize2.width;


	numPatchesX=0; numPatchesY=0;
	for (int curRow=0; curRow< ROI.height-patchSize2.height+1; curRow+=stepRow)
	{
		numPatchesY++;

		for (int curCol=0; curCol< ROI.width-patchSize2.width+1; curCol+=stepCol)
		{
			if(curRow == 0)
				numPatchesX++;

			patches[curPatch].width = patchSize2.width;
			patches[curPatch].height = patchSize2.height;
			patches[curPatch].upper = curRow+ROI.upper;
			patches[curPatch].left = curCol+ROI.left;
			curPatch++;
		}
	}

	assert (curPatch==num);
}

PatchesRegularScan::~PatchesRegularScan(void)
{
}

Rect2 PatchesRegularScan::getSpecialRect(const char* what, Size2 patchSize2)
{
	Rect2 r;
	r.height = -1;
	r.width = -1;
	r.upper = -1;
	r.left = -1;
	return r;
}

Rect2 PatchesRegularScan::getSpecialRect(const char* what)
{
	if (strcmp(what, "UpperLeft")==0) return m_rectUpperLeft;
	if (strcmp(what, "UpperRight")==0) return m_rectUpperRight;
	if (strcmp(what, "LowerLeft")==0) return m_rectLowerLeft;
	if (strcmp(what, "LowerRight")==0) return m_rectLowerRight;
	if (strcmp(what, "Random")==0)
	{
		int index = (rand()%(num));
		return patches[index];
	}

	// assert (false);
	return Rect2(-1, -1, -1, -1); // fixed
}

//-----------------------------------------------------------------------------
PatchesRegularScaleScan::PatchesRegularScaleScan (Rect2 imageROI, Size2 patchSize2, float relOverlap, float scaleStart, float scaleEnd, float scaleFactor)
{
	calculatePatches (imageROI, imageROI, patchSize2, relOverlap, scaleStart, scaleEnd, scaleFactor);
}

PatchesRegularScaleScan::PatchesRegularScaleScan (Rect2 imageROI, Rect2 validROI, Size2 patchSize2, float relOverlap, float scaleStart, float scaleEnd, float scaleFactor)
{
	calculatePatches (imageROI, validROI, patchSize2, relOverlap, scaleStart, scaleEnd, scaleFactor);
}

PatchesRegularScaleScan::~PatchesRegularScaleScan(void)
{

}


void PatchesRegularScaleScan::calculatePatches(Rect2 imageROI, Rect2 validROI, Size2 patchSize2, float relOverlap, float scaleStart, float scaleEnd, float scaleFactor)
{

	if ((validROI == imageROI))
		ROI = imageROI;
	else
		setCheckedROI(imageROI, validROI);

	int numScales = (int)(log(scaleEnd/scaleStart)/log(scaleFactor));
	if (numScales < 0) numScales = 0;
	float curScaleFactor = 1;
	Size2 curPatchSize2;
	int stepCol, stepRow;

	num = 0;
	for (int curScale = 0; curScale <= numScales; curScale++)
	{   
		curPatchSize2 = patchSize2 * (scaleStart*curScaleFactor);
		if (curPatchSize2.height > ROI.height || curPatchSize2.width > ROI.width)
		{
			numScales = curScale-1;
			break;
		}
		curScaleFactor *= scaleFactor;
					
		stepCol = floor((1-relOverlap) * curPatchSize2.width+0.5);
		stepRow = floor((1-relOverlap) * curPatchSize2.height+0.5);
		if (stepCol <= 0) stepCol = 1;
		if (stepRow <= 0) stepRow = 1;
	
		num += ((int)((float)(ROI.width-curPatchSize2.width)/stepCol)+1)*((int)((float)(ROI.height-curPatchSize2.height)/stepRow)+1);
	}
	patches = new Rect2[num];
	    
	int curPatch = 0;
	curScaleFactor = 1;
	for (int curScale = 0; curScale <= numScales; curScale++)
	{   
		curPatchSize2 = patchSize2 * (scaleStart*curScaleFactor);
		curScaleFactor *= scaleFactor;
			
		stepCol = floor((1-relOverlap) * curPatchSize2.width+0.5);
		stepRow = floor((1-relOverlap) * curPatchSize2.height+0.5);
		if (stepCol <= 0) stepCol = 1;
		if (stepRow <= 0) stepRow = 1;
	

		
		
		for (int curRow=0; curRow< ROI.height-curPatchSize2.height+1; curRow+=stepRow)
		{
			for (int curCol=0; curCol<ROI.width-curPatchSize2.width+1; curCol+=stepCol)
			{
				patches[curPatch].width = curPatchSize2.width;
				patches[curPatch].height = curPatchSize2.height;
				patches[curPatch].upper = curRow+ROI.upper;
				patches[curPatch].left = curCol+ROI.left;

				curPatch++;
			}
		}
	}
	assert (curPatch==num);

}

Rect2 PatchesRegularScaleScan::getSpecialRect (const char* what)
{
	
	if (strcmp(what, "Random")==0)
	{
		int index = (rand()%(num));
		return patches[index];
	}

	Rect2 r;
	r.height = -1;
	r.width = -1;
	r.upper = -1;
	r.left = -1;
	return r;
}
Rect2 PatchesRegularScaleScan::getSpecialRect (const char* what, Size2 patchSize2)
{		
	if (strcmp(what, "UpperLeft")==0)
	{
		Rect2 rectUpperLeft;
		rectUpperLeft =  patchSize2;
		rectUpperLeft.upper = ROI.upper;
		rectUpperLeft.left = ROI.left;
		return rectUpperLeft;
	}
	if (strcmp(what, "UpperRight")==0) 
	{
		Rect2 rectUpperRight;
		rectUpperRight = patchSize2;
		rectUpperRight.upper = ROI.upper;
		rectUpperRight.left = ROI.left+ROI.width-patchSize2.width;
		return rectUpperRight;
	}
	if (strcmp(what, "LowerLeft")==0)
	{
		Rect2 rectLowerLeft;
		rectLowerLeft = patchSize2;
		rectLowerLeft.upper = ROI.upper+ROI.height-patchSize2.height;
		rectLowerLeft.left = ROI.left;
		return rectLowerLeft;
	}
	if (strcmp(what, "LowerRight")==0)
	{
		Rect2 rectLowerRight;
		rectLowerRight = patchSize2;
		rectLowerRight.upper = ROI.upper+ROI.height-patchSize2.height;
		rectLowerRight.left = ROI.left+ROI.width-patchSize2.width;
		return rectLowerRight;
	}
	if (strcmp(what, "Random")==0)
	{
		int index = (rand()%(num));
		return patches[index];
	}

	return Rect2(-1, -1, -1, -1);
}