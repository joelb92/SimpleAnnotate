//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2Arr.h"
#import "Line2.h"
#import "Ray2.h"

class Vector2Arr;
class Line2;
class Ray2;

#ifndef LineSegment2_H_
#define LineSegment2_H_
class LineSegment2
{
public:
	//Components
	Vector2 origin;
	Vector2 termintation;
	
	//Constructors
	LineSegment2();
	LineSegment2(Line2 line);
	LineSegment2(Ray2 ray);
	LineSegment2(Ray2 ray, double length);
	LineSegment2(Vector2 ORIGIN, Vector2 TERMINATION);
	LineSegment2(Vector2 ORIGIN, double radAngle, double length);
	
	//Functions
	bool isNull();
	double AngleToTermination();
	Vector2 DirectionUnNormalized();
	Vector2 DirectionNormalized();
	Vector2Arr RasterizedPoints();
	
	LineSegment2 Perpendicular();
	Vector2 ProjectionOfPoint(Vector2 point);
	bool IntersectionWith(Vector2* intersection, LineSegment2 seg);
	bool IntersectionWith(Vector2* intersection, Line2 line);
	bool IntersectionWith(Vector2* intersection, Ray2 ray);
	bool ContainsProjectionOfPoint(Vector2 point);
	
	//Operators
	LineSegment2 operator+ (Vector2 vect);
	void operator+= (Vector2 vect);
	LineSegment2 operator- (Vector2 vect);
	LineSegment2 operator-();
	LineSegment2 operator* (float parm);
	void operator-= (Vector2 vect);
	bool operator== (LineSegment2 seg);
	bool operator!= (LineSegment2 seg);
private:
};

#endif