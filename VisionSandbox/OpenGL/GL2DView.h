//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GLView.h"

typedef struct
{
	BOOL zoomIn;
	BOOL zoomOut;
	
	BOOL left;
	BOOL right;
	BOOL top;
	BOOL bottom;
	float speed;
} iMovement;

@interface GL2DView : GLView
{
	iMovement imageMovement;
	float Magnification;
	
	Vector2 startMousePos;
	Vector2 startImagePos;
	
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

- (void)keyDown:(NSEvent*)event;
- (void)keyUp:(NSEvent*)event;

- (void)move;

//Ensure that the user doesn't zoom, or scroll off of the image (or zoom to some insaine point where you can't see any thing):
- (void)ClampImageToScreen;
@end