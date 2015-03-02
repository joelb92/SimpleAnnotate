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
		rulerTool = [[GLRuler alloc] init];
		protractorTool = [[GLProtractor alloc] init];
		rectangleTool = [[GLRectangleDragger alloc] initWithOutputView:infoOutput];

		
		currentTool = rectangleTool;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateOutput) name:@"MouseOverToolValueChanged" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OpenSegmentationAssistant) name:@"Open Segmentation Assistant!" object:nil];
    }
    
    return self;
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
	if (notification.object == RectKey) {
		if ([currentTool isEqual:rectangleTool] && rectangleTool.mousedOverRectIndex >0) {
			[rectangleTool setRectKey:RectKey.stringValue forIndex:rectangleTool.mousedOverRectIndex];
		}
	}
	
}

-(void)mouseClickedAtPoint:(Vector2)p withEvent:(NSEvent *)event
{
    rectangleTool.rectWidth = defaultRectWidthField.intValue;
    rectangleTool.rectHeight = defaultRectHeightField.intValue;
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
- (void)dealloc
{
	[rulerTool release];
	[protractorTool release];
	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"MouseOverToolValueChanged"];
	[super dealloc];
}
@end
