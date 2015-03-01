//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//
#import "Line2.h"

//Constructors
Line2::Line2()
{
	point1 = Vector2();
	point2 = Vector2();
}
Line2::Line2(LineSegment2 seg)
{
	point1 = seg.origin;
	point2 = seg.termintation;
}
Line2::Line2(Ray2 ray)
{
	point1 = ray.origin;
	point2 = point1 + ray.direction;
}
Line2::Line2(Vector2 p1, Vector2 p2)
{
	point1 = p1;
	point2 = p2;
}
Line2::Line2(Vector2 p1, double radAngle)
{
	point1 = p1;
	point2 = Vector2(cos(radAngle)+point1.x, sin(radAngle)+point1.y);
}

//Functions
double Line2::AngleToTermination()
{
	return atan2(point2.y-point1.y, point2.x-point1.x);
}
Vector2 Line2::DirectionUnNormalized()
{
	return point2-point1;
}
Vector2 Line2::DirectionNormalized()
{
	return (point2-point1).Normalized();
}

Line2 Line2::Perpendicular()
{
	return Line2(point1,(point2-point1).Perpendicular() + point1);
}
Vector2 Line2::ProjectionOfPoint(Vector2 point)
{
	Vector2 u = point2 - point1;
	Vector2 pq = point - point1;
	Vector2 w2 = pq - u*pq.Dot(u)/u.SqMagnitude();
	
	return point - w2;
}
bool Line2::IntersectionWith(Vector2* intersection, Line2 line)
{
	//stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
	Vector2 r = point2-point1;
	Vector2 s = line.point2-line.point1;
	if(r.Cross(s)!=0)
	{
		double u = (line.point1-point1).Cross(r/r.Cross(s));
		*intersection = line.point1 + s*u;
		return true;
	}
	*intersection = Vector2(NAN,NAN);
	return false;
}
bool Line2::IntersectionWith(Vector2* intersection, LineSegment2 seg)
{
	//stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
	Vector2 r = point2-point1;
	Vector2 s = seg.termintation-seg.origin;
	if(r.Cross(s)!=0)
	{
		double u = (seg.origin-point1).Cross(r/r.Cross(s));
		
		*intersection = seg.origin + s*u;
		if(u>=0 && u<=1)
		{
			return true;
		}
		return false;
	}
	*intersection = Vector2(NAN,NAN);
	return false;
}
bool Line2::IntersectionWith(Vector2* intersection, Ray2 ray)
{
	//stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
	Vector2 r = point2-point1;
	Vector2 s = ray.direction;
	if(r.Cross(s)!=0)
	{
		double u = (ray.origin-point1).Cross(r/r.Cross(s));
		
		*intersection = ray.origin + s*u;
		if(u>=0)
		{
			return true;
		}
		return false;
	}
	*intersection = Vector2(NAN,NAN);
	return false;
}

//Operators
bool Line2::operator== (Line2 line)
{
	return point1==line.point1 && point2==line.point2;
}
bool Line2::operator!= (Line2 line)
{
	return point1!=line.point1 || point2!=line.point2;
}