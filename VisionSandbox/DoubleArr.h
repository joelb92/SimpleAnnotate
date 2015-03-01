//
//  DoubleArr.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 10/18/13.
//
//
//	From Array Template created on by Charlie Mehlenbeck on 10/18/13.
//	Please do not add any thing to this class that could be applicable to other classes without as well modifying the template!!!
//	However, some functions or convershions may not be applicable to all types that could be used in this array and those, except any core functionality, may be removed.
//
//

#import <Foundation/Foundation.h>
#import "intArr.h"

#ifndef DoubleArr_H_
#define DoubleArr_H_
class DoubleArr
{
private:
	int actualLength;
	int startingIndex;
	
public:
	double*arr;
	int Length;
	
	DoubleArr();
	DoubleArr(cv::Mat mat);
	DoubleArr(int capacity);
	DoubleArr(int length, double initializedValue);
	
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
	void InsertItemAtIndex(double item, int index);
	void InsertItemsAtIndex(DoubleArr items, int index);
	void AddItemToEnd(double item);
	void AddItemsToEnd(DoubleArr items);
	void AddItemToBegining(double item);
	void AddItemsToBegining(DoubleArr items);
	double Min();
	double Max();
	
	//Operators
	double &operator[](int index);
	const double &operator[](int index) const;
	bool operator== (DoubleArr ARR);
	bool operator!= (DoubleArr ARR);
	
	//Convershions
	cv::Mat AsCVMat();
private:
};
#endif