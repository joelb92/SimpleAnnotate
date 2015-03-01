//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "Ray3.h"

//Constructors
Ray3::Ray3()
{
	origin = Vector3();
	direction = Vector3();
}
Ray3::Ray3(Vector3 ORIGIN, Vector3 DIRECTION)
{
	origin = ORIGIN;
	direction = DIRECTION;
}
Ray3::Ray3(LineSegment3 seg)
{
	origin = seg.origin;
	direction = seg.DirectionNormalized();
}

//Functions
Vector3 Ray3::ProjectionOfPoint(Vector3 point) //Untested in 3D!
{
	Vector3 pq = point - origin;
	Vector3 w2 = pq - direction*pq.Dot(direction)/direction.SqMagnitude();
	
	return point - w2;
}

//Operators
LineSegment3 Ray3::operator* (double parm)
{
	return LineSegment3(origin,direction*parm+origin);
}
LineSegment3 Ray3::operator/ (double parm)
{
	return LineSegment3(origin,direction*parm+origin);
}
Ray3 Ray3::operator-()
{
	return Ray3(origin,-direction);
}
bool Ray3::operator== (Ray3 ray)
{
	return origin==ray.origin && direction==ray.direction;
}
bool Ray3::operator!= (Ray3 ray)
{
	return origin!=ray.origin || direction!=ray.direction;
}