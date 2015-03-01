//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "LineSegment3.h"
#import "Line3.h"
#import "Ray3.h"

#ifndef Plane_H_
#define Plane_H_
class Plane
{
public:
	//Components
	Vector3 position,normal,xTangent,yTangent;
	cv::Matx33d rotationMatrix;
	
	//Constructors
	Plane();
	Plane(Vector3 POSITION, Vector3 NORMAL);
	Plane(Vector3 POSITION, Vector3 NORMAL, Vector3 XTAN);
	Plane(Vector3 POSITION, Vector3 NORMAL, Vector3 XTAN, Vector3 YTAN);
	Plane(Vector3 POSITION, Vector3 NORMAL, Vector3 XTAN, Vector3 YTAN, cv::Matx33d rotMat);
	
	//Functions
	Vector3 ReflectDirection(Vector3 direction);
	Vector3 WorldPointFromObjectPoint(Vector3 objectPoint);
	Vector3 WorldDirectionFromObjectDirection(Vector3 objectDirection);
	Vector3 ProjectionOfPoint(Vector3 point);
	Vector3 LineCast(Line3 line);
	bool IntersectionWith(Vector3* intersection, Ray3 ray);
	bool IntersectionWith(Line3* intersection, Plane plane);
	
	//Operators
	bool operator== (Plane plane);
	bool operator!= (Plane plane);
private:
};

#endif