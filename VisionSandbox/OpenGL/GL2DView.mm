//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GL2DView.h"

@implementation GL2DView

- (void)setMaxImageSpaceRect:(vector2Rect)maxImageSpaceRect
{
//	if(maxImageSpaceRect != spaceConverter.ImageRect)
//	{
		spaceConverter.ImageRect = maxImageSpaceRect;
		MustReshape = true;
//	}
}

//Set some intitial values and start the idle (60 FPS):
- (void)prepareOpenGL
{
	spaceConverter.type = _2d;
	FlasherCyclesPerSecond = 1.5;
	[super prepareOpenGL];
}

//Create a camera and viewport that supports the image and view size:
- (void)reshape
{
	[self.openGLContext makeCurrentContext];
	MustReshape = false;
	
	spaceConverter.screenSize = self.frame.size;
	spaceConverter.screenAspectRatio = spaceConverter.screenSize.width/spaceConverter.screenSize.height;
	
	spaceConverter.frustrumScale = Magnification;
	if(spaceConverter.ImageRect.AspectRatio()>spaceConverter.screenAspectRatio) spaceConverter.frustrumScale *= spaceConverter.screenAspectRatio/spaceConverter.ImageRect.AspectRatio();
	
	glViewport(0, 0, (GLsizei)spaceConverter.screenSize.width, (GLsizei)spaceConverter.screenSize.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	spaceConverter.NearClip = 100;
	spaceConverter.FarClip = -100;
	glOrtho(-spaceConverter.screenAspectRatio/spaceConverter.frustrumScale, spaceConverter.screenAspectRatio/spaceConverter.frustrumScale, -1/spaceConverter.frustrumScale, 1/spaceConverter.frustrumScale, spaceConverter.NearClip, spaceConverter.FarClip);
	//gluPerspective(45.0, rect.size.width/rect.size.height, 0.01, 70.0);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
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
	glTranslatef(spaceConverter.imagePos.x, spaceConverter.imagePos.y, 0);
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSAutoreleasePool*pool = [[NSAutoreleasePool alloc] init];
	[self UpdateFlasherValue];
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

- (void)mouseDown:(NSEvent*)event
{
	[super mouseDown:event];
	startMousePos = mousePosition;
	startImagePos = spaceConverter.imagePos;
}
- (void)mouseMoved:(NSEvent*)event
{
	[super mouseMoved:event];
}
- (void)mouseDragged:(NSEvent*)event
{
	[super mouseDragged:event];
	if(!mouseOverController || !mouseOverController.tool.dragging || ![mouseOverController.superview isEqual:self])
	{
		Vector2 delta = mousePosition - startMousePos;
		
		spaceConverter.imagePos.x = startImagePos.x + (delta.x/spaceConverter.screenSize.width)*spaceConverter.screenAspectRatio/spaceConverter.frustrumScale;
		spaceConverter.imagePos.y = startImagePos.y + (delta.y/spaceConverter.screenSize.height)/spaceConverter.frustrumScale;
		[self ClampImageToScreen];
	}
}
- (void)mouseUp:(NSEvent*)event
{
	[super mouseUp:event];
}

-(BOOL)acceptsFirstResponder{
    return YES;
}

- (void)scrollWheel:(NSEvent*)event
{
	spaceConverter.imagePos.x+=(float)event.scrollingDeltaX/Magnification/750.0;
	spaceConverter.imagePos.y-=(float)event.scrollingDeltaY/Magnification/750.0;
	
	[self ClampImageToScreen];
}

//Pinch Gesture:
- (void)magnifyWithEvent:(NSEvent*)event
{
	Magnification += event.magnification*Magnification;
	[self ClampImageToScreen];
	[self reshape];
}


- (void)flagsChanged:(NSEvent *)theEvent
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"keyFlagsChanged" object:theEvent];
}

