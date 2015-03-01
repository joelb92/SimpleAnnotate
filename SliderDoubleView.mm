//
//  SliderDoubleView.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/14/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "SliderDoubleView.h"

@implementation SliderDoubleView
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
	[field setStringValue:[slider stringValue]];
	[self settingChanged];
}

-(IBAction)valChanged:(id)sender
{
	[slider setDoubleValue:field.doubleValue];
	[self settingChanged];
}

-(void)applyValue:(id)val
{
	if ([val isKindOfClass:NSNumber.class]) {
		[slider setDoubleValue:[(NSNumber *)val doubleValue]];
		[self sliderChandged:nil];
	}
}
-(id)getValue
{
	return @(slider.doubleValue);
}

-(void)setting_min:(NSNumber *)m
{
	self.min = m.doubleValue;
}

-(void)setting_max:(NSNumber *)m
{
	self.max = m.doubleValue;
}

-(void)setMax:(double)m
{
	[slider setMaxValue:m];
	max = m;
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

- (double)doubleVal
{
	return slider.doubleValue;
}


@end
