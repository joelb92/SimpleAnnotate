//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#include "vector2Rect.h"
#include "GLUT/glut.h"
#include "Ray3.h"

#ifndef SpaceConverter_H_
#define SpaceConverter_H_

typedef enum
{
	_2d,
	_3d
}SpaceType;

class SpaceConverter
{
public:
	//Components
	float frustrumScale;
	float screenAspectRatio;
	vector2Rect ImageRect;
	Vector2 imagePos;
	NSSize screenSize;
	float FlasherValue;
	SpaceType type;
	
	float NearClip;
	float FarClip;
	float FieldOfView;
	
	GLint viewport[4];
	GLdouble modelview[16];
	GLdouble projection[16];
	
	//Constructors
	SpaceConverter();
	
	//Functions
	//Camera To ___ Convershions:
	Vector2 CameraToImageVector(Vector2 point);
	Vector2 CameraToPercentVector(Vector2 point);
	Vector2 CameraToScreenVector(Vector2 point);
	
	//Image To ___ Convershions:
	Vector2 ImageToCameraVector(Vector2 point);
	Vector2 ImageToPercentVector(Vector2 point);
	Vector2 ImageToScreenVector(Vector2 point);
	
	//Percent To ___ Convershions:
	Vector2 PercentToCameraVector(Vector2 point);
	Vector2 PercentToImageVector(Vector2 point);
	Vector2 PercentToScreenVector(Vector2 point);
	
	//Screen To ___ Convershions:
	Vector2 ScreenToCameraVector(Vector2 point);
	Vector2 ScreenToImageVector(Vector2 point);
	Vector2 ScreenToPercentVector(Vector2 point);
	
	void GetMatrixes();
	Ray3 RayFromScreenPoint(Vector2 screenPoint);
	//Operator Overflows:
	//bool operator== (SpaceConverter spaceConverter);
};

#endif