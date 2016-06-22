//
//  Vector2Arr.m
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 3/21/12.
//  Copyright (c) 2012 Magna Mirrors. All rights reserved.
//
//	From Array Template created on by Charlie Mehlenbeck on 10/18/13.
//	Please do not add any thing to this class that could be applicable to other classes without as well modifying the template!!!
//	However, some functions or convershions may not be applicable to all types that could be used in this array and those, except any core functionality, may be removed.
//
//

#include "Vector2Arr.h"

//Constructors
Vector2Arr::Vector2Arr()
{
	arr = boost::shared_array<Vector2>(new Vector2[1]);
	Length = 0;
	actualLength = 0;
	startingIndex = 0;
	centerOfMassCalculated = false;
}
Vector2Arr::Vector2Arr(cv::Mat mat)
{
	NSCAssert(mat.cols==1, @"Trying to initialize a Vector2Arr with a mat that is not 1 by n!");
	NSCAssert(mat.type()==CV_64F, @"Trying to initialize a Vector2Arr with a mat that is not CV_64F!");
	
	Length = mat.rows;
	actualLength = Length;
	arr = boost::shared_array<Vector2>(new Vector2[Length]);
	startingIndex = 0;
	
	for(int i=0; i<Length; i++)
	{
		arr[i] = mat.at<Vector2>(i,1);
	}
	centerOfMassCalculated = false;
}
Vector2Arr::Vector2Arr(int capacity)
{
	NSCAssert(capacity>=0, @"Trying to initialize a Vector2Arr with a capacity less than 0 is not allowed!");
	arr = boost::shared_array<Vector2>(new Vector2[capacity]);
	Length = 0;
	actualLength = capacity;
	startingIndex = 0;
	centerOfMassCalculated = false;
}
Vector2Arr::Vector2Arr(int length, Vector2 initializedValue)
{
	NSCAssert(length>=0, @"Trying to initialize a Vector2Arr with a capacity less than 0 is not allowed!");
	arr = boost::shared_array<Vector2>(new Vector2[length]);
	Length = length;
	actualLength = length;
	startingIndex = 0;
	
	for(int i=0; i<length; i++)
	{
		arr[i] = initializedValue;
	}
	centerOfMassCalculated = false;
}
Vector2Arr::Vector2Arr(std::vector<cv::Point2f> points)
{
	Length = (int)points.size();
	actualLength = Length;
	startingIndex = 0;
	
	arr = boost::shared_array<Vector2>(new Vector2[Length]);
	for(int i=0; i<Length; i++)
	{
		arr[i] = Vector2(points[i]);
	}
	
	centerOfMassCalculated = false;
}
Vector2Arr Vector2Arr::Vector2ArrFromSeq(CvSeq* seq)
{
	CvPoint p;
	CvSeqReader reader;
	int N = seq->total;
	cvStartReadSeq(seq, &reader);
	
	
	Vector2Arr points = Vector2Arr(N);
	for(int i=0; i<N; i++)
	{
		CV_READ_SEQ_ELEM(p, reader);
		Vector2 point = Vector2(p.x, p.y);
		points.AddItemToEnd(point);
	}
	return points;
}
Vector2Arr::Vector2Arr(NSString* csv)
{
	NSArray*Lines = [csv componentsSeparatedByString:@"\n"];
	
	Length = 0;
	actualLength = Lines.count;
	startingIndex = 0;
	
	arr = boost::shared_array<Vector2>(new Vector2[actualLength]);
	
	centerOfMassCalculated = false;
	
	for(int i=0; i<Lines.count; i++)
	{
		NSString*line = [Lines objectAtIndex:i];
		NSArray*components = [line componentsSeparatedByString:@","];
		if(components.count==2)
		{
			arr[Length] = Vector2([[components objectAtIndex:0] doubleValue],[[components objectAtIndex:1] doubleValue]);
			Length++;
		}
	}
}
Vector2Arr::Vector2Arr(CvPoint2D32f*points, int count)
{
	Length = count;
	actualLength = count;
	startingIndex = 0;
	
	arr = boost::shared_array<Vector2>(new Vector2[Length]);
	for(int i=0; i<Length; i++)
	{
		arr[i] = Vector2(points[i]);
	}
	
	centerOfMassCalculated = false;
}
Vector2Arr::Vector2Arr(CvSeq* points)
{
	CvPoint p;
	CvSeqReader reader;
	cvStartReadSeq(points, &reader);
	
	Length = points->total;
	actualLength = Length;
	startingIndex = 0;
	
	arr = boost::shared_array<Vector2>(new Vector2[Length]);
	for(int i=0; i<Length; i++)
	{
		CV_READ_SEQ_ELEM(p, reader);
		arr[i] = Vector2(Vector2(p));
	}
	
	centerOfMassCalculated = false;
}
Vector2Arr::Vector2Arr(Vector3Arr ARR)
{
	Length = ARR.Length;
	actualLength = Length;
	startingIndex = 0;
	
	arr = boost::shared_array<Vector2>(new Vector2[Length]);
	
	for(int i=0; i<Length; i++)
	{
		arr[i] = ARR[i].AsVector2();
	}
	
	centerOfMassCalculated = false;
}

