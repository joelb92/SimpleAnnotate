//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLView.h"
#import "trackball.h"
#import "Vector3.h"
typedef struct
{
	BOOL zoomIn;
	BOOL zoomOut;
	
	BOOL left;
	BOOL right;
	BOOL top;
	BOOL bottom;
	float speed;
	float rotationAboutLookAtPosition [4] = {0,0,0,0};
	Vector3 xPanDirection = Vector3();
	Vector3 yPanDirection = Vector3();
	
	BOOL dolly = false;
	BOOL pan = false;
	BOOL trackball = false;
} cMovement;

typedef struct
{
	Vector3 lookAtPosition = Vector3(0,0,0);
	float rotationAboutLookAtPosition [4] = {0,0,0,0};
	Vector3 translationFromLookAtPosition = Vector3(0,0,0);
} CameraPosition;
@interface GL3DView : GLView
{
	cMovement cameraMovement;
	CameraPosition cameraPosition;
	
	int FlasherDirection;
	float FlasherCyclesPerSecond;
	NSDate*FlasherDate;
}
- (void)setMaxImageSpaceRect:(vector2Rect)maxImageSpaceRect;

//////////////////////////////////////////////////////////////////////////////////////////////////
//																								//
//																								//
//									    Event Handling											//
//																								//
//																								//
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)UpdateFlasherValue;

- (void)mouseDown:(NSEvent*)event;
- (void)mouseMoved:(NSEvent*)event;
- (void)mouseDragged:(NSEvent*)event;
- (void)mouseUp:(NSEvent*)event;

- (void)scrollWheel:(NSEvent*)event;

//Pinch Gesture:
- (void)magnifyWithEvent:(NSEvent*)event;

- (void)move;
@end
