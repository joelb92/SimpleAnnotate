//
//  PlaneArr.m
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 3/22/13.
//
//

#import "PlaneArr.h"

@implementation PlaneArr
// Make sure this is a .mm file, not a .m file!
const int AddObjectLengthIncrament = 10000;
- (id)init
{
	self = [super init];
	if(self)
	{
		arr = new Plane[0];
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
		arr = new Plane[length];
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
		arr = new Plane[length];
		Length=length;
		elements=length;
		VisableLength=length;
	}
	return self;
}
- (void)addCapacity:(int)capacityIncrease
{
	Plane*temp = new Plane[Length+capacityIncrease];
	for(int i=0; i<Length; ++i)
	{
		temp[i] = arr[i];
	}
	
	delete[] arr;
	//temp = &arr[0];  USE THIS EVENTUALLY
	arr = temp;
	Length=Length+capacityIncrease;
}
- (void)addElement:(Plane)element
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
- (Plane)elementAtIndex:(int)index
{
	return arr[index];
}
- (void)replaceElementAtIndex:(int)index With:(Plane)element
{
	arr[index] = element;
}
- (void)reset
{
	elements = 0;
	VisableLength = 0;
}

- (Vector3Arr)RaycastPlanesForPlanePointsWithRadius:(float)radius Ray:(Ray3)ray
{
	Vector3Arr Hits = Vector3Arr();
	Vector3 direction = ray.direction.Normalized();
	
	for(int i=0; i<VisableLength; i++)
	{
		Plane aPlane = arr[i];
		Vector3 point = aPlane.position-ray.origin;
		float tempOne = direction.Dot(point);
		float tempTwo = point.Dot(point);
		if(pow(tempOne, 2) - tempTwo + pow(radius, 2) >= 0)
		{
			Hits.AddItemToEnd(point+ray.origin);
		}
		
		point = aPlane.position+aPlane.normal-ray.origin;
		tempOne = direction.Dot(point);
		tempTwo = point.Dot(point);
		if(pow(tempOne, 2) - tempTwo + pow(radius, 2) >= 0)
		{
			Hits.AddItemToEnd(point+ray.origin);
		}
	}
	
	return Hits;
}
- (intArr)RaycastPlanesForIndexesWithRadius:(float)radius Ray:(Ray3)ray
{
	intArr Hits = intArr();
	Vector3 direction = ray.direction.Normalized();
	
	for(int i=0; i<VisableLength; i++)
	{
		Plane aPlane = arr[i];
		Vector3 point = aPlane.position-ray.origin;
		float tempOne = direction.Dot(point);
		float tempTwo = point.Dot(point);
		if(pow(tempOne, 2) - tempTwo + pow(radius, 2) >= 0)
		{
			Hits.AddItemToEnd(i);
		}
		
		point = aPlane.position+aPlane.normal-ray.origin;
		tempOne = direction.Dot(point);
		tempTwo = point.Dot(point);
		if(pow(tempOne, 2) - tempTwo + pow(radius, 2) >= 0)
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
