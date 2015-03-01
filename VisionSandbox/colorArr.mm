//
//  colorArr.m
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 3/22/12.
//  Copyright (c) 2012 Magna Mirrors. All rights reserved.
//

#import "colorArr.h"

@implementation colorArr
// Make sure this is a .mm file, not a .m file!
const int AddObjectLengthIncrament = 10000;
- (id)init
{
	self = [super init];
	if(self)
	{
		arr = new Color[0];
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
		arr = new Color[length];
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
		arr = new Color[length];
		Length=length;
		elements=length;
		VisableLength=length;
	}
	return self;
}
- (void)addCapacity:(int)capacityIncrease
{
	Color*temp = new Color[Length+capacityIncrease];
	for(int i=0; i<Length; ++i)
	{
		temp[i] = arr[i];
	}
	delete[] arr;
	arr = temp;
	Length=Length+capacityIncrease;
}
- (void)addElement:(Color)element
{
	if(VisableLength>=Length)
	{
		[self addCapacity:AddObjectLengthIncrament];
	}
	arr[VisableLength] = element;
	elements++;
	VisableLength++;
}
- (void)addElements:(colorArr*)cols
{
	if(VisableLength+cols.Length>=Length)
	{
		[self addCapacity:cols.Length];
	}
	for(int i=0; i<cols.Length; i++)
	{
		arr[VisableLength+i] = [cols elementAtIndex:i];
	}
	elements += cols.Length;
	VisableLength += cols.Length;
}
- (void)removeLastElement
{
	Length = elements-1;
	Color*temp = new Color[Length];
	for(int i=0; i<Length; ++i)
	{
		temp[i] = arr[i];
	}
	delete[] arr;
	arr=temp;
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
- (Color)elementAtIndex:(int)index
{
	if(index<0 || index>=elements)
	{
		NSLog(@"%i index out of range on an Color* array of length %i.",index,VisableLength);
	}
	return arr[index];
}
- (void)replaceElementAtIndex:(int)index With:(Color)element
{
	if(index<0 || index>=VisableLength)
	{
		NSLog(@"%i index out of range on an Color* array of length %i.",index,VisableLength);
	}
	else arr[index] = element;
}
- (void)Reset
{
	VisableLength = 0;
	elements = 0;
}
- (void)dealloc
{
	delete[] arr;
	[super dealloc];
}
@end
