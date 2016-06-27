//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLViewMouseOverController.h"

@implementation GLViewMouseOverController
@synthesize rectangleTool,RectKey;
- (GLViewTool*)tool
{
	return [[currentTool retain] autorelease];
    
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
	{
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"TableReload" object:nil];
		rulerTool = [[GLRuler alloc] init];
		protractorTool = [[GLProtractor alloc] init];
		rectangleTool = [[GLRectangleDragger alloc] initWithOutputView:infoOutput];
        ellipseTool = [[GLEllipseTool alloc] initWithOutputView:infoOutput];
        pointTool = [[GLPointArrayTool alloc] initWithOutputView:infoOutput];
        allTools = [[NSArray alloc] initWithObjects:rectangleTool,ellipseTool, pointTool, nil];
        rectangleTool.superView = mainView;
        labelFields = [[NSMutableDictionary alloc] init];
        annotationTypes = [[NSMutableArray alloc] initWithObjects:@"Face",@"Tattoo",@"Piercing",@"None",@"+Add Other", nil];
//		[mainTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
		currentTool = rectangleTool;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateOutput) name:@"MouseOverToolValueChanged" object:nil];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OpenSegmentationAssistant) name:@"Open Segmentation Assistant!" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSelectedTableRow:) name:@"SelectionChanged" object:nil];
        linkImg = [NSImage imageNamed:@"link.png"];
        unlinkImg = [NSImage imageNamed:@"unlink.png"];
        currentTool.linkedDims = false;
        rectangleTool.linkedDims = false;
        ellipseTool.linkedDims = false;
    }
    
    return self;
}

- (IBAction)linkDimsToggle:(id)sender {
    if (currentTool.linkedDims) {
        currentTool.linkedDims = false;
        [linkDimsButton setImage:unlinkImg];
    }
    else{
        currentTool.linkedDims = true;
        [linkDimsButton setImage:linkImg];
    }
}


- (void)UpdateOutput
{
		[RectKey setStringValue:[NSString stringWithString:currentTool.currentKey]];
}
- (void)awakeFromNib
{
	currentTool.infoOutput = infoOutput;
    currentTool.defaultWidth = defaultRectWidthField.intValue;
    currentTool.defaultHeight = defaultRectHeightField.intValue;
    [tooltip.typeSelectionBox addItemsWithObjectValues:annotationTypes];
    for(GLViewTool *t in allTools)
    {
        [t setSuperView:mainView];
        [t setTooltip:tooltip];
        t.currentAnnotationType = @"none";
    }
    [rectangleTool setSuperView:mainView];
    [self linkDimsToggle:nil];

}
- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor lightGrayColor] set];
	[[NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:0.80] set];
	[[NSBezierPath bezierPathWithRect:dirtyRect] fill];
	[[NSBezierPath bezierPathWithRect:NSInsetRect([self bounds], 1, 1)] stroke];
}


-(IBAction)toolSelection:(id)sender
{
    currentTool = [allTools objectAtIndex:toolMenu.selectedSegment];
    [self reloadTable];
}

-(void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    if ([[(NSComboBox *)notification.object identifier] isEqualToString:@"tooltipCombo"]) {
        if ([[tooltip.typeSelectionBox.objectValues objectAtIndex:tooltip.typeSelectionBox.indexOfSelectedItem] isEqualToString:@"+Add Other"])
        {
            
        }
        else
        {
            currentAnnotationType = tooltip.typeSelectionBox.indexOfSelectedItem;
            currentTool.currentAnnotationType = [tooltip.typeSelectionBox.objectValues objectAtIndex:currentAnnotationType];
            [currentTool setCurrentElementType:currentTool.currentAnnotationType];
        }
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
}
-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    if ([[(NSTextField *)obj.object identifier] isEqualToString:@"tooltipName"]) {
        
    }
    int row = (int)mainTableView.selectedRow;
    int column =mainTableView.selectedColumn;
    if (row >= 0) {
        NSString *currentKey = [currentTool.getKeys objectAtIndex:row];
        NSString *newKey = [(NSTextField *)obj.object stringValue];
        [[currentTool getKeys] setObject:newKey atIndexedSubscript:row];
    }
}
-(void)mouseClickedAtPoint:(Vector2)p SuperViewPoint:(Vector2)SP withEvent:(NSEvent *)event
{
    currentTool.defaultWidth = defaultRectWidthField.intValue;
    currentTool.defaultHeight = defaultRectHeightField.intValue;

	[currentTool mouseClickedAtPoint:p superPoint:SP withEvent:event];
}

- (bool)ActiveInView:(NSView*)view
{
	return [self.superview isEqual:view];
}
- (void)ToggleInView:(NSView*)view
{
	if([self.superview isEqual:view])
	{
		[self removeFromSuperview];
		return;
	}
	
	if(self.superview) [self removeFromSuperview];
	
	[view addSubview:self];
	[self makeViewFitParentView];
}

-(void)setSelectedTableRow:(NSNotification *)notification
{
    int row = [(NSNumber *)notification.object intValue];
    NSIndexSet *i = [[NSIndexSet alloc] initWithIndex:row];
    [mainTableView selectRowIndexes:i byExtendingSelection:NO];
    if (row < 0) {
        [mainTableView deselectAll:nil];
    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return currentTool.count;
}
- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    NSTextField *result;
    result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, tableColumn.width, 21)];
    if ([tableColumn.identifier isEqualToString:@"Location"]) {
               result.stringValue = [currentTool stringForIndex:row];
        [result setEditable:NO];
        [result setSelectable:NO];
    }
    else{
        result.stringValue = [currentTool.getKeys objectAtIndex:row];
        
    }
    [result setDelegate:self];
    return result;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
//    if ([[aTableView selectedRowIndexes] containsIndex:rowIndex])
//    {
//        [aCell setBackgroundColor: [NSColor yellowColor]];
//    }
//    else
//    {
//        [aCell setBackgroundColor: [NSColor whiteColor]];
//    }
    [aCell setDrawsBackground:YES];
    if ([(ROTableView *)aTableView mouseOverRow] == rowIndex)
        NSLog(@"%d could be highlighted", rowIndex);
    else NSLog(@"%d shouldn't be highlighted", rowIndex);
}
-(void)reloadTable
{
    [mainTableView reloadData];
}


- (void)dealloc
{
	[rulerTool release];
	[protractorTool release];
	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"MouseOverToolValueChanged"];
	[super dealloc];
}
@end
