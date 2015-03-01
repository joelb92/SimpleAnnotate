//
//  Algorithm.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/11/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import "Algorithm.h"

@implementation Algorithm
-(id)init
{
	self = [super init];
	if (self) {
		functions = [[NSMutableArray alloc] init];
	}
	return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		functions = [aDecoder decodeObjectForKey:@"functions"];
	}
	return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:functions forKey:@"functions"];
}
-(Function *)FunctionAtIndex:(int)index
{
	return [functions objectAtIndex:index];
}
-(void)addFunction:(Function *)function
{
	[functions addObject:function];
}
-(void)addFunctions:(NSArray *)functionsArr
{
	for(int i =	0; i < functionsArr.count; i++)
	{
		[self addFunction:[functionsArr objectAtIndex:i]];
	}
}
-(void)insertFunction:(Function *)function atIndex:(int)index
{
	[functions insertObject:function atIndex:index];
}
-(void)replaceFunctionAtIndex:(int)index withFunction:(Function *)function
{
	[functions replaceObjectAtIndex:index withObject:function];
}
-(void)removeFunctionAtIndex:(int)index
{
	[functions removeObjectAtIndex:index];
}
-(void)removeFunction:(Function *)func
{
	[functions removeObject:func];
}
-(int)indexForFunction:(Function *)func
{
	return [functions indexOfObject:func];
}

-(id)runMethod:(id)input
{
	id inputParameter = input;
	for(int i = 0; i < functions.count; i++)
	{
		inputParameter = [[functions objectAtIndex:i] run:inputParameter];
	}
	return inputParameter;
}


-(int)count
{
	return (int)functions.count;
}
@end
