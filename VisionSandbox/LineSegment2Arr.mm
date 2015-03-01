//
//  LineSegment2Arr.mm
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 1/9/14.
//
//
//	From Array Template created on by Charlie Mehlenbeck on 10/18/13.
//	Please do not add any thing to this class that could be applicable to other classes without as well modifying the template!!!
//	However, some functions or convershions may not be applicable to all types that could be used in this array and those, except any core functionality, may be removed.
//
//

#include "LineSegment2Arr.h"

//Constructors
LineSegment2Arr::LineSegment2Arr()
{
	arr = boost::shared_array<LineSegment2>(new LineSegment2[0]);
	Length = 0;
	actualLength = 0;
	startingIndex = 0;
}
LineSegment2Arr::LineSegment2Arr(int capacity)
{
	NSCAssert(capacity>=0, @"Trying to initialize a LineSegment2Arr with a capacity less than 0 is not allowed!");
	arr = boost::shared_array<LineSegment2>(new LineSegment2[capacity]);
	Length = 0;
	actualLength = capacity;
	startingIndex = 0;
}
LineSegment2Arr::LineSegment2Arr(int length, LineSegment2 initializedValue)
{
	NSCAssert(length>=0, @"Trying to initialize a LineSegment2Arr with a capacity less than 0 is not allowed!");
	arr = boost::shared_array<LineSegment2>(new LineSegment2[length]);
	Length = length;
	actualLength = length;
	startingIndex = 0;
	
	for(int i=0; i<length; i++)
	{
		arr[i] = initializedValue;
	}
}

