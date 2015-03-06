//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "DragableSubView.h"
#import "GLRuler.h"
#import "GLProtractor.h"
#import "GLRectangleDragger.h"
#import "ROTableView.h"
@interface GLViewMouseOverController : DragableSubView <NSTabViewDelegate,NSTableViewDataSource,NSTextFieldDelegate>
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
	
    NSMutableDictionary *labelFields;
    IBOutlet NSTextField *testLabel;
	IBOutlet InfoOutputController *infoOutput;
    IBOutlet ROTableView *mainTableView;
    
}
@property (assign) GLRectangleDragger *rectangleTool;
@property (assign) NSTextField *RectKey;
- (GLViewTool*)tool;
- (bool)ActiveInView:(NSView*)view;
- (void)ToggleInView:(NSView*)view;
- (void)mouseClickedAtPoint:(Vector2)p SuperViewPoint:(Vector2)SP withEvent:(NSEvent *)event;
@end
