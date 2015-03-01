//
//  DisplayListArr.mm
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 2/5/13.
//
//

#import "DisplayListArr.h"

@implementation DisplayListArr
// Make sure this is a .mm file, not a .m file!
const int AddObjectLengthIncrament = 10000;
- (id)init
{
	self = [super init];
	if(self)
	{
		arr = new DisplayList*[0];
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
		arr = new DisplayList*[length];
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
		arr = new DisplayList*[length];
		Length=length;
		elements=length;
		VisableLength=length;
	}
	return self;
}

- (void)addCapacity:(int)capacityIncrease
{
	DisplayList**temp = new DisplayList*[(Length+1)*2];
	for(int i=0; i<Length; ++i)
	{
		temp[i] = arr[i];
	}
	delete[] arr;
	arr = temp;
	Length=(Length+1)*2;
}
- (void)addElement:(DisplayList*)element
{
	if([NSThread isMainThread])
	{
		if(VisableLength>=Length)
		{
			[self addCapacity:AddObjectLengthIncrament];
		}
		arr[VisableLength] = element;
		elements++;
		VisableLength++;
	}
	else [self performSelectorOnMainThread:@selector(Reset) withObject:nil waitUntilDone:YES];
}
- (void)removeLastElement
{
	if([NSThread isMainThread])
	{
		arr[VisableLength-1]->release();
		elements--;
		VisableLength--;
	}
	else [self performSelectorOnMainThread:@selector(Reset) withObject:nil waitUntilDone:YES];
}
- (void)Reset
{
	@autoreleasepool
	{
		if(VisableLength>0)
		{
			if([NSThread isMainThread])
			{
				for(int i=0; i<VisableLength; i++)
				{
					arr[i]->release();
				}
				VisableLength = 0;
				elements = 0;
			}
			else [self performSelectorOnMainThread:@selector(Reset) withObject:nil waitUntilDone:YES];
		}
	}
}
- (int)Length
{
	return VisableLength;
}
- (int)numberOfElements
{
	return elements;
}
- (DisplayList*)elementAtIndex:(int)index
{
	if(index<0 || index>=elements)
	{
		NSLog(@"getting %i index out of range on an display list array of length %i.",index,VisableLength);
	}
	return arr[index];
}
- (void)replaceElementAtIndex:(int)index With:(DisplayList*)element
{
	if(index<0 || index>=VisableLength)
	{
		NSLog(@"replacing %i index out of range on an display list array of length %i.",index,VisableLength);
	}
	else
	{
		arr[index]->release();
		arr[index] = element;
	}
}
- (void)dealloc
{
	[self Reset];
	delete[] arr;
	[super dealloc];
}

@end
