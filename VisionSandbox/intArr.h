//
//  intArr.h
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

#import <Foundation/Foundation.h>

#ifndef intArr_H_
#define intArr_H_
class intArr
{
private:
	int actualLength;
	int startingIndex;
	
public:
	int*arr;
	int Length;
	
	intArr();
	intArr(cv::Mat mat);
	intArr(int capacity);
	intArr(int length, int initializedValue);
	
	//Functions
	void Reset();
	void Optimize();
	void Deallocate();
	void DoubleCapacityToEnd();
	void DoubleCapacityToBegining();
	void AddCapacityToEnd(int capacityIncrease);
	void AddCapacityToBegining(int capacityIncrease);
	void RemoveFirstItem();
	void RemoveFirstItems(int n);
	void RemoveLastItem();
	void RemoveLastItems(int n);
	void RemoveItemAtIndex(int index);
	void RemoveItemsAtIndexs(intArr indexes);
	void RemoveItemsAtIndex(int items, int index);
	void InsertItemAtIndex(int item, int index);
	void InsertItemsAtIndex(intArr items, int index);
	void AddItemToEnd(int item);
	void AddItemsToEnd(intArr items);
	void AddItemToBegining(int item);
	void AddItemsToBegining(intArr items);
	int GetAndRemoveFirstElement();
	int GetAndRemoveLastElement();
	
	//Operators
	int &operator[](int index);
	const int &operator[](int index) const;
	bool operator== (intArr ARR);
	bool operator!= (intArr ARR);
	
	//Convershions
	cv::Mat AsCVMat();
private:
};
#endif