//
//  Tooltip.m
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 6/24/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "Tooltip.h"

@implementation Tooltip
@synthesize typeSelectionBox,nameField,openCount;
-(id)init
{
    self = [super init];
    if (self) {
//        typeSelectionBox = [[NSComboBox alloc] init];
//        nameField = [[NSTextField alloc] init];
        openCount = 0;
        objectsTooltipIsVisibleIn = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        //        typeSelectionBox = [[NSComboBox alloc] init];
        //        nameField = [[NSTextField alloc] init];
        openCount = 0;
        objectsTooltipIsVisibleIn = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)setHidden:(BOOL)flag forObject:(id)obj
{
    
    if (flag) {
        while([objectsTooltipIsVisibleIn containsObject:obj]) [objectsTooltipIsVisibleIn removeObject:obj];
        if (objectsTooltipIsVisibleIn.count == 0) {
            [super setHidden:flag];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tooltipIsActive" object:[NSNumber numberWithBool:NO]];
        }
    }
    else{
        [objectsTooltipIsVisibleIn addObject:obj];
        if (objectsTooltipIsVisibleIn.count > 0)
        {
            [super setHidden:flag];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tooltipIsActive" object:[NSNumber numberWithBool:YES]];

        }
    }
}

-(void)setHidden:(BOOL)flag
{
    [super setHidden:flag];
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)incrementVisibleCount
{
    openCount++;
    if (openCount > 0) {
        [self setHidden:NO];
    }
}
-(void)decrementVisibleCount
{
    openCount--;
    if (openCount <= 0) {
        openCount = 0;
        [self setHidden:YES];
        
    }
}
//-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
//{
//    return YES;
//}


@end
