//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLViewMouseOverController.h"

@implementation GLViewMouseOverController
@synthesize rectangleTool,RectKey,allTools,scissorTool;
- (GLViewTool*)tool
{
	return [[currentTool retain] autorelease];
    
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
	{
        tableViewCells = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"TableReload" object:nil];
		rulerTool = [[GLRuler alloc] init];
		protractorTool = [[GLProtractor alloc] init];
		rectangleTool = [[GLRectangleDragger alloc] initWithOutputView:infoOutput];
        ellipseTool = [[GLEllipseTool alloc] initWithOutputView:infoOutput];
        pointTool = [[GLPointArrayTool alloc] initWithOutputView:infoOutput];
        scissorTool = [[IntelligentScissors alloc] init];
        pointTool.scissorTool = scissorTool;
        NSArray *toolNames = @[@"rectangleTool",@"ellipseTool",@"pointTool"];
        NSArray *tools = @[rectangleTool,ellipseTool,pointTool];
        allTools = [[NSDictionary alloc] initWithObjects:tools forKeys:toolNames];
//        keysForTools = [[NSMutableDictionary alloc] initWithObjects:toolNames forKeys:tools];
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

-(NSString *)currentToolKey
{
    for(NSString *key in allTools.allKeys)
    {
        if ([[allTools objectForKey:key] isEqualTo:[self tool]]) {
            return key;
        }
    }
    return [keysForTools objectForKey:[self tool]];
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
    for(GLViewTool *t in allTools.allValues)
    {
        [t setSuperView:mainView];
        [t setTooltip:tooltip];
        t.currentAnnotationType = @"none";
    }
//    [self linkDimsToggle:nil];

}
- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor lightGrayColor] set];
	[[NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:0.80] set];
	[[NSBezierPath bezierPathWithRect:dirtyRect] fill];
	[[NSBezierPath bezierPathWithRect:NSInsetRect([self bounds], 1, 1)] stroke];
}

-(IBAction)lassoSelection:(id)sender
{
    NSSegmentedControl *c = (NSSegmentedControl *) sender;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LassoSelectionChanged" object:@(c.selectedSegment)];
}

-(IBAction)toolSelection:(id)sender
{
    NSString *toolKey =[allTools.allKeys objectAtIndex:toolMenu.selectedSegment];
    currentTool = [allTools objectForKey:toolKey];
    if ([toolKey isEqualToString:@"pointTool"]) {
        [lassoMenu setHidden:NO];
        for(int i = 0; i < lassoMenu.segmentCount; i++)[lassoMenu setEnabled:YES forSegment:i];
    }
    else
    {
        for(int i = 0; i < lassoMenu.segmentCount; i++)[lassoMenu setEnabled:NO forSegment:i];
        [lassoMenu setHidden:YES];
    }
    
    [self reloadTable];
}

-(void)comboBoxWillPopUp:(NSNotification *)notification
{
    for(GLViewTool *t in allTools.allValues)
    {
        t.comboBoxIsOpen = true;
    }
}

-(void)comboBoxWillDismiss:(NSNotification *)notification
{
    for(GLViewTool *t in allTools.allValues)
    {
        t.comboBoxIsOpen = false;
    }
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
            currentTool.currentAnnotationTypeIndex = currentAnnotationType;
        }
    }
    [self reloadTable];
}
-(IBAction)textClick:(id)sender
{
    
}
-(void)controlTextDidBeginEditing:(NSNotification *)obj{
    
}
- (void)controlTextDidChange:(NSNotification *)notification {
    
}
-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    if([[(NSTextField *)obj.object identifier] isEqualToString:@"tooltipCombo"])
    {
        NSString *test = tooltip.typeSelectionBox.objectValue;
        if (![annotationTypes containsObject:tooltip.typeSelectionBox.objectValueOfSelectedItem] &&( tooltip.typeSelectionBox.indexOfSelectedItem >= 0 || tooltip.typeSelectionBox.objectValueOfSelectedItem != nil || ![tooltip.typeSelectionBox.objectValue isEqualToString:@""]) && ![tooltip.typeSelectionBox.objectValues containsObject:test]) {
            [annotationTypes insertObject:tooltip.typeSelectionBox.objectValue atIndex:annotationTypes.count-1];
            [tooltip.typeSelectionBox removeAllItems];
            [tooltip.typeSelectionBox addItemsWithObjectValues:annotationTypes];
            [tooltip.typeSelectionBox selectItemAtIndex:annotationTypes.count-1];
            [self comboBoxSelectionDidChange:obj];
        }
        [tooltip setHidden:YES];
    }
    else
    {
    int row = (int)mainTableView.selectedRow;
    int column =mainTableView.selectedColumn;
    if (row >= 0) {
        NSString *currentKey = [currentTool.getKeys objectAtIndex:row];
        NSString *newKey = [(NSTextField *)obj.object stringValue];
        [currentTool setKey:newKey atIndexed:row];
//        [[currentTool getKeys] setObject:newKey atIndexedSubscript:row];
    }
    }
    [self reloadTable];
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
        [tableViewCells setObject:result forKey:@(row)];
    }
    if(row == currentTool.count -1)
    {
        [self relinkTableCells];
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
    [tableViewCells removeAllObjects];
    [mainTableView reloadData];
}

-(void)relinkTableCells
{
    NSArray *keys = [tableViewCells.allKeys sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:YES]]];
    for (int i = 0; i < keys.count; i++) {
        if (i < keys.count-1) {
            NSTextField *t1 = [tableViewCells objectForKey:[keys objectAtIndex:i]];
            NSTextField *t2 = [tableViewCells objectForKey:[keys objectAtIndex:i+1]];
            if (t1 and t2) {
                [t1 setNextKeyView:t2];
            }
        }
        

    }
//    for (int i = 0; i < keys.count; i++) {
//        if (i < keys.count-1) {
//            NSTextField *t1 = [tableViewCells objectForKey:[keys objectAtIndex:i]];
//            NSTextField *t2 = [t1 nextKeyView];
//            NSLog(t2.stringValue);
//        }
//    }
}


- (void)dealloc
{
	[rulerTool release];
	[protractorTool release];
	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"MouseOverToolValueChanged"];
	[super dealloc];
}
@end
