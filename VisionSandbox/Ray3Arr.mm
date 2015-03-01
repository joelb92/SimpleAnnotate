//
//  Ray3Arr.m
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 3/22/13.
//
//

#import "Ray3Arr.h"

@implementation Ray3Arr
// Make sure this is a .mm file, not a .m file!
const int AddObjectLengthIncrament = 10000;
- (id)init
{
	self = [super init];
	if(self)
	{
		arr = new Ray3[0];
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
		arr = new Ray3[length];
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
		arr = new Ray3[length];
		Length=length;
		elements=length;
		VisableLength=length;
	}
	return self;
}
- (void)addCapacity:(int)capacityIncrease
{
	Ray3*temp = new Ray3[Length+capacityIncrease];
	for(int i=0; i<Length; ++i)
	{
		temp[i] = arr[i];
	}
	
	delete[] arr;
	//temp = &arr[0];  USE THIS EVENTUALLY
	arr = temp;
	Length=Length+capacityIncrease;
}
- (void)addElement:(Ray3)element
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
- (Ray3)elementAtIndex:(int)index
{
	return arr[index];
}
- (void)replaceElementAtIndex:(int)index With:(Ray3)element
{
	arr[index] = element;
}
- (void)reset
{
	elements = 0;
	VisableLength = 0;
}

- (Vector3Arr)RaycastRaysForRayEndsWithRadius:(float)radius Ray:(Ray3)ray
{
	Vector3Arr Hits = Vector3Arr();
	
	for(int i=0; i<VisableLength; i++)
	{
		Ray3 aRay = arr[i];
		Vector3 point = ray.ProjectionOfPoint(aRay.origin);
		if((point-ray.origin).Dot(ray.direction)>0)
		{
			Hits.AddItemToEnd(aRay.origin);
		}
		
		Vector3 term = aRay.origin+aRay.direction;
		point = ray.ProjectionOfPoint(term);
		if((point-term).Dot(ray.direction)>0)
		{
			Hits.AddItemToEnd(term);
		}
	}
	
	return Hits;
}
- (intArr)RaycastRaysForIndexesWithRadius:(float)radius Ray:(Ray3)ray
{
	intArr Hits = intArr();
	
	for(int i=0; i<VisableLength; i++)
	{
		Ray3 aRay = arr[i];
		Vector3 point = ray.ProjectionOfPoint(aRay.origin);
		if((point-ray.origin).Dot(ray.direction)>0)
		{
			Hits.AddItemToEnd(i);
		}
		
		Vector3 term = aRay.origin+aRay.direction;
		point = ray.ProjectionOfPoint(term);
		if((point-term).Dot(ray.direction)>0)
		{
			Hits.AddItemToEnd(i);
		}
	}
	
	return Hits;
}
- (void)dealloc
{
	delete[] arr;
	[super dealloc];
}
@end
