//
//  CvSeqArr.m
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 06/25/14.
//
//

#include "CvSeqArr.h"

//Constructors
CvSeqArr::CvSeqArr()
{
	arr = NULL;
	Length = 0;
	actualLength = 1;
	startingIndex = 0;
}
CvSeqArr::CvSeqArr(cv::Mat mat)
{
	NSCAssert(mat.cols==1, @"Trying to initialize a CvSeqArr with a mat that is not 1 by n!");
	NSCAssert(mat.type()==CV_64F, @"Trying to initialize a CvSeqArr with a mat that is not CV_64F!");
	
	Length = mat.rows;
	actualLength = Length;
	arr = new CvSeq*[Length];
	startingIndex = 0;
	
	for(int i=0; i<Length; i++)
	{
		arr[i] = mat.at<CvSeq*>(i,1);
	}
}
CvSeqArr::CvSeqArr(int capacity)
{
	NSCAssert(capacity>=0, @"Trying to initialize a CvSeqArr with a capacity less than 0 is not allowed!");
	arr = new CvSeq*[capacity];
	Length = 0;
	actualLength = capacity;
	startingIndex = 0;
}
CvSeqArr::CvSeqArr(int length, CvSeq* initializedValue)
{
	NSCAssert(length>=0, @"Trying to initialize a CvSeqArr with a capacity less than 0 is not allowed!");
	arr = new CvSeq*[length];
	Length = length;
	actualLength = length;
	startingIndex = 0;
	
	for(int i=0; i<length; i++)
	{
		arr[i] = initializedValue;
	}
}

void CvSeqArr::Reset()
{
	Length = 0;
	startingIndex = 0;
}
void CvSeqArr::Optimize()
{
	CvSeq**temp = new CvSeq*[Length];
	for(int n=0, i=startingIndex; n<Length; n++, i++)
	{
		temp[n] = arr[i];
	}
	delete[] arr;
	actualLength = Length;
	startingIndex = 0;
	arr=temp;
}
void CvSeqArr::Deallocate()
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
void CvSeqArr::DoubleCapacityToEnd()
{
	int newActualLength = (actualLength+1)*2;
	if(arr==NULL)
	{
		arr = new CvSeq*[newActualLength];
	}
	else
	{
		CvSeq**temp = new CvSeq*[newActualLength];
		for(int n=0, i=startingIndex; n<Length; n++, i++)
		{
			temp[i] = arr[i];
		}
		delete[] arr;
		arr=temp;
	}
	actualLength = newActualLength;
}
void CvSeqArr::DoubleCapacityToBegining()
{
	int newActualLength = (actualLength+1)*2;
	int newStartingIndex = startingIndex+newActualLength-actualLength;
	if(arr==NULL)
	{
		arr = new CvSeq*[newActualLength];
	}
	else
	{
		CvSeq**temp = new CvSeq*[newActualLength];
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
void CvSeqArr::AddCapacityToEnd(int capacityIncrease)
{
	if(capacityIncrease>0)
	{
		if(arr==NULL)
		{
			arr = new CvSeq*[capacityIncrease];
		}
		else
		{
			CvSeq**temp = new CvSeq*[actualLength+capacityIncrease];
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
void CvSeqArr::AddCapacityToBegining(int capacityIncrease)
{
	if(capacityIncrease>0)
	{
		if(arr==NULL)
		{
			arr = new CvSeq*[capacityIncrease];
			actualLength = capacityIncrease;
		}
		else
		{
			int newActualLength = actualLength+capacityIncrease;
			int newStartingIndex = startingIndex+capacityIncrease;
			CvSeq**temp = new CvSeq*[newActualLength];
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
void CvSeqArr::RemoveFirstItem()
{
	NSCAssert(Length>0, @"Can not remove first item of an array with 0 length!");
	startingIndex++;
	Length--;
}
void CvSeqArr::RemoveFirstItems(int n)
{
	NSCAssert(n>=0, @"Can not remove a negative number of items from an array!");
	NSCAssert(Length-n+1>0, @"Can not remove first items of an array with 0 length!");
	startingIndex+=n;
	Length-=n;
}
void CvSeqArr::RemoveLastItem()
{
	NSCAssert(Length>0, @"Can not remove last item of an array with 0 length!");
	Length--;
}
void CvSeqArr::RemoveLastItems(int n)
{
	NSCAssert(n>=0, @"Can not remove a negative number of items from an array!");
	NSCAssert(Length-n+1>0, @"Can not remove last items of an array with 0 length!");
	Length-=n;
}
void CvSeqArr::RemoveItemAtIndex(int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	CvSeq**temp = new CvSeq*[actualLength];
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
void CvSeqArr::RemoveItemsAtIndexs(intArr indexes)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(indexes.Length>0)
	{
		CvSeq**temp = new CvSeq*[actualLength];
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
void CvSeqArr::RemoveItemsAtIndex(int items, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(items>0)
	{
		index += startingIndex;
		CvSeq**temp = new CvSeq*[actualLength];
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
void CvSeqArr::InsertItemAtIndex(CvSeq* item, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	
	Length++;
	actualLength++;
	index += startingIndex;
	CvSeq**temp = new CvSeq*[actualLength];
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
void CvSeqArr::InsertItemsAtIndex(CvSeqArr items, int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(items.Length>0)
	{
		Length += items.Length;
		index += startingIndex;
		CvSeq**temp = new CvSeq*[actualLength];
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
void CvSeqArr::AddItemToEnd(CvSeq* item)
{
	if(arr==NULL)
	{
		arr = new CvSeq*[1];
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
void CvSeqArr::AddItemsToEnd(CvSeqArr items)
{
	if(arr==NULL)
	{
		arr = new CvSeq*[items.Length];
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
void CvSeqArr::AddItemToBegining(CvSeq* item)
{
	if(arr==NULL)
	{
		arr = new CvSeq*[1];
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
void CvSeqArr::AddItemsToBegining(CvSeqArr items)
{
	if(arr==NULL)
	{
		arr = new CvSeq*[items.Length];
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
CvSeq* CvSeqArr::GetAndRemoveFirstElement()
{
    NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(Length>0, @"Can not GetAndRemoveFirstElement() of a array with 0 length!");
	CvSeq* val = arr[startingIndex];
	RemoveFirstItem();
	return val;
}
CvSeq* CvSeqArr::GetAndRemoveLastElement()
{
    NSCAssert(arr!=NULL, @"Can not use dealocated array!");
    NSCAssert(Length>0, @"Can not GetAndRemoveLastElement() of a array with 0 length!");
	CvSeq* val = arr[startingIndex+Length-1];
	RemoveLastItem();
	return val;
}

//Operators
CvSeq* &CvSeqArr::operator[](int index)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	NSCAssert(index>=startingIndex && index<Length+startingIndex, @"Index out of range!");
	return arr[index+startingIndex];
}
bool CvSeqArr::operator== (CvSeqArr ARR)
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	if(ARR.Length != Length) return false;
	for(int i=0; i<Length; i++)
	{
		if(arr[i]!=ARR[i]) return false;
	}
	return true;
}
bool CvSeqArr::operator!= (CvSeqArr ARR)
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
cv::Mat CvSeqArr::AsCVMat()
{
	NSCAssert(arr!=NULL, @"Can not use dealocated array!");
	cv::Mat cvArr = cv::Mat(Length, 1, CV_64F);
	for(int n=0, i=0; n<Length; n++, i++)
	{
		cvArr.at<CvSeq*>(n,1) = arr[i];
	}
	return cvArr;
}
