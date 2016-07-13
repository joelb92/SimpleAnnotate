//
//  ComboBoxWithMouseOver.m
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 7/13/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "ComboBoxWithMouseOver.h"

@implementation ComboBoxWithMouseOver

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

-(void)mouseDown:(NSEvent *)theEvent
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tooltipIsActive" object:[NSNumber numberWithBool:YES]];
}
@end
