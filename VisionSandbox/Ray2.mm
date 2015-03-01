//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#include "Ray2.h"

//Constructors
Ray2::Ray2()
{
	origin = Vector2();
	direction = Vector2();
}
Ray2::Ray2(Vector2 ORIGIN, Vector2 DIRECTION)
{
	origin = ORIGIN;
	direction = DIRECTION;
}
Ray2::Ray2(LineSegment2 seg)
{
	origin = seg.origin;
	direction = seg.DirectionNormalized();
}

//Functions
Vector2 Ray2::ProjectionOfPoint(Vector2 point)
{
	Vector2 u = direction - origin;
	Vector2 pq = point - origin;
	Vector2 w2 = pq - u*pq.Dot(u)/u.SqMagnitude();
	
	return point - w2;
}
bool Ray2::IntersectionWith(Vector2* intersection, Line2 line)
{
	//stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
	//	Vector2 r = direction;
	Vector2 s = line.DirectionUnNormalized();
	if(direction.Cross(s)!=0)
	{
		double t = (line.point1-origin).Cross(s/direction.Cross(s));
		double u = (line.point1-origin).Cross(direction/direction.Cross(s));
		
		*intersection = origin + direction*t;
		if(t>=0)
		{
			return true;
		}
		return false;
	}
	*intersection = Vector2(NAN,NAN);
	return false;
}
bool Ray2::IntersectionWith(Vector2* intersection, LineSegment2 seg)
{
	//stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
	Vector2 r = direction;
	Vector2 s = seg.termintation-seg.origin;
	if(r.Cross(s)!=0)
	{
		double t = (seg.origin-origin).Cross(s/r.Cross(s));
		double u = (seg.origin-origin).Cross(r/r.Cross(s));
		
		*intersection = origin + r*t;
		if(t>=0 && u>=0 && u<=1)
		{
			return true;
		}
		return false;
	}
	*intersection = Vector2(NAN,NAN);
	return false;
}
bool Ray2::IntersectionWith(Vector2* intersection, Ray2 ray)
{
	//stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
//	Vector2 r = direction;
//	Vector2 s = ray.direction;
	if(direction.Cross(ray.direction)!=0)
	{
		double t = (ray.origin-origin).Cross(ray.direction/direction.Cross(ray.direction));
		double u = (ray.origin-origin).Cross(direction/direction.Cross(ray.direction));
		
		*intersection = origin + direction*t;
		if(t>=0 && u>=0)
		{
			return true;
		}
		return false;
	}
	*intersection = Vector2(NAN,NAN);
	return false;
}

//Operators
LineSegment2 Ray2::operator* (double parm)
{
	return LineSegment2(origin,direction*parm+origin);
}
LineSegment2 Ray2::operator/ (double parm)
{
	return LineSegment2(origin,direction*parm+origin);
}
Ray2 Ray2::operator-()
{
	return Ray2(origin,-direction);
}
bool Ray2::operator== (Ray2 ray)
{
	return origin==ray.origin && direction==ray.direction;
}
bool Ray2::operator!= (Ray2 ray)
{
	return origin!=ray.origin || direction!=ray.direction;
}