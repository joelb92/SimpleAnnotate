//
//  DragableSubView.m
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DragableSubView.h"

@implementation DragableSubView
- (void)mouseDown:(NSEvent*)event
{
	startMousePos = [self convertPoint:[event locationInWindow] fromView:self];
	startViewPos = self.frame.origin;
	mouseStartedOnView = true;
}
- (void)mouseDragged:(NSEvent*)event
{
	if(mouseStartedOnView)
	{
		NSPoint mousePos = [self convertPoint:[event locationInWindow] fromView:self];
		NSPoint newViewPos;
		newViewPos.x = floor(startViewPos.x + mousePos.x-startMousePos.x);
		newViewPos.y = floor(startViewPos.y + mousePos.y-startMousePos.y);
		[self setFrameOrigin:newViewPos];
		[self makeViewFitParentView];
	}
}
- (void)mouseUp:(NSEvent *)theEvent
{
	mouseStartedOnView = false;
}

- (void)viewDidMoveToSuperview
{
	if(self.superview)
	{
		[self makeViewFitParentView];
		[super viewDidMoveToSuperview];
	}
}
- (void)makeViewFitParentView
{
	NSRect parentFrame = self.superview.frame;
	
	NSRect frame = self.frame;
	if(frame.origin.x < 0)
		frame.origin.x = 0;
	
	if(frame.origin.y < 0)
		frame.origin.y = 0;
	
	if(frame.origin.x+frame.size.width > parentFrame.size.width)
		frame.origin.x = parentFrame.size.width-frame.size.width;
	
	if(frame.origin.y+frame.size.height > parentFrame.size.height)
		frame.origin.y = parentFrame.size.height-frame.size.height;
	[self setFrame:frame];
}
@end
