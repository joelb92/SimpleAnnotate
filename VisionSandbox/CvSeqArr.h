//
//  CvSeqArr.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 06/25/14.
//
//
//	From Array Template created on by Charlie Mehlenbeck on 10/18/13.
//	Please do not add any thing to this class that could be applicable to other classes without as well modifying the template!!!
//	However, some functions or convershions may not be applicable to all types that could be used in this array and those, except any core functionality, may be removed.
//
//

#import <Foundation/Foundation.h>
#import "intArr.h"

#ifndef CvSeqArr_H_
#define CvSeqArr_H_
class CvSeqArr
{
private:
	int actualLength;
	int startingIndex;
	
public:
	CvSeq**arr;
	int Length;
	
	CvSeqArr();
	CvSeqArr(cv::Mat mat);
	CvSeqArr(int capacity);
	CvSeqArr(int length, CvSeq* initializedValue);
	
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
	void InsertItemAtIndex(CvSeq* item, int index);
	void InsertItemsAtIndex(CvSeqArr items, int index);
	void AddItemToEnd(CvSeq* item);
	void AddItemsToEnd(CvSeqArr items);
	void AddItemToBegining(CvSeq* item);
	void AddItemsToBegining(CvSeqArr items);
	CvSeq* GetAndRemoveFirstElement();
	CvSeq* GetAndRemoveLastElement();
    
	//Operators
	CvSeq* &operator[](int index);
	const CvSeq* &operator[](int index) const;
	bool operator== (CvSeqArr ARR);
	bool operator!= (CvSeqArr ARR);
	
	//Convershions
	cv::Mat AsCVMat();
private:
};
#endif