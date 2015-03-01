//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "Line3.h"

//Constructors
Line3::Line3()
{
	point1 = Vector3();
	point2 = Vector3();
}
Line3::Line3(Ray3 ray)
{
	point1 = ray.origin;
	point2 = point1 + ray.direction;
}
Line3::Line3(LineSegment3 seg)
{
	point1 = seg.origin;
	point2 = seg.termintation;
}
Line3::Line3(Vector3 p1, Vector3 p2)
{
	point1 = p1;
	point2 = p2;
}

//Functions
Vector3 Line3::DirectionUnNormalized()
{
	return point2-point1;
}
Vector3 Line3::DirectionNormalized()
{
	return (point2-point1).Normalized();
}

Vector3 Line3::ProjectionOfPoint(Vector3 point)
{
	Vector3 u = point2 - point1;
	Vector3 pq = point - point1;
	Vector3 w2 = pq - u*pq.Dot(u)/u.SqMagnitude();
	
	return point - w2;
}

//Operators
bool Line3::operator== (Line3 line)
{
	return point1==line.point1 && point2==line.point2;
}
bool Line3::operator!= (Line3 line)
{
	return point1!=line.point1 || point2!=line.point2;
}