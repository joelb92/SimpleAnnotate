//
//  VisualFunctionViewHolder.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/13/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "VisualFunctionViewHolder.h"

@implementation VisualFunctionViewHolder
@synthesize viewHolder;
static VisualFunctionViewHolder *sharedViewHolder;
-(id)init
{
	self = [super init];
	if (self)
	{
		sharedViewHolder = self;
	}
	return self;
}
+ (id)sharedViewHolder
{
    return sharedViewHolder;
}
@end
