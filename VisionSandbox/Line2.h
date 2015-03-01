//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LineSegment2.h"
#import "Ray2.h"

class Ray2;
class LineSegment2;

#ifndef Line2_H_
#define Line2_H_
class Line2
{
public:
	//Components
	Vector2 point1;
	Vector2 point2;
	
	//Constructors
	Line2();
	Line2(LineSegment2 seg);
	Line2(Ray2 ray);
	Line2(Vector2 p1, Vector2 p2);
	Line2(Vector2 p1, double radAngle);
	
	//Functions
	double AngleToTermination();
	Vector2 DirectionUnNormalized();
	Vector2 DirectionNormalized();
	
	Line2 Perpendicular();
	Vector2 ProjectionOfPoint(Vector2 point);
	bool IntersectionWith(Vector2* intersection, Line2 line);
	bool IntersectionWith(Vector2* intersection, LineSegment2 seg);
	bool IntersectionWith(Vector2* intersection, Ray2 ray);
	
	//Operators
	bool operator== (Line2 line);
	bool operator!= (Line2 line);
private:
};

#endif