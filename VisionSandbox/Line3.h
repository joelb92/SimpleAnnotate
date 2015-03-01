//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "LineSegment3.h"
#import "Ray3.h"

class Ray3;
class LineSegment3;

#ifndef Line3_H_
#define Line3_H_
class Line3
{
public:
	//Components
	Vector3 point1;
	Vector3 point2;
	
	//Constructors
	Line3();
	Line3(Ray3 ray);
	Line3(LineSegment3 seg);
	Line3(Vector3 p1, Vector3 p2);
	
	//Functions
	Vector3 DirectionUnNormalized();
	Vector3 DirectionNormalized();
	
	Vector3 ProjectionOfPoint(Vector3 point);
	
	//Operators
	bool operator== (Line3 line);
	bool operator!= (Line3 line);
private:
};

#endif