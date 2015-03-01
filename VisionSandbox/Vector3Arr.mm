//
//  Vector3Arr.mm
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 3/19/13.
//
//
//	From Array Template created on by Charlie Mehlenbeck on 10/18/13.
//	Please do not add any thing to this class that could be applicable to other classes without as well modifying the template!!!
//	However, some functions or convershions may not be applicable to all types that could be used in this array and those, except any core functionality, may be removed.
//
//

#include "Vector3Arr.h"

//Constructors
Vector3Arr::Vector3Arr()
{
	arr = NULL;
	Length = 0;
	actualLength = 1;
	startingIndex = 0;
}
Vector3Arr::Vector3Arr(cv::Mat mat)
{
	NSCAssert(mat.cols==1, @"Trying to initialize a Vector3Arr with a mat that is not 1 by n!");
	NSCAssert(mat.type()==CV_64F, @"Trying to initialize a Vector3Arr with a mat that is not CV_64F!");
	
	Length = mat.rows;
	actualLength = Length;
	arr = new Vector3[Length];
	startingIndex = 0;
	
	for(int i=0; i<Length; i++)
	{
		arr[i] = mat.at<Vector3>(i,1);
	}
}
Vector3Arr::Vector3Arr(int capacity)
{
	NSCAssert(capacity>=0, @"Trying to initialize a Vector3Arr with a capacity less than 0 is not allowed!");
	arr = new Vector3[capacity];
	Length = 0;
	actualLength = capacity;
	startingIndex = 0;
}
Vector3Arr::Vector3Arr(int length, Vector3 initializedValue)
{
	NSCAssert(length>=0, @"Trying to initialize a Vector3Arr with a capacity less than 0 is not allowed!");
	arr = new Vector3[length];
	Length = length;
	actualLength = length;
	startingIndex = 0;
	
	for(int i=0; i<length; i++)
	{
		arr[i] = initializedValue;
	}
}

