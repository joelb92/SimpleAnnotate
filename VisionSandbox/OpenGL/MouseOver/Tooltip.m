//
//  Tooltip.m
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 6/24/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "Tooltip.h"

@implementation Tooltip
@synthesize typeSelectionBox,nameField;
-(id)init
{
    self = [super init];
    if (self) {
//        typeSelectionBox = [[NSComboBox alloc] init];
//        nameField = [[NSTextField alloc] init];

    }
    return self;
}

-(void)setHidden:(BOOL)flag
{
    [super setHidden:flag];
    if (flag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tooltipIsActive" object:[NSNumber numberWithBool:NO]];

    }
    
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}
-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

@end
