//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "LineSegment3.h"
//Constructors
LineSegment3::LineSegment3()
{
	origin = Vector3();
	termintation = Vector3();
}
LineSegment3::LineSegment3(Vector3 ORIGIN, Vector3 TERMINATION)
{
	origin = ORIGIN;
	termintation = TERMINATION;
}

//Functions
Vector3 LineSegment3::DirectionUnNormalized()
{
	return termintation-origin;
}
Vector3 LineSegment3::DirectionNormalized()
{
	return (termintation-origin).Normalized();
}

Vector3 LineSegment3::ProjectionOfPoint(Vector3 point) //Untested in 3D!
{
	Vector3 u = termintation - origin;
	Vector3 pq = point - origin;
	Vector3 w2 = pq - u*pq.Dot(u)/u.SqMagnitude();
	
	return point - w2;
}

//Operators
bool LineSegment3::operator== (LineSegment3 seg)
{
	return origin==seg.origin && termintation==seg.termintation;
}
bool LineSegment3::operator!= (LineSegment3 seg)
{
	return origin!=seg.origin || termintation!=seg.termintation;
}