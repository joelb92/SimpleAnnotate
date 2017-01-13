//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLViewMouseOverController.h"

@implementation GLViewMouseOverController
@synthesize rectangleTool,RectKey,allTools,scissorTool,visibleTools;
- (GLViewTool*)tool
{
    return [[currentTool retain] autorelease];
    
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        previousStatusLabel = @"";
        tableViewCells = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"TableReload" object:nil];
        rulerTool = [[GLRuler alloc] init];
        visibleTools = [[NSMutableArray alloc] init];
        toolIndexToTableIndex = [[NSMutableDictionary alloc] init];
        tableIndexToToolIndex = [[NSMutableDictionary alloc] init];
        protractorTool = [[GLProtractor alloc] init];
        rectangleTool = [[GLRectangleDragger alloc] initWithOutputView:infoOutput];
        ellipseTool = [[GLEllipseTool alloc] initWithOutputView:infoOutput];
        pointTool = [[GLPointArrayTool alloc] initWithOutputView:infoOutput];
        scissorTool = [[IntelligentScissors alloc] init];
        pointTool.scissorTool = scissorTool;
        toolNames = [@[@"rectangleTool",@"ellipseTool",@"pointTool"] retain];
        tools = [@[rectangleTool,ellipseTool,pointTool] retain];
        allTools = [[NSDictionary alloc] initWithObjects:tools forKeys:toolNames];
        keysForTools = [[NSMutableDictionary alloc] init];
        labelFields = [[NSMutableDictionary alloc] init];
        annotationTypes = [[NSMutableArray alloc] initWithObjects:@"Face",@"Tattoo",@"Piercing",@"None",@"+Add Other", nil];
        //		[mainTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
        currentTool = rectangleTool;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateOutput) name:@"MouseOverToolValueChanged" object:nil];
        //		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OpenSegmentationAssistant) name:@"Open Segmentation Assistant!" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSelectedTableRow:) name:@"SelectionChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyDownHappened:) name:@"KeyDownHappened" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyDownHappened:) name:@"KeyUpHappened" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyFlagsChanged:) name:@"keyFlagsChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableHoverRect:) name:@"TableViewHoverChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableHoverRect:) name:@"TableViewHoverEnded" object:nil];
        
        
        
        linkImg = [NSImage imageNamed:@"link.png"];
        unlinkImg = [NSImage imageNamed:@"unlink.png"];
        currentTool.linkedDims = false;
        rectangleTool.linkedDims = false;
        ellipseTool.linkedDims = false;
    }
    
    return self;
}

-(void)keyDownHappened:(NSNotification *)notification
{
    NSEvent *event = [notification object];
    if (event.keyCode == 36) {
        if (currentTool == pointTool and lassoMenu.selectedSegment == 0) {
            previousStatusLabel = statusLabel.stringValue;
            [statusLabel setStringValue:@"'CMD'+''alt' click to begin a new magnetic lasso point set"];
        }
    }
    if (event.modifierFlags & NSControlKeyMask) {
        if ([[event characters] isEqualToString:@"r"]) {
            [toolMenu setSelectedSegment:0];
            [self toolSelection:nil];
        }
        else if ([[event characters] isEqualToString:@"c"]) {
            [toolMenu setSelectedSegment:1];
            [self toolSelection:nil];
        }
        else if ([[event characters] isEqualToString:@"s"]) {
            [toolMenu setSelectedSegment:2];
            [self toolSelection:nil];
        }
    }
    
}

-(void)keyUpHappened:(NSNotification *)notification
{
    NSEvent *event = [notification object];
}

