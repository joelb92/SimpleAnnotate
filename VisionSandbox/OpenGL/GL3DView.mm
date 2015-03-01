//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GL3DView.h"

@implementation GL3DView

- (void)setMaxImageSpaceRect:(vector2Rect)maxImageSpaceRect
{
	if(maxImageSpaceRect != spaceConverter.ImageRect)
	{
		spaceConverter.ImageRect = maxImageSpaceRect;
		MustReshape = true;
	}
}

//Set some intitial values and start the idle (60 FPS):
- (void)prepareOpenGL
{
	spaceConverter.type = _3d;
	FlasherCyclesPerSecond = 1.5;
	[super prepareOpenGL];
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LESS);
}

//Create a camera and viewport that supports the image and view size:
- (void)reshape
{
	[self.openGLContext makeCurrentContext];
	MustReshape = false;
	
	spaceConverter.screenSize = self.frame.size;
	spaceConverter.screenAspectRatio = spaceConverter.screenSize.width/spaceConverter.screenSize.height;
	
	glViewport(0, 0, (GLsizei)spaceConverter.screenSize.width, (GLsizei)spaceConverter.screenSize.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(spaceConverter.FieldOfView, spaceConverter.screenAspectRatio, spaceConverter.NearClip, spaceConverter.FarClip);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	GLfloat lightpos[] = {0, 5, 0, 1.0};
	glLightfv(GL_LIGHT0, GL_POSITION, lightpos);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//																								//
//																								//
//									Main Drawing Methodes										//
//																								//
//																								//
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadModelMatrix
{
	glTranslatef(cameraPosition.translationFromLookAtPosition.x, cameraPosition.translationFromLookAtPosition.y, cameraPosition.translationFromLookAtPosition.z);
	if(cameraMovement.rotationAboutLookAtPosition[0] != 0.0f) glRotatef(cameraMovement.rotationAboutLookAtPosition[0], cameraMovement.rotationAboutLookAtPosition[1], cameraMovement.rotationAboutLookAtPosition[2], cameraMovement.rotationAboutLookAtPosition[3]);
	glRotatef(cameraPosition.rotationAboutLookAtPosition[0], cameraPosition.rotationAboutLookAtPosition[1], cameraPosition.rotationAboutLookAtPosition[2], cameraPosition.rotationAboutLookAtPosition[3]);
	glTranslatef(cameraPosition.lookAtPosition.x, cameraPosition.lookAtPosition.y, cameraPosition.lookAtPosition.z);
}
- (void)drawRect:(NSRect)dirtyRect
{
	NSAutoreleasePool*pool = [[NSAutoreleasePool alloc] init];
	[self.openGLContext makeCurrentContext];
	[self UpdateFlasherValue];
	if(backgroundColor)
	{
		[backgroundColor release];
		backgroundColor = nil;
	}
	backgroundColor = [((Color)Black).AsNSColor() retain];
	[super drawRect:dirtyRect];
	[self move];
	[pool drain];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//																								//
//																								//
//									    Event Handling											//
//																								//
//																								//
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)UpdateFlasherValue
{
	NSDate*now = [NSDate date];
	spaceConverter.FlasherValue += [now timeIntervalSinceDate:FlasherDate]*FlasherCyclesPerSecond*2*FlasherDirection;
	[FlasherDate release];
	FlasherDate = [now retain];
	
	if(spaceConverter.FlasherValue>1)
	{
		FlasherDirection = -1;
		spaceConverter.FlasherValue = 1;
	}
	if(spaceConverter.FlasherValue<0)
	{
		FlasherDirection = 1;
		spaceConverter.FlasherValue = 0;
	}
}


- (void)mouseMoved:(NSEvent*)event
{
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	previousMouseLocation.x = location.x;
	previousMouseLocation.y = location.y;
	
	[super mouseMoved:event];
}

- (void)mouseDown:(NSEvent*)theEvent // trackball
{
    if([theEvent modifierFlags] & NSControlKeyMask) // send to pan
	{
		[self rightMouseDown:theEvent];
	}
	else if([theEvent modifierFlags] & NSAlternateKeyMask) // send to dolly
	{
		[self otherMouseDown:theEvent];
	}
	else
	{
		[super mouseDown:theEvent];
		
		cameraMovement.dolly = false;
		cameraMovement.pan = false;
		cameraMovement.trackball = true;
		startTrackball(mousePosition.x, mousePosition.y, 0, 0, spaceConverter.screenSize.width, spaceConverter.screenSize.height);
	}
}

- (void)rightMouseDown:(NSEvent*)event // pan
{
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	//location.y = spaceConverter.screenSize.height - location.y;
	if(cameraMovement.trackball)
	{
		if(cameraMovement.rotationAboutLookAtPosition[0] != 0.0)
		{
			addToRotationTrackball(cameraMovement.rotationAboutLookAtPosition, cameraPosition.rotationAboutLookAtPosition);
		}
		cameraMovement.rotationAboutLookAtPosition[0] = 0;
		cameraMovement.rotationAboutLookAtPosition[1] = 0;
		cameraMovement.rotationAboutLookAtPosition[2] = 0;
		cameraMovement.rotationAboutLookAtPosition[3] = 0;
	}
	cameraMovement.dolly = false;
	cameraMovement.pan = true;
	cameraMovement.trackball = false;
	previousMouseLocation.x = location.x;
	previousMouseLocation.y = location.y;
	
	GLKVector3 temp;
	GLKQuaternion rotation = GLKQuaternionMakeWithAngleAndAxis(-cameraPosition.rotationAboutLookAtPosition[0]*M_PI/180.0,
															   cameraPosition.rotationAboutLookAtPosition[1],
															   cameraPosition.rotationAboutLookAtPosition[2],
															   cameraPosition.rotationAboutLookAtPosition[3]);
	temp = GLKVector3Make(1, 0, 0);
	temp = GLKQuaternionRotateVector3(rotation, temp);
	cameraMovement.xPanDirection = Vector3(temp.x,temp.y,temp.z);
	temp = GLKVector3Make(0, 1, 0);
	temp = GLKQuaternionRotateVector3(rotation, temp);
	cameraMovement.yPanDirection = Vector3(temp.x,temp.y,temp.z);
}

- (void)otherMouseDown:(NSEvent*)event //dolly
{
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	//location.y = spaceConverter.screenSize.height - location.y;
	if(cameraMovement.trackball)
	{
		if(cameraMovement.rotationAboutLookAtPosition[0] != 0.0)
			addToRotationTrackball(cameraMovement.rotationAboutLookAtPosition, cameraPosition.rotationAboutLookAtPosition);
		cameraMovement.rotationAboutLookAtPosition[0] = 0;
		cameraMovement.rotationAboutLookAtPosition[1] = 0;
		cameraMovement.rotationAboutLookAtPosition[2] = 0;
		cameraMovement.rotationAboutLookAtPosition[3] = 0;
	}
	cameraMovement.dolly = true;
	cameraMovement.pan = false;
	cameraMovement.trackball = false;
	
	previousMouseLocation.x = location.x;
	previousMouseLocation.y = location.y;
}

- (void)mouseDragged:(NSEvent*)event
{
	if(!mouseOverController || !mouseOverController.tool.dragging || ![mouseOverController.superview isEqual:self])
	{
		NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
		//location.y = spaceConverter.screenSize.height - location.y;
		if(cameraMovement.trackball)
		{
			[super mouseDragged:event];
			rollToTrackball(mousePosition.x, mousePosition.y, cameraMovement.rotationAboutLookAtPosition);
		}
		else if(cameraMovement.dolly)
		{
			[self mouseDolly:location];
		}
		else if(cameraMovement.pan)
		{
			[self mousePan:location];
		}
	}
}

// move camera in z axis
- (void)mouseDolly:(NSPoint)location
{
	cameraPosition.translationFromLookAtPosition.z += (location.y-previousMouseLocation.y)*cameraMovement.speed;
	previousMouseLocation.x = location.x;
	previousMouseLocation.y = location.y;
	if(-cameraPosition.translationFromLookAtPosition.z < spaceConverter.NearClip)
		cameraPosition.translationFromLookAtPosition.z = -spaceConverter.NearClip;
	if(-cameraPosition.translationFromLookAtPosition.z > spaceConverter.FarClip)
		cameraPosition.translationFromLookAtPosition.z = -spaceConverter.FarClip;
}

// move camera in x/y plane
- (void)mousePan:(NSPoint)location
{
	Vector2 mouseDelta = Vector2(location.x, location.y) - previousMouseLocation;
	cameraPosition.lookAtPosition = cameraPosition.lookAtPosition + cameraMovement.xPanDirection*mouseDelta.x*cameraMovement.speed + cameraMovement.yPanDirection*mouseDelta.y*cameraMovement.speed;
	previousMouseLocation.x = location.x;
	previousMouseLocation.y = location.y;
}

- (void)mouseUp:(NSEvent*)theEvent
{
	if(cameraMovement.dolly)
	{
		cameraMovement.dolly = false;
	}
	else if(cameraMovement.pan)
	{
		cameraMovement.pan = false;
	}
	else if(cameraMovement.trackball)
	{
		cameraMovement.trackball = false;
		if (cameraMovement.rotationAboutLookAtPosition[0] != 0.0)
		{
			addToRotationTrackball(cameraMovement.rotationAboutLookAtPosition, cameraPosition.rotationAboutLookAtPosition);
		}
		cameraMovement.rotationAboutLookAtPosition[0] = 0;
		cameraMovement.rotationAboutLookAtPosition[1] = 0;
		cameraMovement.rotationAboutLookAtPosition[2] = 0;
		cameraMovement.rotationAboutLookAtPosition[3] = 0;
	}
	[super mouseUp:theEvent];
}

- (void)scrollWheel:(NSEvent*)event
{
	cameraPosition.translationFromLookAtPosition.z += [event deltaY]*cameraMovement.speed;
	if(-cameraPosition.translationFromLookAtPosition.z < spaceConverter.NearClip)
		cameraPosition.translationFromLookAtPosition.z = -spaceConverter.NearClip;
	if(-cameraPosition.translationFromLookAtPosition.z > spaceConverter.FarClip)
		cameraPosition.translationFromLookAtPosition.z = -spaceConverter.FarClip;
}

//Pinch Gesture:
- (void)magnifyWithEvent:(NSEvent*)event
{
	spaceConverter.FieldOfView -= event.magnification*spaceConverter.FieldOfView*cameraMovement.speed;
	if(spaceConverter.FieldOfView < 0.1) spaceConverter.FieldOfView = 0.1;
	if(spaceConverter.FieldOfView > 179.9) spaceConverter.FieldOfView = 179.9;
	[self reshape];
}

- (void)keyDown:(NSEvent*)event
{
    NSString *characters = [event characters];
    if([characters length])
	{
        unichar character = [characters characterAtIndex:0];
		switch (character)
		{
				
		}
	}
}



- (void)rightMouseDragged:(NSEvent*)theEvent
{
	[self mouseDragged: theEvent];
}
- (void)otherMouseDragged:(NSEvent*)theEvent
{
	[self mouseDragged: theEvent];
}
- (void)rightMouseUp:(NSEvent*)theEvent
{
	[self mouseUp:theEvent];
}
- (void)otherMouseUp:(NSEvent*)theEvent
{
	[self mouseUp:theEvent];
}




















//- (void)keyDown:(NSEvent*)event
//{
//	switch ([event keyCode])
//	{
//		case 13:	//w
//			cameraMovement.zoomIn = YES;
//			break;
//		case 1:		//s
//			cameraMovement.zoomOut = YES;
//			break;
//		case 123:	//left
//			cameraMovement.left = YES;
//			break;
//		case 124:	//right
//			cameraMovement.right = YES;
//			break;
//		case 125:	//down
//			cameraMovement.bottom = YES;
//			break;
//		case 126:	//up
//			cameraMovement.top = YES;
//			break;
//	}
//}
//- (void)keyUp:(NSEvent*)event
//{
//	switch ([event keyCode])
//	{
//		case 13:	//w
//			cameraMovement.zoomIn = NO;
//			break;
//		case 1:		//s
//			cameraMovement.zoomOut = NO;
//			break;
//		case 123:	//left
//			cameraMovement.left = NO;
//			break;
//		case 124:	//right
//			cameraMovement.right = NO;
//			break;
//		case 125:	//down
//			cameraMovement.bottom = NO;
//			break;
//		case 126:	//up
//			cameraMovement.top = NO;
//			break;
//	}
//}

- (void)ZoomIn
{
    spaceConverter.FieldOfView +=.3*spaceConverter.FieldOfView;
    [self reshape];
}
- (void)ZoomOut
{
    spaceConverter.FieldOfView -=.3*spaceConverter.FieldOfView;
    [self reshape];
}

- (void)move
{
	if(cameraMovement.zoomIn)
	{
		spaceConverter.FieldOfView = spaceConverter.FieldOfView+.1*spaceConverter.FieldOfView;
		if(spaceConverter.FieldOfView<1) spaceConverter.FieldOfView = 1;
		[self reshape];
	}
	if(cameraMovement.zoomOut)
	{
		spaceConverter.FieldOfView = spaceConverter.FieldOfView-.1*spaceConverter.FieldOfView;
		if(spaceConverter.FieldOfView<1) spaceConverter.FieldOfView = 1;
		[self reshape];
	}
}

//Reset all the viewing values:
- (void)Reset
{
	spaceConverter.NearClip = 1.0;
	spaceConverter.FarClip = 2000.0;
	spaceConverter.FieldOfView = 60;
	
	cameraMovement.left = NO;
	cameraMovement.right = NO;
	cameraMovement.top = NO;
	cameraMovement.bottom = NO;
	cameraMovement.speed = 0.1f;
	
	cameraMovement.zoomIn = NO;
	cameraMovement.zoomOut = NO;
	
	cameraMovement.rotationAboutLookAtPosition[0] = 0;
	cameraMovement.rotationAboutLookAtPosition[1] = 0;
	cameraMovement.rotationAboutLookAtPosition[2] = 0;
	cameraMovement.rotationAboutLookAtPosition[3] = 0;
	cameraMovement.xPanDirection = Vector3(0,0,0);
	cameraMovement.yPanDirection = Vector3(0,0,0);
	
	cameraMovement.dolly = false;
	cameraMovement.pan = false;
	cameraMovement.trackball = false;
	
	cameraPosition.lookAtPosition = Vector3(0,0,0);
	cameraPosition.rotationAboutLookAtPosition[0] = 0;
	cameraPosition.rotationAboutLookAtPosition[1] = 0;
	cameraPosition.rotationAboutLookAtPosition[2] = 0;
	cameraPosition.rotationAboutLookAtPosition[3] = 0;
	cameraPosition.translationFromLookAtPosition = Vector3(0,0,-60);
	
	spaceConverter.FlasherValue = 0;
	FlasherDirection = 1;
	[FlasherDate release];
	FlasherDate = [[NSDate date] retain];
	
	[super Reset];
}

- (void)dealloc
{
	[FlasherDate release];
	[super dealloc];
}
@end
