//
//  boolArr.h
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

#import <Foundation/Foundation.h>
#import "intArr.h"

#ifndef boolArr_H_
#define boolArr_H_
class boolArr
{
private:
	int actualLength;
	int startingIndex;
	
public:
	bool*arr;
	int Length;
	
	boolArr();
	boolArr(cv::Mat mat);
	boolArr(int capacity);
	boolArr(int length, bool initializedValue);
	
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
	void InsertItemAtIndex(bool item, int index);
	void InsertItemsAtIndex(boolArr items, int index);
	void AddItemToEnd(bool item);
	void AddItemsToEnd(boolArr items);
	void AddItemToBegining(bool item);
	void AddItemsToBegining(boolArr items);
	bool GetAndRemoveFirstElement();
	bool GetAndRemoveLastElement();
    
	//Operators
	bool &operator[](int index);
	const bool &operator[](int index) const;
	bool operator== (boolArr ARR);
	bool operator!= (boolArr ARR);
	
	//Convershions
	cv::Mat AsCVMat();
private:
};
#endif