-(void)keyFlagsChanged:(NSNotification *)notification
{
    NSEvent *event = [notification object];
    if ([event modifierFlags] & NSCommandKeyMask) {
        commandIsHeld = true;
    }
    else
    {
        commandIsHeld = false;
    }
    for(GLViewTool *t in allTools.allValues) t.modifierFlags = event.modifierFlags;
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
    [self displayTypeDidChange:nil];
    
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
    if (currentTool == pointTool and !pointTool.scissorTool.scissorActive and lassoMenu.selectedSegment == 0)
    {
        previousStatusLabel = statusLabel.stringValue;
        [statusLabel setStringValue:@"'CMD'+''alt' click to begin a new magnetic lasso point set"];
    }
    else if(currentTool == pointTool and !pointTool.scissorTool.scissorActive and lassoMenu.selectedSegment == 1)
    {
        previousStatusLabel = statusLabel.stringValue;
        [statusLabel setStringValue:@"'CMD'+''alt' click to begin a new point set"];
    }
    else if(currentTool != pointTool)
    {
        previousStatusLabel = statusLabel.stringValue;
        [statusLabel setStringValue:[NSString stringWithFormat:@"Now using %@",[keysForTools objectForKey:currentTool]]];
    }
    [self displayTypeDidChange:nil];
    [self reloadTable];
}

-(IBAction)displayTypeDidChange:(id)sender
{
    [visibleTools removeAllObjects];
    if ([displayCurrentCheckbox state] > 0) {
        [visibleTools addObject:currentTool];
        [displayrectCheckbox setEnabled:NO];
        [displayellipseCheckbox setEnabled:NO];
        [displayPointCheckbox setEnabled:NO];
    }
    else {
        [displayrectCheckbox setEnabled:YES];
        [displayellipseCheckbox setEnabled:YES];
        [displayPointCheckbox setEnabled:YES];
        if ([displayrectCheckbox state]) {
            [visibleTools addObject:rectangleTool];
        }
        if ([displayellipseCheckbox state])
        {
            [visibleTools addObject:ellipseTool];
        }
        if ([displayPointCheckbox state])
        {
            [visibleTools addObject:pointTool];
        }
    }
    [self reloadTable];
}

-(void)comboBoxWillPopUp:(NSNotification *)notification
{
    for(GLViewTool *t in allTools.allValues)
    {
        t.comboBoxIsOpen = true;
    }
    [tooltip setHidden:NO];
    comboDismissed = true;
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
    if (comboDismissed)
    {
        comboDismissed = false;
    NSComboBox *box = notification.object;
    if ([[box identifier] isEqualToString:@"tooltipCombo"]) {
        NSString *comboText = [box stringValue];
        if (![[box objectValues] containsObject:comboText])
        {
            
        }
        else if ([[tooltip.typeSelectionBox.objectValues objectAtIndex:tooltip.typeSelectionBox.indexOfSelectedItem] isEqualToString:@"+Add Other"])
        {
            
        }
        else
        {
            int row = (int)mainTableView.selectedRow;
            if (row >= 0) {
                NSArray *toolAndIndex = [self toolAndKeyForTableIndex:row];
                GLViewTool *mousedOverTool = [allTools objectForKey: [toolAndIndex objectAtIndex:0]];
                if ([mousedOverTool mousedOverElementIndex] >= 0)
                {
                    int ind = [[toolAndIndex objectAtIndex:1] intValue];
                    currentAnnotationType = tooltip.typeSelectionBox.indexOfSelectedItem;
                    
                    mousedOverTool.currentAnnotationType = [tooltip.typeSelectionBox.objectValues objectAtIndex:currentAnnotationType];
                    [mousedOverTool setCurrentElementType:currentTool.currentAnnotationType];
                    mousedOverTool.currentAnnotationTypeIndex = currentAnnotationType;
                }
            }
        }
    }
    [self reloadTable];
    }
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
            [tooltip.typeSelectionBox selectItemAtIndex:annotationTypes.count-2];
            [self comboBoxSelectionDidChange:obj];
        }
        [tooltip setHidden:YES];
    }
    else
    {
        int row = (int)mainTableView.selectedRow;
        int column =mainTableView.selectedColumn;
        if (row >= 0) {
            NSArray *toolAndIndex = [self toolAndKeyForTableIndex:row];
            GLViewTool *mousedOverTool = [allTools objectForKey: [toolAndIndex objectAtIndex:0]];
            int ind = [[toolAndIndex objectAtIndex:1] intValue];
            NSString *currentKey = [mousedOverTool.getKeys objectAtIndex:ind];
            NSString *newKey = [(NSTextField *)obj.object stringValue];
            [mousedOverTool setKey:newKey atIndexed:ind];
            
            //        [[currentTool getKeys] setObject:newKey atIndexedSubscript:row];
        }
    }
    [self reloadTable];
}
-(void)mouseClickedAtPoint:(Vector2)p SuperViewPoint:(Vector2)SP withEvent:(NSEvent *)event
{
    if (previousStatusLabel == nil) previousStatusLabel = @"";
    currentTool.defaultWidth = defaultRectWidthField.intValue;
    currentTool.defaultHeight = defaultRectHeightField.intValue;
    if (currentTool == pointTool and pointTool.scissorTool.scissorActive) {
        previousStatusLabel = [statusLabel stringValue];
        [statusLabel setStringValue:@"Press 'Enter' to finish Magnetic Lasso"];
    }
    
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
    GLViewTool *tool = [notification.object objectAtIndex:0];
    if ([tool mousedOverElementIndex] >= 0)
    {
        int row = [(NSNumber *)[notification.object objectAtIndex:1] intValue];
        int tableIndex = [self tableIndexForVisibleTool:tool andElementIndex:row];
        NSIndexSet *i = [[NSIndexSet alloc] initWithIndex:tableIndex];
        [mainTableView selectRowIndexes:i byExtendingSelection:NO];
        if (row < 0) {
            [mainTableView deselectAll:nil];
        }
    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    int total = 0;
    for(GLViewTool *t in visibleTools) total+= [t count];
    return total;
}
- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    NSTextField *result;
    NSString *toolKey;
    GLViewTool *tool;
    int toolElementIndex = -1;
    NSArray *toolProps = [self toolAndKeyForTableIndex:row];
    toolKey = [toolProps objectAtIndex:0];
    tool = [allTools objectForKey:toolKey];
    toolElementIndex = [[toolProps objectAtIndex:1] intValue];
    
    result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, tableColumn.width, 21)];
    if ([tableColumn.identifier isEqualToString:@"Location"]) {
        NSString *val =[tool stringForIndex:toolElementIndex];
        result.stringValue = val;
        [result setEditable:NO];
        [result setSelectable:NO];
    }
    else{
        NSString *key =[tool.getKeys objectAtIndex:toolElementIndex];
        result.stringValue = key;
        [tableViewCells setObject:result forKey:@(row)];
    }
    if(row == [self numberOfRowsInTableView:nil] -1)
    {
        [self relinkTableCells];
    }
    [result setDelegate:self];
    return result;
}

