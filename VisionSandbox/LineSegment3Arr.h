//
//  LineSegment3Arr.h
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
#import "LineSegment3.h"
#import "Vector3Arr.h"
#import "intArr.h"

#ifndef LineSegment3Arr_H_
#define LineSegment3Arr_H_
class LineSegment3Arr
{
private:
	int actualLength;
	int startingIndex;
	
public:
	boost::shared_array<LineSegment3> arr;
	int Length;
	
	LineSegment3Arr();
	LineSegment3Arr(int capacity);
	LineSegment3Arr(int length, LineSegment3 initializedValue);
	
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
	void InsertItemAtIndex(LineSegment3 item, int index);
	void InsertItemsAtIndex(LineSegment3Arr items, int index);
	void AddItemToEnd(LineSegment3 item);
	void AddItemsToEnd(LineSegment3Arr items);
	void AddItemToBegining(LineSegment3 item);
	void AddItemsToBegining(LineSegment3Arr items);
	LineSegment3 GetAndRemoveFirstElement();
	LineSegment3 GetAndRemoveLastElement();
	
	Vector3Arr RaycastSegsForSegsEndingWithinRadiusOfRay(float radius, Ray3 ray);
	intArr RaycastSegsForIndiciesOfSegsEndingWithinRadiusOfRay(float radius, Ray3 ray);
	
	//Operators
	LineSegment3 &operator[](int index);
	const LineSegment3 &operator[](int index) const;
	bool operator== (LineSegment3Arr ARR);
	bool operator!= (LineSegment3Arr ARR);
private:
};
#endif