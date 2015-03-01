//
//  FunctionVisualParametersView.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/9/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "FunctionVisualParametersView.h"
#import "VisualFunctionViewHolder.h"
@implementation FunctionVisualParametersView
-(id)init
{
	self = [super init];
	if (self) {
		totalRunningHeight = 0;
//		ColorTableCellView	*subview =[[[VisualFunctionViewHolder sharedViewHolder] viewHolder] makeViewWithIdentifier:@"Slider" owner:self];
//		subview.frame = NSMakeRect(subview.frame.origin.x, subview.frame.origin.y, self.frame.size.width, subview.frame.size.height);
//		[subview setBackgroundColor:[NSColor redColor]];
		subViewDictionary = [[NSMutableDictionary alloc] init];
//		[self addSubview:subview];
	}
	return self;
}

-(void)addSubview:(NSTableCellView *)aView forKey:(NSString *)key
{
	[aView setFrame:NSMakeRect(aView.frame.origin.x, aView.frame.origin.y, self.frame.size.width, aView.frame.size.height)];
	totalRunningHeight+=aView.frame.size.height;
	[[aView textField] setStringValue:[key stringByReplacingOccurrencesOfString:@"set_" withString:@""]];
	self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height+aView.frame.size.height);
	[super addSubview:aView];
	[subViewDictionary setObject:aView forKey:key];
}

-(NSTableCellView *)subviewForKey:(NSString *)key
{
	return [subViewDictionary objectForKey:key];
}
@end
