//
//  SliderView.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/13/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "SliderView.h"

@implementation SliderView
@dynamic min,max;
@synthesize numType;
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
	}
    return self;
}

-(id)init
{
	self = [super init];
	if (self)
	{
	}
	return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
	}
	return self;
}

-(IBAction)sliderChandged:(id)sender
{
	[field setStringValue:[NSString stringWithFormat:@"%i",slider.intValue]];
	[self settingChanged];
}

-(IBAction)valChanged:(id)sender
{
	[slider setIntValue:field.intValue];
	[self settingChanged];
}

-(void)applyValue:(id)val
{
	if ([val isKindOfClass:NSNumber.class]) {
		slider.intValue = [(NSNumber *)val intValue];
		[self sliderChandged:nil];
	}
}

-(id)getValue
{
	return @(slider.intValue);
}

-(void)setMax:(double)m
{
	[slider setMaxValue:m];
	max = m;
}

-(void)setting_min:(NSNumber *)m
{
	self.min = m.intValue;
}

-(void)setting_max:(NSNumber *)m
{
	self.max = m.intValue;
}

-(void)setMin:(double)m
{
	[slider setMinValue:m];
	min = m;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (int)intVal
{
	return slider.intValue;
}

@end
