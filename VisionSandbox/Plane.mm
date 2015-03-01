//
//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "Plane.h"

//Constructors
Plane::Plane()
{
	position = Vector3();
	normal = Vector3();
	xTangent = Vector3();
	yTangent = Vector3();
}
Plane::Plane(Vector3 POSITION, Vector3 NORMAL)
{
	position = POSITION;
	normal = NORMAL;
	xTangent = Vector3();
	yTangent = Vector3();
}
Plane::Plane(Vector3 POSITION, Vector3 NORMAL, Vector3 XTAN)
{
	position = POSITION;
	normal = NORMAL;
	xTangent = XTAN;
	yTangent = xTangent.Cross(normal);
}
Plane::Plane(Vector3 POSITION, Vector3 NORMAL, Vector3 XTAN, Vector3 YTAN)
{
	position = POSITION;
	normal = NORMAL;
	xTangent = XTAN;
	yTangent = YTAN;
}
Plane::Plane(Vector3 POSITION, Vector3 NORMAL, Vector3 XTAN, Vector3 YTAN, cv::Matx33d rotMat)
{
	position = POSITION;
	normal = NORMAL;
	xTangent = XTAN;
	yTangent = YTAN;
	rotationMatrix = rotMat;
}

//Functions
Vector3 Plane::ReflectDirection(Vector3 direction)
{
	float dDOTn = direction.Dot(normal);
	float twoDdotN = dDOTn*2.0;
	Vector3 normalTimesTwoDdotN = normal*twoDdotN;
	Vector3 normalTimesTwoDdotNMinusDirection = normalTimesTwoDdotN - direction;
	return -normalTimesTwoDdotNMinusDirection;
}
Vector3 Plane::WorldPointFromObjectPoint(Vector3 objectPoint)
{
	return WorldDirectionFromObjectDirection(objectPoint) + position;
}
Vector3 Plane::WorldDirectionFromObjectDirection(Vector3 objectDirection)
{
	cv::Matx31d original_point(objectDirection.x,objectDirection.y,objectDirection.z);
	cv::Mat direction = (cv::Mat)(rotationMatrix*original_point);
	return Vector3(direction.at<double>(0,0),direction.at<double>(1,0),direction.at<double>(2,0));
}
Vector3 Plane::ProjectionOfPoint(Vector3 point)
{
	return point-normal*((point-position).Dot(normal));
}
Vector3 Plane::LineCast(Line3 line)
{
	float d = -normal.x*position.x - normal.y*position.y - normal.z*position.z;
	float a = (-normal.x*line.point1.x - normal.y*line.point1.y - normal.z*line.point1.z - d) / (normal.x*line.point2.x + normal.y*line.point2.y + normal.z*line.point2.z);
	
	return line.point1 + line.point2*a;
}
bool Plane::IntersectionWith(Vector3* intersection, Ray3 ray)
{
	Vector3 p2 = ray.direction + ray.origin;
	float d = -normal.x*position.x - normal.y*position.y - normal.z*position.z;
	float a = (-normal.x*ray.origin.x - normal.y*ray.origin.y - normal.z*ray.origin.z - d) / (normal.x*p2.x + normal.y*p2.y + normal.z*p2.z);
	
	*intersection = ray.origin + p2*a;
	
	if(a>=0)
	{
		return true;
	}
	return false;
}
bool Plane::IntersectionWith(Line3* intersection, Plane plane)
{
	if(normal == plane.normal) //Planes are parallel, no intersection line exists.
	{
		//Solve for the direction vector of the line of intersection
		Vector3 intDirection = normal.Cross(plane.normal);
		
		//A plane can be represented as: ax + by + cz + d = 0,
		//<a,b,c> being the normal,
		//this being plane 1, and 'plane' being plane 2.
		//Extract values:
		double a1 = normal.x;
		double b1 = normal.y;
		double c1 = normal.z;
		
		double a2 = plane.normal.x;
		double b2 = plane.normal.y;
		double c2 = plane.normal.z;
		//Solve d for both:
		double d1 = -(a1*position.x			+ b1*position.y			+ c1*position.z);
		double d2 = -(a2*plane.position.x	+ b2*plane.position.y	+ c2*plane.position.z);
		
		//Solve for a point on the line of intersection:
		//a1x + b1y + c1z + d1 = a2x + b2y + c2z + d2
		//Set z = 0 and solve for x,y:
		//
		//->a1x + b1y + d1		|	a2x + b2y + d2
		//->b2(a1x + b1y + d1)  |	b1(a2x + b2y + d2)
		//->b2(a1x + b1y + d1)  |	b1(a2x + b2y + d2)
		//->b2*a1*x + b2*d1		=	b1*a2*x + b1*d2
		//->b2*a1*x				=	b1*a2*x + b1*d2 - b2*d1
		//->b2*a1*x - b1*a2*x	=	b1*d2 - b2*d1
		//->(b2*a1 - b1*a2) * x	=	b1*d2 - b2*d1
		double x = (b1*d2 - b2*d1)/(b2*a1 - b1*a2);
		//
		//->a1x + b1y + d1		|	a2x + b2y + d2
		//->a2(a1x + b1y + d1)  |	a1(a2x + b2y + d2)
		//->a2*b1*y + a2*d1		=	a1*b2*y + a1*d2
		//->a2*b1*y				=	a1*b2*y + a1*d2 - a2*d1
		//->a2*b1*y - a1*b2*y	=	a1*d2 - a2*d1
		//->(a2*b1 - a1*b2) * y	=	a1*d2 - a2*d1
		double y = (a1*d2 - a2*d1)/(a2*b1 - a1*b2);
		
		Vector3 intPoint = Vector3(x,y,0);
		
		*intersection = Line3(intPoint, intPoint+intDirection);
		return true;
	}
	return false;
}

//Operators
bool Plane::operator== (Plane plane)
{
	return position==plane.position && normal==plane.normal;
}
bool Plane::operator!= (Plane plane)
{
	return position!=plane.position || normal!=plane.normal;
}