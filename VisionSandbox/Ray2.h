//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Vector2.h"
#import "LineSegment2.h"
#import "Line2.h"

class Line2;
class LineSegment2;

#ifndef Ray2_H_
#define Ray2_H_
class Ray2
{
public:
	//Components
	Vector2 origin;
	Vector2 direction;
	
	//Constructors
	Ray2();
	Ray2(Vector2 ORIGIN, Vector2 DIRECTION);
	Ray2(LineSegment2 seg);
	
	//Functions
	Vector2 ProjectionOfPoint(Vector2 point);
	bool IntersectionWith(Vector2* intersection, Line2 line);
	bool IntersectionWith(Vector2* intersection, LineSegment2 seg);
	bool IntersectionWith(Vector2* intersection, Ray2 ray);
	
	//Operators
	LineSegment2 operator* (double parm);
	LineSegment2 operator/ (double parm);
	Ray2 operator-();
	bool operator== (Ray2 Ray2);
	bool operator!= (Ray2 Ray2);
private:
};

#endif