void Vector3Arr::Reset()
{
	Length = 0;
	startingIndex = 0;
}
void Vector3Arr::Optimize()
{
	Vector3*temp = new Vector3[Length];
	for(int n=0, i=startingIndex; n<Length; n++, i++)
	{
		temp[n] = arr[i];
	}
	delete[] arr;
	actualLength = Length;
	startingIndex = 0;
	arr=temp;
}
void Vector3Arr::Deallocate()
{
	if(arr!=NULL)
	{
		if(actualLength>0) delete[] arr;
		Length = 0;
		actualLength = 0;
		startingIndex = 0;
		arr = NULL;
	}
}
void Vector3Arr::DoubleCapacityToEnd()
{
	int newActualLength = (actualLength+1)*2;
	if(arr==NULL)
	{
		arr = new Vector3[newActualLength];
	}
	else
	{
		Vector3*temp = new Vector3[newActualLength];
		for(int n=0, i=startingIndex; n<Length; n++, i++)
		{
			temp[i] = arr[i];
		}
		delete[] arr;
		arr=temp;
	}
	actualLength = newActualLength;
}
void Vector3Arr::DoubleCapacityToBegining()
{
	int newActualLength = (actualLength+1)*2;
	int newStartingIndex = startingIndex+newActualLength-actualLength;
	if(arr==NULL)
	{
		arr = new Vector3[newActualLength];
	}
	else
	{
		Vector3*temp = new Vector3[newActualLength];
		for(int n=0, i=startingIndex, nI=newStartingIndex; n<Length; n++, i++, nI++)
		{
			temp[nI] = arr[i];
		}
		delete[] arr;
		arr=temp;
	}
	actualLength = newActualLength;
	startingIndex = newStartingIndex;
}
void Vector3Arr::AddCapacityToEnd(int capacityIncrease)
{
	if(capacityIncrease>0)
	{
		if(arr==NULL)
		{
			arr = new Vector3[capacityIncrease];
		}
		else
		{
			Vector3*temp = new Vector3[actualLength+capacityIncrease];
			for(int n=0, i=startingIndex; n<Length; n++, i++)
			{
				temp[i] = arr[i];
			}
			delete[] arr;
			arr=temp;
		}
		actualLength = actualLength+capacityIncrease;
		
	}
}
void Vector3Arr::AddCapacityToBegining(int capacityIncrease)
{
	if(capacityIncrease>0)
	{
		if(arr==NULL)
		{
			arr = new Vector3[capacityIncrease];
			actualLength = capacityIncrease;
		}
		else
		{
			int newActualLength = actualLength+capacityIncrease;
			int newStartingIndex = startingIndex+capacityIncrease;
			Vector3*temp = new Vector3[newActualLength];
			for(int n=0, i=startingIndex, nI=newStartingIndex; n<Length; n++, i++, nI++)
			{
				temp[nI] = arr[i];
			}
			delete[] arr;
			arr=temp;
			
			actualLength = newActualLength;
			startingIndex = newStartingIndex;
		}
	}
}
void Vector3Arr::RemoveFirstItem()
{
	NSCAssert(Length>0, @"Can not remove first item of an array with 0 length!");
	startingIndex++;
	Length--;
}
void Vector3Arr::RemoveFirstItems(int n)
{
	NSCAssert(n>=0, @"Can not remove a negative number of items from an array!");
	NSCAssert(Length-n+1>0, @"Can not remove first items of an array with 0 length!");
	startingIndex+=n;
	Length-=n;
}
void Vector3Arr::RemoveLastItem()
{
	NSCAssert(Length>0, @"Can not remove last item of an array with 0 length!");
	Length--;
}
void Vector3Arr::RemoveLastItems(int n)
{
	NSCAssert(n>=0, @"Can not remove a negative number of items from an array!");
	NSCAssert(Length-n+1>0, @"Can not remove last items of an array with 0 length!");
	Length-=n;
}
void Vector3Arr::RemoveItemAtIndex(int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	Vector3*temp = new Vector3[actualLength];
	int nI = startingIndex;
	index += startingIndex;
	for(int n=0, i=startingIndex; n<Length; n++, i++)
	{
		if(i!=index)
		{
			temp[nI] = arr[i];
			nI++;
		}
	}
	delete[] arr;
	Length--;
	arr=temp;
}
void Vector3Arr::RemoveItemsAtIndexs(intArr indexes)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(indexes.Length>0)
	{
		Vector3*temp = new Vector3[actualLength];
		int nI = startingIndex;
		int index = indexes[0]+startingIndex;
		for(int n=0, i=startingIndex, rI=1; n<Length; n++, i++)
		{
			if(i!=index)
			{
				temp[nI] = arr[i];
				nI++;
			}
			else if(rI<indexes.Length)
			{
				index = indexes[rI]+startingIndex;
				rI++;
			}
		}
		delete[] arr;
		Length--;
		arr=temp;
	}
}
void Vector3Arr::RemoveItemsAtIndex(int items, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(items>0)
	{
		index += startingIndex;
		Vector3*temp = new Vector3[actualLength];
		int indexAndItemsLength = index+items;
		for(int n=0, nI=startingIndex, oI = startingIndex, itemsIndex=0; n<Length; n++, oI++)
		{
			if(oI<index || oI>=indexAndItemsLength)
			{
				temp[nI] = arr[oI];
				nI++;
			}
		}
		Length -= items;
		delete[] arr;
		arr=temp;
	}
}
void Vector3Arr::InsertItemAtIndex(Vector3 item, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	
	Length++;
	actualLength++;
	index += startingIndex;
	Vector3*temp = new Vector3[actualLength];
	for(int n=0, i=startingIndex, nI = startingIndex; n<Length; n++, nI++)
	{
		if(nI!=index)
		{
			temp[nI] = arr[i];
			i++;
		}
		else
		{
			temp[nI] = item;
		}
	}
	delete[] arr;
	arr=temp;
}
void Vector3Arr::InsertItemsAtIndex(Vector3Arr items, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(items.Length>0)
	{
		Length += items.Length;
		index += startingIndex;
		Vector3*temp = new Vector3[actualLength];
		int indexAndItemsLength = index+items.Length;
		for(int n=0, i=startingIndex, nI = startingIndex, itemsIndex=0; n<Length; n++, nI++)
		{
			if(nI<index || nI>=indexAndItemsLength)
			{
				temp[nI] = arr[i];
				i++;
			}
			else
			{
				temp[nI] = items[itemsIndex];
				itemsIndex++;
			}
		}
		delete[] arr;
		arr=temp;
	}
}
void Vector3Arr::AddItemToEnd(Vector3 item)
{
	if(arr==NULL)
	{
		arr = new Vector3[1];
		arr[0] = item;
		
		actualLength = 1;
		Length = 1;
	}
	else
	{
		if(actualLength-startingIndex<=Length)
		{
			DoubleCapacityToEnd();
		}
		arr[Length+startingIndex] = item;
		Length++;
	}
}
void Vector3Arr::AddItemsToEnd(Vector3Arr items)
{
	if(arr==NULL)
	{
		arr = new Vector3[items.Length];
		for(int i=0; i<items.Length; i++)
		{
			arr[i] = items[i];
		}
		
		actualLength = items.Length;
		Length = items.Length;
	}
	else
	{
		if(actualLength-startingIndex<=Length+items.Length)
		{
			AddCapacityToEnd(items.Length);
		}
		for(int n=0, i=startingIndex+Length; n<items.Length; n++, i++)
		{
			arr[i] = items[n];
		}
		Length+=items.Length;
	}
}
void Vector3Arr::AddItemToBegining(Vector3 item)
{
	if(arr==NULL)
	{
		arr = new Vector3[1];
		arr[0] = item;
		
		actualLength = 1;
		Length = 1;
	}
	else
	{
		if(startingIndex<=0)
		{
			DoubleCapacityToBegining();
		}
		startingIndex--;
		arr[startingIndex] = item;
		Length++;
	}
}
void Vector3Arr::AddItemsToBegining(Vector3Arr items)
{
	if(arr==NULL)
	{
		arr = new Vector3[items.Length];
		for(int i=0; i<items.Length; i++)
		{
			arr[i] = items[i];
		}
		
		actualLength = items.Length;
		Length = items.Length;
	}
	else
	{
		if(startingIndex<items.Length)
		{
			AddCapacityToBegining(items.Length);
		}
		startingIndex-=items.Length;
		for(int n=0, i=startingIndex; n<items.Length; n++, i++)
		{
			arr[i] = items[n];
		}
		Length+=items.Length;
	}
}
Vector3 Vector3Arr::GetAndRemoveFirstElement()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(Length>0, @"Can not GetAndRemoveFirstElement() of a array with 0 length!");
	Vector3 val = arr[startingIndex];
	RemoveFirstItem();
	return val;
}
Vector3 Vector3Arr::GetAndRemoveLastElement()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(Length>0, @"Can not GetAndRemoveLastElement() of a array with 0 length!");
	Vector3 val = arr[startingIndex+Length-1];
	RemoveLastItem();
	return val;
}
Vector3Arr Vector3Arr::Clone()
{
	Vector3Arr clone = Vector3Arr(Length);
	for(int i=0, n=startingIndex; i<Length; i++, n++)
	{
		clone.AddItemToEnd(arr[n]);
	}
	return clone;
}