void Vector2Arr::Reset()
{
	Length = 0;
	startingIndex = 0;
}
void Vector2Arr::Optimize()
{
	boost::shared_array<Vector2> temp (new Vector2[Length]);
	for(int n=0, i=startingIndex; n<Length; n++, i++)
	{
		temp[n] = arr[i];
	}
	//delete[] arr;
	actualLength = Length;
	startingIndex = 0;
	arr=temp;
}
void Vector2Arr::Deallocate()
{
	if(arr!=NULL)
	{
		//if(actualLength>0) //delete[] arr;
		Length = 0;
		actualLength = 0;
		startingIndex = 0;
		//arr = NULL;
	}
}
void Vector2Arr::DoubleCapacityToEnd()
{
	int newActualLength = (actualLength+1)*2;
	if(arr==NULL)
	{
		arr = boost::shared_array<Vector2>(new Vector2[newActualLength]);
	}
	else
	{
		boost::shared_array<Vector2> temp (new Vector2[newActualLength]);
		for(int i=startingIndex; i<startingIndex+Length; i++)
		{
			temp[i] = arr[i];
		}
		//delete[] arr;
		arr=temp;
	}
	actualLength = newActualLength;
}
void Vector2Arr::DoubleCapacityToBegining()
{
	int newActualLength = (actualLength+1)*2;
	int newStartingIndex = startingIndex+newActualLength-actualLength;
	if(arr==NULL)
	{
		arr = boost::shared_array<Vector2>(new Vector2[newActualLength]);
	}
	else
	{
		boost::shared_array<Vector2> temp (new Vector2[newActualLength]);
		for(int n=0, i=startingIndex, nI=newStartingIndex; n<Length; n++, i++, nI++)
		{
			temp[nI] = arr[i];
		}
		//delete[] arr;
		arr=temp;
	}
	actualLength = newActualLength;
	startingIndex = newStartingIndex;
}
void Vector2Arr::AddCapacityToEnd(int capacityIncrease)
{
	if(capacityIncrease>0)
	{
		if(arr==NULL)
		{
			arr = boost::shared_array<Vector2>(new Vector2[capacityIncrease]);
		}
		else
		{
			boost::shared_array<Vector2> temp (new Vector2[actualLength+capacityIncrease]);
			for(int i=startingIndex; i<startingIndex+Length; i++)
			{
				temp[i] = arr[i];
			}
			//delete[] arr;
			arr=temp;
		}
		actualLength = actualLength+capacityIncrease;
	}
}
void Vector2Arr::AddCapacityToBegining(int capacityIncrease)
{
	if(capacityIncrease>0)
	{
		if(arr==NULL)
		{
			arr = boost::shared_array<Vector2>(new Vector2[capacityIncrease]);
			actualLength = capacityIncrease;
		}
		else
		{
			int newActualLength = actualLength+capacityIncrease;
			int newStartingIndex = startingIndex+capacityIncrease;
			boost::shared_array<Vector2> temp (new Vector2[newActualLength]);
			for(int n=0, i=startingIndex, nI=newStartingIndex; n<Length; n++, i++, nI++)
			{
				temp[nI] = arr[i];
			}
			//delete[] arr;
			arr=temp;
			
			actualLength = newActualLength;
			startingIndex = newStartingIndex;
		}
	}
}
void Vector2Arr::RemoveFirstItem()
{
	NSCAssert(Length>0, @"Can not remove first item of an array with 0 length!");
	startingIndex++;
	Length--;
}
void Vector2Arr::RemoveFirstItems(int n)
{
	NSCAssert(n>=0, @"Can not remove a negative number of items from an array!");
	NSCAssert(Length-n+1>0, @"Can not remove first items of an array with 0 length!");
	startingIndex+=n;
	Length-=n;
}
void Vector2Arr::RemoveLastItem()
{
	NSCAssert(Length>0, @"Can not remove last item of an array with 0 length!");
	Length--;
}
void Vector2Arr::RemoveLastItems(int n)
{
	NSCAssert(n>=0, @"Can not remove a negative number of items from an array!");
	NSCAssert(Length-n+1>0, @"Can not remove last items of an array with 0 length!");
	Length-=n;
}
void Vector2Arr::RemoveItemAtIndex(int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	boost::shared_array<Vector2> temp (new Vector2[actualLength]);
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
	//delete[] arr;
	Length--;
	arr=temp;
}
void Vector2Arr::RemoveItemsAtIndexs(intArr indexes)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(indexes.Length>0)
	{
		boost::shared_array<Vector2> temp (new Vector2[actualLength]);
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
		//delete[] arr;
		Length--;
		arr=temp;
	}
}
void Vector2Arr::RemoveItemsAtIndex(int items, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(items>0)
	{
		index += startingIndex;
		boost::shared_array<Vector2> temp (new Vector2[actualLength]);
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
		//delete[] arr;
		arr=temp;
	}
}
void Vector2Arr::InsertItemAtIndex(Vector2 item, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	
	Length++;
	actualLength++;
	index += startingIndex;
	boost::shared_array<Vector2> temp (new Vector2[actualLength]);
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
	//delete[] arr;
	arr=temp;
}
void Vector2Arr::InsertItemsAtIndex(Vector2Arr items, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(items.Length>0)
	{
		Length += items.Length;
		index += startingIndex;
		boost::shared_array<Vector2> temp (new Vector2[actualLength]);
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
		//delete[] arr;
		arr=temp;
	}
}
void Vector2Arr::AddItemToEnd(Vector2 item)
{
	if(arr==NULL)
	{
		arr = boost::shared_array<Vector2>(new Vector2[1]);
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
void Vector2Arr::AddItemsToEnd(Vector2Arr items)
{
	if(arr==NULL)
	{
		arr = boost::shared_array<Vector2>(new Vector2[items.Length]);
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
void Vector2Arr::AddItemToBegining(Vector2 item)
{
	if(arr==NULL)
	{
		arr = boost::shared_array<Vector2>(new Vector2[1]);
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
void Vector2Arr::AddItemsToBegining(Vector2Arr items)
{
	if(arr==NULL)
	{
		arr = boost::shared_array<Vector2>(new Vector2[items.Length]);
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
Vector2 Vector2Arr::GetAndRemoveFirstElement()
{
    NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(Length>0, @"Can not GetAndRemoveFirstElement() of a array with 0 length!");
	Vector2 val = arr[startingIndex];
	RemoveFirstItem();
	return val;
}
Vector2 Vector2Arr::GetAndRemoveLastElement()
{
    NSCAssert(arr!=NULL, @"Can not use dealocated array!");
    NSCAssert(Length>0, @"Can not GetAndRemoveLastElement() of a array with 0 length!");
	Vector2 val = arr[startingIndex+Length-1];
	RemoveLastItem();
	return val;
}
Vector2Arr Vector2Arr::PointsForIndices(intArr indices)
{
	Vector2Arr points = Vector2Arr(indices.Length);
	for(int i=0; i<indices.Length; i++)
	{
		points.AddItemToEnd( arr[indices[i]] );
	}
	return points;
}
Vector2 Vector2Arr::CenterOfMass()
{
	if(!centerOfMassCalculated)
	{
		centerOfMass = Vector2(0,0);
		for(int i=startingIndex; i<Length+startingIndex; i++)
		{
			centerOfMass = centerOfMass+arr[i];
		}
		if(Length>0) centerOfMass = centerOfMass/Length;
		centerOfMassCalculated = true;
	}
	return centerOfMass;
}
int Vector2Arr::ClosestIndexToPoint(Vector2 point)
{
	int closestIndex = -1;
	float minSqDistance = INFINITY;
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		float sqDist = (arr[i]-point).SqMagnitude();
		if(sqDist<minSqDistance)
		{
			minSqDistance = sqDist;
			closestIndex = i-startingIndex;
		}
	}
	return closestIndex;
}
Vector2 Vector2Arr::FurthestPointAlongDirectionFromLine(Vector2 direction, Line2 line)
{
	float maxSqDistance = 0;
	Vector2 furthestPoint = Vector2(NAN,NAN);
	
	Vector2 perpendicularDirection = line.Perpendicular().DirectionNormalized();
	if(direction.Dot(-perpendicularDirection) > direction.Dot(perpendicularDirection))
	{
		perpendicularDirection = -perpendicularDirection;
	}
	
	for(int i=startingIndex; i<Length+startingIndex; i++)
	{
		Vector2 vert = arr[i];
		if((vert-line.point1).Dot(perpendicularDirection)>0)
		{
			Vector2 projection = line.ProjectionOfPoint(vert);
			float sqDist = (vert-projection).SqMagnitude();
			if(sqDist>maxSqDistance)
			{
				maxSqDistance = sqDist;
				furthestPoint = vert;
			}
		}
	}
	return furthestPoint;
}
NSString* Vector2Arr::description()
{
	NSMutableArray*Lines = [[NSMutableArray alloc] initWithCapacity:Length];
	for(int i=startingIndex; i<startingIndex+Length; i++)
	{
		[Lines addObject:arr[i].csv()];
	}
	NSString*Output = [Lines componentsJoinedByString:@"\n"];
	[Lines release];
	return Output;
}
Vector2Arr arrayWithDescription(NSString* description)
{
	NSArray*components = [description componentsSeparatedByString:@"\n"];
	Vector2Arr output = Vector2Arr(components.count);
	for(int i=0; i<components.count; i++)
	{
		NSString*vect = [components objectAtIndex:i];
		NSArray*vectComponents = [vect componentsSeparatedByString:@","];
		if(vectComponents.count==2)
		{
			NSString*X = [vectComponents objectAtIndex:0];
			NSString*Y = [vectComponents objectAtIndex:1];
			output.AddItemToEnd(Vector2(X.floatValue,Y.floatValue));
		}
	}
	return output;
}

std::vector<cv::Point2f>  Vector2Arr::asCVContour()
{
    std::vector<cv::Point2f> ret;
    for(int i = 0; i < Length; i++)
    {
        ret.push_back(arr[i].AsCvPoint());
    }
    return ret;
}

//Operators
Vector2 &Vector2Arr::operator[](int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(index>=startingIndex && index<Length+startingIndex, @"Index out of range!");
	return arr[index+startingIndex];
}
bool Vector2Arr::operator== (Vector2Arr ARR)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(ARR.Length != Length) return false;
	for(int i=0; i<Length; i++)
	{
		if(arr[i]!=ARR[i]) return false;
	}
	return true;
}
bool Vector2Arr::operator!= (Vector2Arr ARR)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(ARR.Length != Length) return true;
	for(int i=0; i<Length; i++)
	{
		if(arr[i]!=ARR[i]) return true;
	}
	return false;
}

//Convershions
cv::Mat Vector2Arr::AsCVMat()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	cv::Mat cvArr = cv::Mat(Length, 1, CV_64F);
	for(int n=0, i=0; n<Length; n++, i++)
	{
		cvArr.at<Vector2>(n,1) = arr[i];
	}
	return cvArr;
}
NSString* Vector2Arr::csv()
{
	NSString*csv = @"";
	
	for(int i=startingIndex; i<startingIndex+Length; i++)
	{
		Vector2 vect = arr[i];
		csv = [csv stringByAppendingString:[NSString stringWithFormat:@"%@%f,%f",i>0?@"\n":@"",vect.x,vect.y]];
	}
	
	return csv;
}





