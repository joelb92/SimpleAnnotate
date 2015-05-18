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
        labelFields = [[NSMutableDictionary alloc] init];
//		[mainTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
		currentTool = rectangleTool;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateOutput) name:@"MouseOverToolValueChanged" object:nil];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OpenSegmentationAssistant) name:@"Open Segmentation Assistant!" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSelectedTableRow:) name:@"SelectionChanged" object:nil];
        linkImg = [NSImage imageNamed:@"link.png"];
        unlinkImg = [NSImage imageNamed:@"unlink.png"];
        rectangleTool.linkedDims = true;
    }
    
    return self;
}
- (IBAction)linkDimsToggle:(id)sender {
    if (rectangleTool.linkedDims) {
        rectangleTool.linkedDims = false;
        [linkDimsButton setImage:unlinkImg];
    }
    else{
        rectangleTool.linkedDims = true;
        [linkDimsButton setImage:linkImg];
    }
}
- (void)UpdateOutput
{
		[RectKey setStringValue:[NSString stringWithString:rectangleTool.currentKey]];
}
- (void)awakeFromNib
{
	rectangleTool.infoOutput = infoOutput;
}
- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor lightGrayColor] set];
	[[NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:0.80] set];
	[[NSBezierPath bezierPathWithRect:dirtyRect] fill];
	[[NSBezierPath bezierPathWithRect:NSInsetRect([self bounds], 1, 1)] stroke];
}


- (void)controlTextDidChange:(NSNotification *)notification {
}
-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    int row = (int)mainTableView.selectedRow;
    int column =mainTableView.selectedColumn;
    if (row >= 0) {
        NSString *currentKey = [rectangleTool.getKeys objectAtIndex:row];
        NSString *newKey = [(NSTextField *)obj.object stringValue];
        [[rectangleTool getKeys] setObject:newKey atIndexedSubscript:row];
    }
}
-(void)mouseClickedAtPoint:(Vector2)p SuperViewPoint:(Vector2)SP withEvent:(NSEvent *)event
{
    rectangleTool.rectWidth = defaultRectWidthField.intValue;
    rectangleTool.rectHeight = defaultRectHeightField.intValue;
    NSRect newframe  = NSMakeRect(SP.x, SP.y, testLabel.frame.size.width, testLabel.frame.size.height);
    [testLabel setFrame:newframe];
	[currentTool mouseClickedAtPoint:p withEvent:event];
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
    return rectangleTool.getRects.count;
}
- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    NSTextField *result;
    result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, tableColumn.width, 21)];
    if ([tableColumn.identifier isEqualToString:@"Location"]) {
        NSRect r =[[[rectangleTool getRects] objectForKey:[[rectangleTool getKeys] objectAtIndex:row]] rectValue];
        result.stringValue =  [NSString stringWithFormat:@"%i,%i,%i,%i",(int)r.origin.x,(int)r.origin.y,(int)r.size.width,(int)r.size.height];
        [result setEditable:NO];
        [result setSelectable:NO];
    }
    else{
        result.stringValue = [rectangleTool.getKeys objectAtIndex:row];
        
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