- (void)keyDown:(NSEvent*)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KeyDownHappened" object:event];
	switch ([event keyCode])
	{
		case 13:	//w
			imageMovement.zoomIn = YES;
			break;
		case 1:		//s
			imageMovement.zoomOut = YES;
			break;
		case 123:	//left
			imageMovement.left = YES;
			break;
		case 124:	//right
			imageMovement.right = YES;
			break;
		case 125:	//down
			imageMovement.bottom = YES;
			break;
		case 126:	//up
			imageMovement.top = YES;
			break;
	}
}
- (void)keyUp:(NSEvent*)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KeyUpHappened" object:event];
	switch ([event keyCode])
	{
		case 13:	//w
			imageMovement.zoomIn = NO;
			break;
		case 1:		//s
			imageMovement.zoomOut = NO;
			break;
		case 123:	//left
			imageMovement.left = NO;
			break;
		case 124:	//right
			imageMovement.right = NO;
			break;
		case 125:	//down
			imageMovement.bottom = NO;
			break;
		case 126:	//up
			imageMovement.top = NO;
			break;
	}
}

- (void)ZoomIn
{
    Magnification +=.3*Magnification;;
    [self ClampImageToScreen];
    [self reshape];
}
- (void)ZoomOut
{
    Magnification -=.3*Magnification;
    [self ClampImageToScreen];
    [self reshape];
}

- (void)move
{
	if(imageMovement.right)
	{
		spaceConverter.imagePos.x -= imageMovement.speed/Magnification;
	}
	if(imageMovement.left)
	{
		spaceConverter.imagePos.x += imageMovement.speed/Magnification;
	}
	if(imageMovement.top)
	{
		spaceConverter.imagePos.y -= imageMovement.speed/Magnification;
	}
	if(imageMovement.bottom)
	{
		spaceConverter.imagePos.y += imageMovement.speed/Magnification;
	}
	
	if(imageMovement.zoomIn)
	{
		Magnification = Magnification+.1*Magnification;
		if(Magnification<1) Magnification = 1;
		[self reshape];
	}
	if(imageMovement.zoomOut)
	{
		Magnification = Magnification-.1*Magnification;
		if(Magnification<1) Magnification = 1;
		[self reshape];
	}
	
	[self ClampImageToScreen];
}

//Ensure that the user doesn't zoom, or scroll off of the image (or zoom to some insaine point where you can't see any thing):
- (void)ClampImageToScreen
{
	if(Magnification<1) Magnification = 1;
	if(Magnification>10000) Magnification = 10000;
	
	if(spaceConverter.ImageRect.AspectRatio()<spaceConverter.screenAspectRatio)
	{
		if(Magnification > spaceConverter.screenAspectRatio/spaceConverter.ImageRect.AspectRatio())
		{
			float maxX = (1/Magnification*spaceConverter.screenAspectRatio-spaceConverter.ImageRect.AspectRatio());
			if(spaceConverter.imagePos.x<maxX) spaceConverter.imagePos.x=maxX;
			if(spaceConverter.imagePos.x>-maxX) spaceConverter.imagePos.x=-maxX;
		}
		else spaceConverter.imagePos.x = 0;
		
		float maxY = 1/Magnification-1;
		if(spaceConverter.imagePos.y<maxY) spaceConverter.imagePos.y=maxY;
		if(spaceConverter.imagePos.y>-maxY) spaceConverter.imagePos.y=-maxY;
	}
	else
	{
		float maxX = (1/Magnification-1)*spaceConverter.ImageRect.AspectRatio();
		if(spaceConverter.imagePos.x<maxX) spaceConverter.imagePos.x=maxX;
		if(spaceConverter.imagePos.x>-maxX) spaceConverter.imagePos.x=-maxX;
		
		if(Magnification > spaceConverter.ImageRect.AspectRatio()/spaceConverter.screenAspectRatio)
		{
			float maxY = 1/Magnification*(spaceConverter.ImageRect.AspectRatio()/spaceConverter.screenAspectRatio) - 1;
			if(spaceConverter.imagePos.y<maxY) spaceConverter.imagePos.y=maxY;
			if(spaceConverter.imagePos.y>-maxY) spaceConverter.imagePos.y=-maxY;
		}
		else spaceConverter.imagePos.y = 0;
	}
}

//Reset all the viewing values:
- (void)Reset
{
	Magnification = 1;
	
	spaceConverter.imagePos.x = 0.0f;
	spaceConverter.imagePos.y = 0.0f;
	imageMovement.left = NO;
	imageMovement.right = NO;
	imageMovement.top = NO;
	imageMovement.bottom = NO;
	imageMovement.speed = 0.1f;
	
	imageMovement.zoomIn = NO;
	imageMovement.zoomOut = NO;
	
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
