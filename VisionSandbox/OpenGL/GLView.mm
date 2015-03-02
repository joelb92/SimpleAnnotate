//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLView.h"

@implementation GLView
@synthesize Enabled;
@synthesize objectList,mouseOverController;
@dynamic backgroundColor;
- (void)setBackgroundColor:(NSColor*)backC
{
	backC = [[NSColor colorWithCalibratedRed:backC.redComponent*0.5 green:backC.greenComponent*0.5 blue:backC.blueComponent*0.5 alpha:backC.alphaComponent] retain];
	if(backgroundColor)
	{
		[backgroundColor release];
		backgroundColor = nil;
	}
	backgroundColor = backC;
	
	[self setNeedsDisplay:YES];
}
- (NSColor*)backgroundColor
{
	return [[backgroundColor retain] autorelease];
}

//Default initializer for sub-classes of NSView.
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		Enabled = true;
		NSOpenGLPixelFormatAttribute attribs[] =
        {
			kCGLPFAAccelerated,
			kCGLPFANoRecovery,
			kCGLPFADoubleBuffer,
			kCGLPFAColorSize, 24,
			kCGLPFADepthSize, 16,
			0
		};
		NSOpenGLPixelFormat* pixFmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
		NSOpenGLContext*context = [[NSOpenGLContext alloc] initWithFormat:pixFmt shareContext:nil];
		[pixFmt release];
		
		[self setOpenGLContext:context];
		[context release];
		
		//objectList = [[GLObjectList alloc] init];
		
		spaceConverter = SpaceConverter();
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ZoomIn) name:@"ZoomIn" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ZoomOut) name:@"ZoomOut" object:nil];
		
		backgroundColor = [[NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.1 alpha:1] retain];
	}
	return self;
}
//Set some intitial values and start the idle (60 FPS):
- (void)prepareOpenGL
{
	[self setWantsLayer:YES]; //Makes other views capable of drawing on top of this one, without it, opengl will take the show and cover every thing above or below it.
	[self.openGLContext makeCurrentContext];
	
	glClearColor(backgroundColor.redComponent, backgroundColor.greenComponent, backgroundColor.blueComponent, 1.0f);
	
	//glEnable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER, 0.45f);
	
	glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
	[self Reset];
}

- (void)SaveObjectList
{
	[objectList Save];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
//																								//
//																								//
//									Main Drawing Methodes										//
//																								//
//																								//
//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)Draw
{
	if(Enabled) [self setNeedsDisplay:YES]; //If wants layer is true, do not call drawrect directly, it won't work.
}
- (void)loadModelMatrix
{
	
}
- (void)drawRect:(NSRect)dirtyRect
{
	NSAutoreleasePool*pool = [[NSAutoreleasePool alloc] init];
	if(Enabled)
	{
		[self.openGLContext makeCurrentContext];
		[objectList releaseDeallocedObjects];
		if(MustReshape) [self reshape];
		
		glClearColor(backgroundColor.redComponent, backgroundColor.greenComponent, backgroundColor.blueComponent, 1.0f);
		
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glPushMatrix();
		{
			[self loadModelMatrix];
			spaceConverter.GetMatrixes();
			
			///////////////////
			//			     //
			//  Graph Stuff  //
			//			     //
			///////////////////
			
			[objectList GraphUsingSpaceConverter:spaceConverter];
			
			if(mouseOverController && [mouseOverController.superview isEqual:self])
			{
				[objectList MouseOverInfoAtScreenPoint:previousMousePosition UsingSpaceConverter:spaceConverter];
				[mouseOverController.tool GraphUsingSpaceConverter:spaceConverter];
			}
		}glPopMatrix();
		
		
		glFlush();
		[self.openGLContext flushBuffer];
	}
	
	[pool drain];
}
-(void)updateTrackingAreas
{
    if(trackingArea != nil)
	{
        [self removeTrackingArea:trackingArea];
        [trackingArea release];
    }
	
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingMouseMoved);
    trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}
