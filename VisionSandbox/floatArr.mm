//
//  floatArr.m
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "floatArr.h"

@implementation floatArr
// Make sure this is a .mm file, not a .m file!
const int AddObjectLengthIncrament = 10000;
- (id)init
{
	self = [super init];
	if(self)
	{
		arr = new float[0];
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
		arr = new float[length];
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
		arr = new float[length];
		Length=length;
		elements=length;
		VisableLength=length;
	}
	return self;
}
- (void)addCapacity:(int)capacityIncrease
{
	float*temp = new float[Length+capacityIncrease];
	for(int i=0; i<Length; ++i)
	{
		temp[i] = arr[i];
	}
	delete[] arr;
	arr = temp;
	Length=Length+capacityIncrease;
}
- (void)addElement:(float)element
{
	if(VisableLength>=Length)
	{
		[self addCapacity:AddObjectLengthIncrament];
	}
	arr[VisableLength] = element;
	elements++;
	VisableLength++;
}
- (void)removeLastElement
{
	Length = elements-1;
	float*temp = new float[Length];
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

- (int)Length
{
	return VisableLength;
}

- (int)numberOfElements
{
	return elements;
}
- (float)elementAtIndex:(int)index
{
	if(index<0 || index>=elements)
	{
		NSLog(@"%i index out of range on an float array of length %i.",index,VisableLength);
		return nil;
	}
	else return arr[index];
}
- (void)replaceElementAtIndex:(int)index With:(float)element
{
	if(index<0 || index>=VisableLength)
	{
		NSLog(@"%i index out of range on an float array of length %i.",index,VisableLength);
	}
	else arr[index] = element;
        }
- (void)dealloc
{
	delete[] arr;
	[super dealloc];
}
@end