-(void)tableHoverRect:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"TableViewHoverEnded"]) {
        for(GLViewTool *otherTool in visibleTools) [otherTool tableHoverRect:[NSNotification notificationWithName:@"" object:@(-1)]];
        return;
    }
    int tableIndex = [notification.object intValue];
    NSArray *toolProps = [self toolAndKeyForTableIndex:tableIndex];
    GLViewTool *t = [allTools objectForKey:[toolProps objectAtIndex:0]];
    int index = [[toolProps objectAtIndex:1] intValue];
    [t tableHoverRect:[NSNotification notificationWithName:@"none" object:@(index)]];
    for(GLViewTool *otherTool in visibleTools) if(otherTool != t) [otherTool tableHoverRect:[NSNotification notificationWithName:@"" object:@(-1)]];
}



-(int)tableIndexForVisibleTool:(GLViewTool *)t andElementIndex:(int)elIndex
{
    int offsetCount = 0;
    for(int i = 0; i < visibleTools.count; i++)
    {
        if ([visibleTools objectAtIndex:i] == t) {
            break;
        }
        else offsetCount+= [[visibleTools objectAtIndex:i] count];
    }
    return elIndex+offsetCount;
}

-(NSArray *)toolAndKeyForTableIndex:(int)tableIndex
{
    GLViewTool *correctTool = [[allTools allValues] objectAtIndex:0];
    int toolIndex = -1;
    int countIndex = 0;
    
    for(int i = 0; i < visibleTools.count; i++)
    {
        if (tableIndex < [[visibleTools objectAtIndex:i] count]+countIndex ) {
            correctTool = [visibleTools objectAtIndex:i];
            toolIndex = tableIndex-countIndex;
            
            break;
        }
        countIndex +=[[visibleTools objectAtIndex:i] count];
    }
    return @[[toolNames objectAtIndex:[tools indexOfObject:correctTool]],@(toolIndex)];
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
