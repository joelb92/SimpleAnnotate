//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Vector2.h"
#include "math.h"

#ifndef vector2Rect_H_
#define vector2Rect_H_

class vector2Rect
{
public:
	//Components
	Vector2 origin;
	Vector2 size;
	
	//Constructors
	vector2Rect();
	vector2Rect(Vector2 Origin, Vector2 Size);
	vector2Rect(float x, float y, float width, float height);
	vector2Rect(NSRect r);
//	vector2Rect(CGRect r);
	
	//Functions
	bool ContainsPoint(Vector2 point);
	float AspectRatio();
	
	//Operators
	vector2Rect operator+ (vector2Rect rect);
	vector2Rect operator+ (Vector2 vect);
	void operator+= (vector2Rect rect);
	void operator+= (Vector2 vect);
	bool operator== (vector2Rect rect);
	bool operator!= (vector2Rect rect);
	
	//Convershions
	CGRect AsCGRect();
	std::vector<cv::Point> AsContour();
private:
};

#endif