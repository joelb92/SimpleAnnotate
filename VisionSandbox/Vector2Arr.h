//
//  Vector2Arr.h
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
#import "Vector3Arr.h"
#import "Vector2.h"
#import "intArr.h"
#import "Line2.h"
#import "boost/shared_array.hpp"

class Line2;
class LineSegment2;
class Vector3Arr;

#ifndef Vector2Arr_H_
#define Vector2Arr_H_
class Vector2Arr
{
private:
	int actualLength;
	int startingIndex;
	Vector2 centerOfMass;
	bool centerOfMassCalculated;
	
public:
	boost::shared_array<Vector2> arr;
	int Length;
	
	Vector2Arr();
	Vector2Arr(cv::Mat mat);
	Vector2Arr(int capacity);
	Vector2Arr(int length, Vector2 initializedValue);
	Vector2Arr(std::vector<cv::Point2f> points);
	static Vector2Arr Vector2ArrFromSeq(CvSeq* seq);
	Vector2Arr(NSString* csv);
	Vector2Arr(CvPoint2D32f*points, int count);
	Vector2Arr(CvSeq* points);
	Vector2Arr(Vector3Arr ARR);
	
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
	void InsertItemAtIndex(Vector2 item, int index);
	void InsertItemsAtIndex(Vector2Arr items, int index);
	void AddItemToEnd(Vector2 item);
	void AddItemsToEnd(Vector2Arr items);
	void AddItemToBegining(Vector2 item);
	void AddItemsToBegining(Vector2Arr items);
	Vector2 GetAndRemoveFirstElement();
	Vector2 GetAndRemoveLastElement();
    Vector2Arr PointsForIndices(intArr indices);
	
	Vector2 CenterOfMass();
	int ClosestIndexToPoint(Vector2 point);
	Vector2Arr arrayWithDescription(NSString* description);
	Vector2 FurthestPointAlongDirectionFromLine(Vector2 direction, Line2 line);
	NSString* description();
	
	//Operators
	Vector2 &operator[](int index);
	const Vector2 &operator[](int index) const;
	bool operator== (Vector2Arr ARR);
	bool operator!= (Vector2Arr ARR);
	
	//Convershions
	cv::Mat AsCVMat();
	NSString* csv();
private:
};
#endif