- (NSImage*)imageFromOpenGLView
{
	bool oldEnabled = Enabled;
	Enabled = true;
	
	NSRect bounds = [self bounds];
	int height = bounds.size.height;
	int width = bounds.size.width;
	
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc]
								  initWithBitmapDataPlanes:NULL
								  pixelsWide:width
								  pixelsHigh:height
								  bitsPerSample:8
								  samplesPerPixel:4
								  hasAlpha:YES
								  isPlanar:NO
								  colorSpaceName:NSDeviceRGBColorSpace
								  bytesPerRow:4 * width
								  bitsPerPixel:0
								  ];
	
	// This call is crucial, to ensure we are working with the correct context
	[self.openGLContext makeCurrentContext];
	
	GLuint framebuffer, renderbuffer;
	GLenum status;
	// Set the width and height appropriately for your image
	GLuint imageWidth = width, imageHeight = height;
	//Set up a FBO with one renderbuffer attachment
	glGenFramebuffersEXT(1, &framebuffer);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, framebuffer);
	glGenRenderbuffersEXT(1, &renderbuffer);
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, renderbuffer);
	glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_RGBA8, imageWidth, imageHeight);
	glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
								 GL_RENDERBUFFER_EXT, renderbuffer);
	status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if (status != GL_FRAMEBUFFER_COMPLETE_EXT){
		// Handle errors
	}
	//Your code to draw content to the renderbuffer
	[self drawRect:[self bounds]];
	//Your code to use the contents
	glReadPixels(0, 0, width, height,
				 GL_RGBA, GL_UNSIGNED_BYTE, [imageRep bitmapData]);
	
	// Make the window the target
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	// Delete the renderbuffer attachment
	glDeleteRenderbuffersEXT(1, &renderbuffer);
	
	NSImage *image=[[[NSImage alloc] initWithSize:NSMakeSize(width,height)] autorelease];
	[image addRepresentation:imageRep];
	[image setFlipped:YES];
	[image lockFocusOnRepresentation:imageRep]; // This will flip the rep.
	[image unlockFocus];
	[imageRep autorelease]; //I added to silance The Anylizer, untested!
	
	Enabled = oldEnabled;
	
	return image;
	return nil;
}
- (void)SaveRenderToPath:(NSString*)Path
{
	//	[[self imageFromOpenGLView] saveAsJpegWithName:Path];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//																								//
//																								//
//									    Event Handling											//
//																								//
//																								//
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)GetMousePositionForEvent:(NSEvent*)event
{
	previousMousePosition = mousePosition;
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	mousePosition.x = location.x;
	mousePosition.y = location.y;
}
- (void)mouseMoved:(NSEvent*)event
{
	[self GetMousePositionForEvent:event];
	if(mouseOverController && [mouseOverController.superview isEqual:self] && (!spaceConverter.ImageRect.size.isNull() || spaceConverter.type==_3d))
	{
		[mouseOverController.tool SetMousePosition:mousePosition UsingSpaceConverter:spaceConverter];
        int mouseX = [objectList MouseOverPointAtScreenPoint:mousePosition UsingSpaceConverter:spaceConverter].x;
        int mouseY =[objectList MouseOverPointAtScreenPoint:mousePosition UsingSpaceConverter:spaceConverter].y;
		[infoOutput.xCoordMouseLabel setStringValue:[NSString stringWithFormat:@"%i",mouseX]];
		[infoOutput.yCoordMouseLabel setStringValue:[NSString stringWithFormat:@"%i",mouseY]];
        id obj =[objectList ObjectForKeyPath:@"/First"];
        cv::Mat img = [(OpenImageHandler *)([(TreeListItem *)[objectList ObjectForKeyPath:@"/First"] object]) Cv];
        int r,g,b;
        cv::Vec4b bgra;
        if (mouseX >= 0 && mouseX < img.cols && mouseY >= 0 && mouseY < img.rows) {
            bgra = img.at<cv::Vec4b>(mouseY,mouseX);
            infoOutput.blueLabel.intValue = bgra[0];
            infoOutput.greenLabel.intValue = bgra[1];
            infoOutput.redLabel.intValue = bgra[2];
        }
        else{
            infoOutput.blueLabel.stringValue = @"NA";
            infoOutput.redLabel.stringValue = @"NA";
            infoOutput.greenLabel.stringValue = @"NA";
        }
        
	}
}
- (void)mouseDown:(NSEvent*)event
{
	[self GetMousePositionForEvent:event];
	mousePositionOnMouseDown = mousePosition;
	if(mouseOverController && [mouseOverController.superview isEqual:self]) [mouseOverController.tool StartDragging:[event modifierFlags]];
	mouseDragged = false;
}
- (void)mouseUp:(NSEvent*)event
{
	[self GetMousePositionForEvent:event];
	if(mouseOverController)
	{
		if (mousePosition == mousePositionOnMouseDown)
		{
			[self mouseClicked:event];
		}
		if(!mouseDragged && !mouseOverController.tool.dragging){} //[mouseOverController ToggleInView:self];
		else if([mouseOverController.superview isEqual:self])
		{
			[mouseOverController.tool StopDragging];
		}
	}
}
- (void)mouseClicked:(NSEvent *)event
{
	[mouseOverController mouseClickedAtPoint:[objectList MouseOverPointAtScreenPoint:mousePosition UsingSpaceConverter:spaceConverter] SuperViewPoint:mousePosition withEvent:event];
}
- (void)mouseDragged:(NSEvent*)event
{
	[self GetMousePositionForEvent:event];
	if(mouseOverController && mouseOverController.tool.dragging && [mouseOverController.superview isEqual:self])
	{
		
		Vector3 point = [objectList MouseOverPointAtScreenPoint:mousePosition UsingSpaceConverter:spaceConverter];
		if(!point.isNull())
		{
			[mouseOverController.tool DragTo:point Event:event];
		}
	}
	else mouseDragged = true;
}

//Setters:
- (void)setSmoothing:(bool)state
{
	if(state)
	{
		glShadeModel(GL_SMOOTH);
	}
	else
	{
		glShadeModel(GL_FLAT);
	}
}

//Reset all the viewing values:
- (void)Reset
{
	[objectList ClearAll];
	[self reshape];
}

//Clear Content From View:
- (void)Clear
{
	[objectList ClearAll];
	[self reshape];
}
- (void)ZoomIn {}
- (void)ZoomOut {}
- (void)dealloc
{
	[backgroundColor release];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ZoomIn" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ZoomOut" object:nil];
	//[tool release];
	[objectList release];
	[super dealloc];
}
@end