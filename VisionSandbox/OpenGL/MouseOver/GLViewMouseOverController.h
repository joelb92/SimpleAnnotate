//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "DragableSubView.h"
#import "GLRuler.h"
#import "GLProtractor.h"
#import "GLRectangleDragger.h"
@interface GLViewMouseOverController : DragableSubView <NSTabViewDelegate>
{
	GLRuler*rulerTool;
	GLProtractor*protractorTool;
	GLViewTool*currentTool;
	GLRectangleDragger *rectangleTool;
    IBOutlet NSTextField *defaultRectHeightField;
    IBOutlet NSTextField *defaultRectWidthField;
	IBOutlet NSTabView *TabView;
	
	//Ruler
	IBOutlet NSTextField *DistanceOutput;
	
	//Protractor
	IBOutlet NSTextField *AngleOutput;
	
	//Spherometer
	IBOutlet NSTextField *RadiusOutput;
	
	//RectTool
	IBOutlet NSTextField *RectKey;
	
	IBOutlet InfoOutputController *infoOutput;

}
@property (assign) GLRectangleDragger *rectangleTool;
@property (assign) NSTextField *RectKey;
- (GLViewTool*)tool;
- (bool)ActiveInView:(NSView*)view;
- (void)ToggleInView:(NSView*)view;
- (void)mouseClickedAtPoint:(Vector2)p withEvent:(NSEvent *)event;
@end
