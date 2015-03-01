//
//  intArr.m
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 3/21/12.
//  Copyright (c)2012 Magna Mirrors. All rights reserved.
//
//	From Array Template created on by Charlie Mehlenbeck on 10/18/13.
//	Please do not add any thing to this class that could be applicable to other classes without as well modifying the template!!!
//	However, some functions or convershions may not be applicable to all types that could be used in this array and those, except any core functionality, may be removed.
//
//

#include "intArr.h"

//Constructors
intArr::intArr()
{
	arr = NULL;
	Length = 0;
	actualLength = 1;
	startingIndex = 0;
}
intArr::intArr(cv::Mat mat)
{
	NSCAssert(mat.cols==1, @"Trying to initialize a intArr with a mat that is not 1 by n!");
	NSCAssert(mat.type()==CV_64F, @"Trying to initialize a intArr with a mat that is not CV_64F!");
	
	Length = mat.rows;
	actualLength = Length;
	arr = new int[Length];
	startingIndex = 0;
	
	for(int i=0; i<Length; i++)
	{
		arr[i] = mat.at<int>(i,1);
	}
}
intArr::intArr(int capacity)
{
	NSCAssert(capacity>=0, @"Trying to initialize a intArr with a capacity less than 0 is not allowed!");
	arr = new int[capacity];
	Length = 0;
	actualLength = capacity;
	startingIndex = 0;
}
intArr::intArr(int length, int initializedValue)
{
	NSCAssert(length>=0, @"Trying to initialize a intArr with a capacity less than 0 is not allowed!");
	arr = new int[length];
	Length = length;
	actualLength = length;
	startingIndex = 0;
	
	for(int i=0; i<length; i++)
	{
		arr[i] = initializedValue;
	}
}

void intArr::Reset()
{
	Length = 0;
	startingIndex = 0;
}
void intArr::Optimize()
{
	int*temp = new int[Length];
	for(int n=0, i=startingIndex; n<Length; n++, i++)
	{
		temp[n] = arr[i];
	}
	delete[] arr;
	actualLength = Length;
	startingIndex = 0;
	arr=temp;
}
void intArr::Deallocate()
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
void intArr::DoubleCapacityToEnd()
{
	int newActualLength = (actualLength+1)*2;
	if(arr==NULL)
	{
		arr = new int[newActualLength];
	}
	else
	{
		int*temp = new int[newActualLength];
		for(int n=0, i=startingIndex; n<Length; n++, i++)
		{
			temp[i] = arr[i];
		}
		delete[] arr;
		arr=temp;
	}
	actualLength = newActualLength;
}
void intArr::DoubleCapacityToBegining()
{
	int newActualLength = (actualLength+1)*2;
	int newStartingIndex = startingIndex+newActualLength-actualLength;
	if(arr==NULL)
	{
		arr = new int[newActualLength];
	}
	else
	{
		int*temp = new int[newActualLength];
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
void intArr::AddCapacityToEnd(int capacityIncrease)
{
	if(capacityIncrease>0)
	{
		if(arr==NULL)
		{
			arr = new int[capacityIncrease];
		}
		else
		{
			int*temp = new int[actualLength+capacityIncrease];
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
void intArr::AddCapacityToBegining(int capacityIncrease)
{
	if(capacityIncrease>0)
	{
		if(arr==NULL)
		{
			arr = new int[capacityIncrease];
			actualLength = capacityIncrease;
		}
		else
		{
			int newActualLength = actualLength+capacityIncrease;
			int newStartingIndex = startingIndex+capacityIncrease;
			int*temp = new int[newActualLength];
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
void intArr::RemoveFirstItem()
{
	NSCAssert(Length>0, @"Can not remove first item of an array with 0 length!");
	startingIndex++;
	Length--;
}
void intArr::RemoveFirstItems(int n)
{
	NSCAssert(n>=0, @"Can not remove a negative number of items from an array!");
	NSCAssert(Length-n+1>0, @"Can not remove first items of an array with 0 length!");
	startingIndex+=n;
	Length-=n;
}
void intArr::RemoveLastItem()
{
	NSCAssert(Length>0, @"Can not remove last item of an array with 0 length!");
	Length--;
}
void intArr::RemoveLastItems(int n)
{
	NSCAssert(n>=0, @"Can not remove a negative number of items from an array!");
	NSCAssert(Length-n+1>0, @"Can not remove last items of an array with 0 length!");
	Length-=n;
}
void intArr::RemoveItemAtIndex(int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	int*temp = new int[actualLength];
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
void intArr::RemoveItemsAtIndexs(intArr indexes)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(indexes.Length>0)
	{
		int*temp = new int[actualLength];
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
void intArr::RemoveItemsAtIndex(int items, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(items>0)
	{
		index += startingIndex;
		int*temp = new int[actualLength];
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
void intArr::InsertItemAtIndex(int item, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	
	Length++;
	actualLength++;
	index += startingIndex;
	int*temp = new int[actualLength];
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
void intArr::InsertItemsAtIndex(intArr items, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(items.Length>0)
	{
		Length += items.Length;
		index += startingIndex;
		int*temp = new int[actualLength];
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
void intArr::AddItemToEnd(int item)
{
	if(arr==NULL)
	{
		arr = new int[1];
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
void intArr::AddItemsToEnd(intArr items)
{
	if(arr==NULL)
	{
		arr = new int[items.Length];
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
void intArr::AddItemToBegining(int item)
{
	if(arr==NULL)
	{
		arr = new int[1];
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
void intArr::AddItemsToBegining(intArr items)
{
	if(arr==NULL)
	{
		arr = new int[items.Length];
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
int intArr::GetAndRemoveFirstElement()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(Length>0, @"Can not GetAndRemoveFirstElement() of a array with 0 length!");
	int val = arr[startingIndex];
	RemoveFirstItem();
	return val;
}
int intArr::GetAndRemoveLastElement()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(Length>0, @"Can not GetAndRemoveLastElement() of a array with 0 length!");
	int val = arr[startingIndex+Length-1];
	RemoveLastItem();
	return val;
}

//Operators
int &intArr::operator[](int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(index>=startingIndex && index<Length+startingIndex, @"Index out of range!");
	return arr[index+startingIndex];
}
bool intArr::operator== (intArr ARR)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(ARR.Length != Length) return false;
	for(int i=0; i<Length; i++)
	{
		if(arr[i]!=ARR[i]) return false;
	}
	return true;
}
bool intArr::operator!= (intArr ARR)
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
cv::Mat intArr::AsCVMat()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	cv::Mat cvArr = cv::Mat(Length, 1, CV_64F);
	for(int n=0, i=0; n<Length; n++, i++)
	{
		cvArr.at<int>(n,1) = arr[i];
	}
	return cvArr;
}
