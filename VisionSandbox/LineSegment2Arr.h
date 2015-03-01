//
//  LineSegment2Arr.h
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

#import <Foundation/Foundation.h>
#import "boost/shared_array.hpp"
#import "LineSegment2.h"
#import "intArr.h"

#ifndef LineSegment2Arr_H_
#define LineSegment2Arr_H_
class LineSegment2Arr
{
private:
	int actualLength;
	int startingIndex;
	
public:
	boost::shared_array<LineSegment2> arr;
	int Length;
	
	LineSegment2Arr();
	LineSegment2Arr(int capacity);
	LineSegment2Arr(int length, LineSegment2 initializedValue);
	
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
	void InsertItemAtIndex(LineSegment2 item, int index);
	void InsertItemsAtIndex(LineSegment2Arr items, int index);
	void AddItemToEnd(LineSegment2 item);
	void AddItemsToEnd(LineSegment2Arr items);
	void AddItemToBegining(LineSegment2 item);
	void AddItemsToBegining(LineSegment2Arr items);
	LineSegment2 GetAndRemoveFirstElement();
	LineSegment2 GetAndRemoveLastElement();
    
	//Operators
	LineSegment2 &operator[](int index);
	const LineSegment2 &operator[](int index) const;
	bool operator== (LineSegment2Arr ARR);
	bool operator!= (LineSegment2Arr ARR);
private:
};
#endif