Vector3Arr Vector3Arr::PointsForIndices(intArr indices)
{
	Vector3Arr points = Vector3Arr(indices.Length);
	for(int i=0; i<indices.Length; i++)
	{
		points.AddItemToEnd( arr[indices[i]] );
	}
	return points;
}
Vector3Arr Vector3Arr::RaycastPointsForPointsWithRadiusRay(float radius, Ray3 ray)
{
	Vector3Arr Hits = Vector3Arr();
	Vector3 direction = ray.direction;
	
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		Vector3 point = arr[i]-ray.origin;
		float tempOne = direction.Dot(point);
		float tempTwo = point.Dot(point);
		if(pow(tempOne, 2) - tempTwo + pow(radius, 2) >= 0)
		{
			Hits.AddItemToEnd(point+ray.origin);
		}
	}
	
	return Hits;
}
intArr Vector3Arr::RaycastPointsForIndexesWithRadiusRay(float radius, Ray3 ray)
{
	intArr Hits = intArr();
	Vector3 direction = ray.direction;
	
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		Vector3 point = arr[i]-ray.origin;
		float tempOne = direction.Dot(point);
		float tempTwo = point.Dot(point);
		if(pow(tempOne, 2) - tempTwo + pow(radius, 2) >= 0)
		{
			Hits.AddItemToEnd(i);
		}
	}
	
	return Hits;
}
int Vector3Arr::ClosestIndexToPoint(Vector3 point)
{
	int closestIndex = -1;
	float smallestSqDistance = INFINITY;
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		float mag = (arr[i]-point).SqMagnitude();
		if(mag<smallestSqDistance)
		{
			closestIndex = i;
			smallestSqDistance = mag;
		}
	}
	
	return closestIndex;
}
Vector3 Vector3Arr::ClosestPointToPoint(Vector3 point)
{
	Vector3 closestPoint = Vector3(NAN,NAN,NAN);
	float smallestSqDistance = INFINITY;
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		Vector3 p = arr[i];
		float mag = (p-point).SqMagnitude();
		if(mag<smallestSqDistance)
		{
			closestPoint = p;
			smallestSqDistance = mag;
		}
	}
	
	return closestPoint;
}
int Vector3Arr::ClosestIndexToPointOfIndexes(Vector3 point, intArr indexes)
{
	int closestIndex = -1;
	float smallestSqDistance = INFINITY;
	for(int i=0; i<indexes.Length; i++)
	{
		int index = indexes[i];
		float mag = (arr[index]-point).SqMagnitude();
		if(mag<smallestSqDistance)
		{
			closestIndex = index;
			smallestSqDistance = mag;
		}
	}
	
	return closestIndex;
}
Vector3 Vector3Arr::ClosestPointToPointOfIndexes(Vector3 point, intArr indexes)
{
	Vector3 closestPoint = point;
	float smallestSqDistance = INFINITY;
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		int index = indexes[i];
		Vector3 p = arr[index];
		float mag = (p-point).SqMagnitude();
		if(mag<smallestSqDistance)
		{
			closestPoint = p;
			smallestSqDistance = mag;
		}
	}
	
	return closestPoint;
}
int Vector3Arr::ClosestIndexToRay(Ray3 ray)
{
	int closestIndex = -1;
	float smallestSqDistance = INFINITY;
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		Vector3 point = arr[i];
		Vector3 pointProjected = ray.ProjectionOfPoint(point);
		if((pointProjected-ray.origin).Dot(ray.direction)>0)
		{
			float mag = (pointProjected-point).SqMagnitude();
			if(mag<smallestSqDistance)
			{
				closestIndex = i;
				smallestSqDistance = mag;
			}
		}
	}
	
	return closestIndex;
}
Vector3 Vector3Arr::ClosestPointToRay(Ray3 ray)
{
	Vector3 closestPoint = Vector3(NAN,NAN,NAN);
	float smallestSqDistance = INFINITY;
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		Vector3 point = arr[i+startingIndex];
		Vector3 pointProjected = ray.ProjectionOfPoint(point);
		if((pointProjected-ray.origin).Dot(ray.direction)>0)
		{
			float mag = (pointProjected-point).SqMagnitude();
			if(mag<smallestSqDistance)
			{
				closestPoint = point;
				smallestSqDistance = mag;
			}
		}
	}
	
	return closestPoint;
}
NSString*Vector3Arr::csv()
{
	if(Length>0)
	{
		Vector3 point = arr[startingIndex];
		
		NSMutableString*mutableString = [NSMutableString stringWithFormat:@"%f,%f,%f",point.x,point.y,point.z];
		
		for(int i=startingIndex+1; i<startingIndex+Length; i++)
		{
			Vector3 point = arr[i];
			[mutableString appendFormat:@"\n%f,%f,%f",point.x,point.y,point.z];
		}
		return [NSString stringWithString:mutableString];
	}
	return @"";
}

