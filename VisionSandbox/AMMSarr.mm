//
//  AMMSarr.m
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AMMSarr.h"

@implementation AMMSarr
// Make sure this is a .mm file, not a .m file!
const int AddObjectLengthIncrament = 10000;
- (id)init
{
	self = [super init];
	if(self)
	{
		arr = new AMMS*[0];
		Length=0;
		arrays=0;
		VisableLength=0;
	}
	return self;
}
- (id)initWithCapacity:(int)length
{
	self = [super init];
	if(self)
	{
		arr = new AMMS*[length];
		Length=length;
		arrays=0;
		VisableLength=0;
	}
	return self;
}
- (id)initWithLength:(int)length
{
	self = [super init];
	if(self)
	{
		arr = new AMMS*[length];
		for(int i=0; i<length; ++i)
		{
			arr[i] = [[AMMS alloc] init];
		}
		Length=length;
		arrays=length;
		VisableLength=length;
	}
	return self;
}
- (id)initWithLength:(int)length MaxValuesPerAMMS:(int)num
{
	self = [super init];
	if(self)
	{
		arr = new AMMS*[length];
		for(int i=0; i<length; ++i)
		{
			arr[i] = [[AMMS alloc] initWithNumberOfValues:num];
		}
		Length=length;
		arrays=length;
		VisableLength=length;
	}
	return self;
}

- (void)addCapacity:(int)capacityIncrease
{
	AMMS**temp = new AMMS*[Length+capacityIncrease];
	for(int i=0; i<Length; ++i)
	{
		temp[i] = arr[i];
	}
	delete[] arr;
	arr = temp;
	Length=Length+capacityIncrease;
}
- (void)addArray:(AMMS*)array
{
	if(VisableLength>=Length)
	{
		[self addCapacity:AddObjectLengthIncrament];
	}
	arr[VisableLength] = [array retain];
	arrays++;
	VisableLength++;
}
- (void)removeLastArray
{
	Length = arrays-1;
	AMMS**temp = new AMMS*[Length];
	for(int i=0; i<Length; ++i)
	{
		temp[i] = arr[i];
	}
	delete[] arr;
	arr=temp;
	delete[] temp;
	arrays--;
	VisableLength--;
}

- (int)Length
{
	return VisableLength;
}
- (int)numberOfArrays
{
	return arrays;
}
- (AMMS*)arrayAtIndex:(int)index
{
	if(index<0 || index>=arrays)
	{
		NSLog(@"%i index out of range on an AMMS array of length %i.",index,VisableLength);
		return nil;
	}
	else return arr[index];
}
- (void)replaceArrayAtIndex:(int)index With:(AMMS*)array
{
	if(index<0 || index>=VisableLength)
	{
		NSLog(@"%i index out of range on an AMMS array of length %i.",index,VisableLength);
	}
	else arr[index] = array;
}
- (void)dealloc
{
	for(int i=0; i<VisableLength; ++i)
	{
		[arr[i] release];
	}
	delete[] arr;
	[super dealloc];
}
@end
