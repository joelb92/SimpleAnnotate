//
//  ColorTableCellView.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/13/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "ColorTableCellView.h"

@implementation ColorTableCellView

@dynamic backgroundColor;
-(id)init
{
	self = [super init];
	if (self)
	{
		self.backgroundColor = [NSColor windowBackgroundColor];
	}
	return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
	{
		self.backgroundColor = [NSColor windowBackgroundColor];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.backgroundColor = [NSColor windowBackgroundColor];
	}
	return self;
}

- (void)setBackgroundColor:(NSColor*)backC
{
	backgroundColor = backC;
	
	[self setNeedsDisplay:YES];
}
- (NSColor*)backgroundColor
{
	return backgroundColor;
}


- (void)drawRect:(NSRect)frame
{
    NSBezierPath* rectanglePath = [NSBezierPath bezierPathWithRect:frame];
	[backgroundColor setFill];
	[rectanglePath fill];
}

@end
