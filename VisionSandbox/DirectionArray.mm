//
//  DirectionArray.m
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 9/19/12.
//  Copyright (c)2012 __MyCompanyName__. All rights reserved.
//

#import "DirectionArray.h"
@implementation DirectionArray
- (id)init
{
	self = [super init];
	if(self)
	{
		arr = new Direction[0];
		Length=0;
		elements=0;
		VisableLength=0;
	}
	return self;
}
- (id)initWithCapacity:(int)length
{
	self = [super init];
	if(self)
	{
		arr = new Direction[length];
		Length=length;
		elements=0;
		VisableLength=0;
	}
	return self;
}
- (id)initWithLength:(int)length
{
	self = [super init];
	if(self)
	{
		arr = new Direction[length];
		Length=length;
		elements=length;
		VisableLength=length;
	}
	return self;
}
- (void)addCapacity
{
	Direction*temp = new Direction[(Length+1)*2];
	for(int i=0; i<Length; ++i)
	{
		temp[i] = arr[i];
	}
	delete[] arr;
	arr = temp;
	Length=(Length+1)*2;
}
- (void)addElement:(Direction)element
{
	if(VisableLength>=Length)
	{
		[self addCapacity];
	}
	arr[VisableLength] = element;
	elements++;
	VisableLength++;
}
- (void)removeLastElement
{
	Length = elements-1;
	Direction*temp = new Direction[Length];
	for(int i=0; i<Length; ++i)
	{
		temp[i] = arr[i];
	}
	delete[] arr;
	arr=temp;
	delete[] temp;
	elements--;
	VisableLength--;
}
- (void)Reset
{
	VisableLength=0;
	elements=0;
}
- (int)Length
{
	return VisableLength;
}
- (int)numberOfElements
{
	return elements;
}
- (Direction)elementAtIndex:(int)index
{
	if(index<0 || index>=elements)
	{
		NSLog(@"%i index out of range on an Direction array of length %i.",index,VisableLength);
	}
	return arr[index];
}
- (void)replaceElementAtIndex:(int)index With:(Direction)element
{
	if(index<0 || index>=VisableLength)
	{
		NSLog(@"%i index out of range on an Direction array of length %i.",index,VisableLength);
	}
	else arr[index] = element;
}
- (void)dealloc
{
	delete[] arr;
	[super dealloc];
}
@end