Vector3 Vector3Arr::Centroid()
{
	Vector3 centroid = Vector3(NAN,NAN,NAN);
	if(Length>0)
	{
		centroid = Vector3(0,0,0);
		for(int i=startingIndex; i<Length+startingIndex; i++)
		{
			centroid += arr[i];
		}
		centroid = centroid/Length;
	}
	return centroid;
}

void Vector3Arr::SetCentroidTo(Vector3 newCentroid)
{
	Vector3 centroid = Centroid();
	*this += newCentroid-centroid;
}

//Operators
Vector3 &Vector3Arr::operator[](int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(index>=startingIndex && index<Length+startingIndex, @"Index out of range!");
	return arr[index+startingIndex];
}
bool Vector3Arr::operator== (Vector3Arr ARR)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(ARR.Length != Length) return false;
	for(int i=startingIndex, cI=0; i<Length+startingIndex; i++, cI++)
	{
		if(arr[i]!=ARR[cI]) return false;
	}
	return true;
}
bool Vector3Arr::operator!= (Vector3Arr ARR)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(ARR.Length != Length) return true;
	for(int i=startingIndex, cI=0; i<Length+startingIndex; i++, cI++)
	{
		if(arr[i]!=ARR[cI]) return true;
	}
	return false;
}
void Vector3Arr::operator+= (Vector3 delta)
{
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		arr[i] += delta;
	}
}
void Vector3Arr::operator-= (Vector3 delta)
{
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		arr[i] -= delta;
	}
}
Vector3Arr Vector3Arr::operator+ (Vector3 delta)
{
	Vector3Arr outArr = Vector3Arr(Length);
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		outArr.AddItemToEnd(arr[i] + delta);
	}
	return outArr;
}
Vector3Arr Vector3Arr::operator- (Vector3 delta)
{
	Vector3Arr outArr = Vector3Arr(Length);
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		outArr.AddItemToEnd(arr[i] - delta);
	}
	return outArr;
}
Vector3Arr Vector3Arr::operator* (GLKQuaternion rotation)
{
	Vector3Arr outArr = Vector3Arr(Length);
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		outArr.AddItemToEnd(Vector3( GLKQuaternionRotateVector3(rotation, arr[i].AsGLKVector3()) ));
	}
	return outArr;
}
//Convershions
cv::Mat Vector3Arr::AsCVMat()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	cv::Mat cvArr = cv::Mat(Length, 3, CV_32F);
	for(int n=0, i=startingIndex; n<Length; n++, i++)
	{
		Vector3 vect = arr[i];
		cvArr.at<float>(n,0) = vect.x;
		cvArr.at<float>(n,1) = vect.y;
		cvArr.at<float>(n,2) = vect.z;
	}
	return cvArr;
}
std::vector<cv::Point3f> Vector3Arr::AsPointVector()
{
	std::vector<cv::Point3f> points(Length);
	for(int n=0, i=startingIndex; n<Length; n++, i++)
	{
		points.push_back( arr[i].cvPoint3f() );
	}
	return points;
}