void LineSegment2Arr::Reset()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	Length = 0;
	startingIndex = 0;
}
void LineSegment2Arr::Optimize()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	boost::shared_array<LineSegment2> temp (new LineSegment2[Length]);
	for(int n=0, i=startingIndex; n<Length; n++, i++)
	{
		temp[n] = arr[i];
	}
	//delete[] arr;
	actualLength = Length;
	startingIndex = 0;
	arr=temp;
}
void LineSegment2Arr::Deallocate()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	Length = 0;
	actualLength = 0;
	startingIndex = 0;
	//delete[] arr;
	//arr = NULL;
}
void LineSegment2Arr::DoubleCapacityToEnd()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	int newActualLength = (actualLength+1)*2;
	boost::shared_array<LineSegment2> temp (new LineSegment2[newActualLength]);
	for(int n=0, i=startingIndex; n<Length; n++, i++)
	{
		temp[i] = arr[i];
	}
	//delete[] arr;
	actualLength = newActualLength;
	arr=temp;
}
void LineSegment2Arr::DoubleCapacityToBegining()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	int newActualLength = (actualLength+1)*2;
	int newStartingIndex = startingIndex+newActualLength-actualLength;
	boost::shared_array<LineSegment2> temp (new LineSegment2[newActualLength]);
	for(int n=0, i=startingIndex, nI=newStartingIndex; n<Length; n++, i++, nI++)
	{
		temp[nI] = arr[i];
	}
	//delete[] arr;
	actualLength = newActualLength;
	startingIndex = newStartingIndex;
	arr=temp;
}
void LineSegment2Arr::AddCapacityToEnd(int capacityIncrease)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(capacityIncrease>0)
	{
		boost::shared_array<LineSegment2> temp (new LineSegment2[actualLength+capacityIncrease]);
		for(int n=0, i=startingIndex; n<Length; n++, i++)
		{
			temp[i] = arr[i];
		}
		//delete[] arr;
		actualLength = actualLength+capacityIncrease;
		arr=temp;
	}
}
void LineSegment2Arr::AddCapacityToBegining(int capacityIncrease)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(capacityIncrease>0)
	{
		int newActualLength = actualLength+capacityIncrease;
		int newStartingIndex = startingIndex+capacityIncrease;
		boost::shared_array<LineSegment2> temp (new LineSegment2[newActualLength]);
		for(int n=0, i=startingIndex, nI=newStartingIndex; n<Length; n++, i++, nI++)
		{
			temp[nI] = arr[i];
		}
		//delete[] arr;
		actualLength = newActualLength;
		startingIndex = newStartingIndex;
		arr=temp;
	}
}
void LineSegment2Arr::RemoveFirstItem()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
    NSCAssert(Length>0, @"Can not remove first item of an array with 0 length!");
	startingIndex++;
	Length--;
}
void LineSegment2Arr::RemoveFirstItems(int n)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(n>=0, @"Can not remove a negative number of items from an array!");
    NSCAssert(Length-n+1>0, @"Can not remove first items of an array with 0 length!");
	startingIndex+=n;
	Length-=n;
}
void LineSegment2Arr::RemoveLastItem()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
    NSCAssert(Length>0, @"Can not remove last item of an array with 0 length!");
	Length--;
}
void LineSegment2Arr::RemoveLastItems(int n)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(n>=0, @"Can not remove a negative number of items from an array!");
    NSCAssert(Length-n+1>0, @"Can not remove last items of an array with 0 length!");
	Length-=n;
}
void LineSegment2Arr::RemoveItemAtIndex(int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	boost::shared_array<LineSegment2> temp (new LineSegment2[actualLength]);
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
void LineSegment2Arr::RemoveItemsAtIndexs(intArr indexes)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(indexes.Length>0)
	{
		boost::shared_array<LineSegment2> temp (new LineSegment2[actualLength]);
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
void LineSegment2Arr::RemoveItemsAtIndex(int items, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(items>0)
	{
		index += startingIndex;
		boost::shared_array<LineSegment2> temp (new LineSegment2[actualLength]);
		int indexAndItemsLength = index+items;
		for(int n=0, nI=startingIndex, oI = startingIndex; n<Length; n++, oI++)
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
void LineSegment2Arr::InsertItemAtIndex(LineSegment2 item, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	
	Length++;
	actualLength++;
	index += startingIndex;
	boost::shared_array<LineSegment2> temp (new LineSegment2[actualLength]);
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
void LineSegment2Arr::InsertItemsAtIndex(LineSegment2Arr items, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(items.Length>0)
	{
		Length += items.Length;
		actualLength += items.Length;
		index += startingIndex;
		boost::shared_array<LineSegment2> temp (new LineSegment2[actualLength]);
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
void LineSegment2Arr::AddItemToEnd(LineSegment2 item)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(actualLength-startingIndex<=Length)
	{
		DoubleCapacityToEnd();
	}
	arr[Length+startingIndex] = item;
	Length++;
}
void LineSegment2Arr::AddItemsToEnd(LineSegment2Arr items)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
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
void LineSegment2Arr::AddItemToBegining(LineSegment2 item)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(startingIndex<=0)
	{
		DoubleCapacityToBegining();
	}
	startingIndex--;
	arr[startingIndex] = item;
	Length++;
}
void LineSegment2Arr::AddItemsToBegining(LineSegment2Arr items)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
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
LineSegment2 LineSegment2Arr::GetAndRemoveFirstElement()
{
    NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(Length>0, @"Can not GetAndRemoveFirstElement() of a array with 0 length!");
	LineSegment2 val = arr[startingIndex];
	RemoveFirstItem();
	return val;
}
LineSegment2 LineSegment2Arr::GetAndRemoveLastElement()
{
    NSCAssert(arr!=NULL, @"Can not use dealocated array!");
    NSCAssert(Length>0, @"Can not GetAndRemoveLastElement() of a array with 0 length!");
	LineSegment2 val = arr[startingIndex+Length-1];
	RemoveLastItem();
	return val;
}

//Operators
LineSegment2 &LineSegment2Arr::operator[](int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(index>=startingIndex && index<Length+startingIndex, @"Index out of range!");
	return arr[index+startingIndex];
}
bool LineSegment2Arr::operator== (LineSegment2Arr ARR)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(ARR.Length != Length) return false;
	for(int i=0; i<Length; i++)
	{
		if(arr[i]!=ARR[i]) return false;
	}
	return true;
}
bool LineSegment2Arr::operator!= (LineSegment2Arr ARR)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(ARR.Length != Length) return true;
	for(int i=0; i<Length; i++)
	{
		if(arr[i]!=ARR[i]) return true;
	}
	return false;
}
