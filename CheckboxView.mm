//
//  CheckboxView.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/13/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "CheckboxView.h"

@implementation CheckboxView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

-(void)applyValue:(id)val
{
	if ([val isKindOfClass:NSNumber.class]) {
		[checkBox setState:[(NSNumber *)checkBox boolValue]];
		
	}
}

-(IBAction)checkChanged:(id)sender
{
	[self settingChanged];
}
-(id)getValue
{
	return @(checkBox.state);
}
- (bool)state
{
	return checkBox.state;
}
@end
