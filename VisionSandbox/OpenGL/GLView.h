//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GLObjectList.h"
#import "GLViewTool.h"
#import "GLUT/glut.h"
#import "Ray3.h"
#import "GLViewMouseOverController.h"
#import "OpenImageHandler.h"
@interface GLView : NSOpenGLView 
{
	bool Enabled;
	SpaceConverter spaceConverter;
	GLObjectList*objectList;
	
	bool mouseDragged;
	bool MustReshape;
	
	IBOutlet GLViewMouseOverController*mouseOverController;
	Vector2 previousMouseLocation;
	NSTrackingArea*trackingArea;
    cv::Mat rgbImg;
    bool isConverted;
	Vector2 mousePosition;
	Vector2 previousMousePosition;
	Vector2 mousePositionOnMouseDown;
	Vector2 mousePositionOnMouseRelease;
	NSColor*backgroundColor;
	IBOutlet InfoOutputController *infoOutput;
}
@property (readwrite) bool Enabled;
@property (retain) GLObjectList*objectList;
@property (assign) NSColor *backgroundColor;
@property GLViewMouseOverController *mouseOverController;
- (void)SaveObjectList;
//////////////////////////////////////////////////////////////////////////////////////////////////
//																								//
//																								//
//									Main Drawing Methodes										//
//																								//
//																								//
//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)Draw;
- (void)drawRect:(NSRect)dirtyRect;

- (NSImage*)imageFromOpenGLView;
- (void)SaveRenderToPath:(NSString*)Path;

//////////////////////////////////////////////////////////////////////////////////////////////////
//																								//
//																								//
//									    Event Handling											//
//																								//
//																								//
//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)mouseDown:(NSEvent*)event;
- (void)mouseUp:(NSEvent*)event;

//Setters:
- (void)setSmoothing:(bool)state;

//Reset all the viewing values:
- (void)Reset;

//Clear Content From View:
- (void)Clear;

- (void)ZoomIn;
- (void)ZoomOut;
@end