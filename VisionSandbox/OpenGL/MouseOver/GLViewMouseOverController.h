//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "DragableSubView.h"
#import "GLRuler.h"
#import "GLProtractor.h"
#import "GLRectangleDragger.h"
#import "GLEllipseTool.h"
#import "GLPointArrayTool.h"
#import "ROTableView.h"
#import "Tooltip.h"
#import "IntelligentScissors.h"

@interface GLViewMouseOverController : DragableSubView <NSTabViewDelegate,NSTableViewDataSource,NSTextFieldDelegate,NSComboBoxDelegate>
{
	GLRuler*rulerTool;
	GLProtractor*protractorTool;
    GLEllipseTool*ellipseTool;
    GLPointArrayTool*pointTool;
	GLViewTool*currentTool;
    
    
	GLRectangleDragger *rectangleTool;
    NSMutableArray *annotationTypes;
    int currentAnnotationType;
    IBOutlet NSTextField *defaultRectHeightField;
    IBOutlet NSTextField *defaultRectWidthField;
	IBOutlet NSTabView *TabView;
    NSDictionary *allTools;
	
	//Ruler
	IBOutlet NSTextField *DistanceOutput;
	
	//Protractor
	IBOutlet NSTextField *AngleOutput;
	
	//Spherometer
	IBOutlet NSTextField *RadiusOutput;
	
	//RectTool
	IBOutlet NSTextField *RectKey;
	
    IBOutlet NSView * mainView;
    IBOutlet Tooltip *tooltip;
    NSMutableDictionary *labelFields;
	IBOutlet InfoOutputController *infoOutput;
    IBOutlet ROTableView *mainTableView;
    IBOutlet NSButton *linkDimsButton;
    IBOutlet NSSegmentedControl *toolMenu;
    IBOutlet NSSegmentedControl *lassoMenu;
    IBOutlet NSTextField *statusLabel;
    
    IBOutlet NSButton *displayCurrentCheckbox;
    IBOutlet NSButton *displayrectCheckbox;
    IBOutlet NSButton *displayellipseCheckbox;
    IBOutlet NSButton *displayPointCheckbox;
    
    NSMutableDictionary *tableViewCells;
    NSMutableDictionary *keysForTools;
    NSMutableArray *visibleTools;
    NSMutableDictionary *toolIndexToTableIndex;
    NSMutableDictionary *tableIndexToToolIndex;
    NSArray *tools;
    NSArray *toolNames;
    IntelligentScissors *scissorTool;
    NSString *previousStatusLabel;
    int lassoMenuHeight;
    NSImage *linkImg;
    NSImage *unlinkImg;
    bool commandIsHeld;
    bool comboDismissed;
}
@property (assign) GLRectangleDragger *rectangleTool;
@property (assign) NSTextField *RectKey;
@property (assign) NSDictionary *allTools;
@property (assign) IntelligentScissors *scissorTool;
@property (readonly) NSMutableArray *visibleTools;
-(NSString *) currentToolKey;
- (GLViewTool*)tool;
- (bool)ActiveInView:(NSView*)view;
- (void)ToggleInView:(NSView*)view;
- (void)mouseClickedAtPoint:(Vector2)p SuperViewPoint:(Vector2)SP withEvent:(NSEvent *)event;
@end
