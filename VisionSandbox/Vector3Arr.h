//
//  Vector3Arr.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 3/19/13.
//
//
//	From Array Template created on by Charlie Mehlenbeck on 10/18/13.
//	Please do not add any thing to this class that could be applicable to other classes without as well modifying the template!!!
//	However, some functions or convershions may not be applicable to all types that could be used in this array and those, except any core functionality, may be removed.
//
//

#import <Foundation/Foundation.h>
#import "Vector3.h"
#import "Vector2Arr.h"
#import "intArr.h"
#import "Ray3.h"

class Vector2Arr;

#ifndef Vector3Arr_H_
#define Vector3Arr_H_
class Vector3Arr
{
private:
	int actualLength;
	int startingIndex;
	
public:
	Vector3*arr;
	int Length;
	
	Vector3Arr();
	Vector3Arr(cv::Mat mat);
	Vector3Arr(int capacity);
	Vector3Arr(int length, Vector3 initializedValue);
	
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
	void InsertItemAtIndex(Vector3 item, int index);
	void InsertItemsAtIndex(Vector3Arr items, int index);
	void AddItemToEnd(Vector3 item);
	void AddItemsToEnd(Vector3Arr items);
	void AddItemToBegining(Vector3 item);
	void AddItemsToBegining(Vector3Arr items);
	Vector3 GetAndRemoveFirstElement();
	Vector3 GetAndRemoveLastElement();
	Vector3Arr Clone();
	NSString*csv();
	
	Vector3Arr PointsForIndices(intArr indices);
	Vector3Arr RaycastPointsForPointsWithRadiusRay(float radius, Ray3 ray);
	intArr RaycastPointsForIndexesWithRadiusRay(float radius, Ray3 ray);
	int ClosestIndexToPoint(Vector3 point);
	Vector3 ClosestPointToPoint(Vector3 point);
	int ClosestIndexToPointOfIndexes(Vector3 point, intArr indexes);
	Vector3 ClosestPointToPointOfIndexes(Vector3 point, intArr indexes);
	int ClosestIndexToRay(Ray3 ray);
	Vector3 ClosestPointToRay(Ray3 ray);
	Vector3 Centroid();
	void SetCentroidTo(Vector3 newCentroid);
	
	//Operators
	Vector3 &operator[](int index);
	const Vector3 &operator[](int index) const;
	bool operator== (Vector3Arr ARR);
	bool operator!= (Vector3Arr ARR);
	void operator+= (Vector3 delta);
	void operator-= (Vector3 delta);
	Vector3Arr operator+ (Vector3 delta);
	Vector3Arr operator- (Vector3 delta);
	Vector3Arr operator* (GLKQuaternion rotation);
	
	//Convershions
	cv::Mat AsCVMat();
	std::vector<cv::Point3f> AsPointVector();
private:
};
#endif