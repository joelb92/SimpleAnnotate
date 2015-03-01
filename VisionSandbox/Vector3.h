//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2.h"
#import <GLKit/GLKit.h>
#import "math.h"

class Vector2;

#ifndef Vector3_H_
#define Vector3_H_
class Vector3
{
public:
	//Components
	double x, y, z;
	
	//Constructors
	Vector3();
	Vector3(Vector2 point);
	Vector3(Vector2 point, double Z);
	Vector3(double X, double Y, double Z);
	Vector3(GLKVector3 vect);
	Vector3(cv::Matx13d mat);
	Vector3(cv::Matx31d mat);
	Vector3(cv::Point3f point);
	Vector3(GLKVector2 vect);
	Vector3(cv::Vec3b vect);
	
	//Functions
	bool isNull();
	double SqMagnitude();
	double Magnitude();
	double Volume();
	double Dot(Vector3 vect);
	Vector3 Cross(Vector3 vect);
	Vector3 Normalized();
	Vector3 FromToBy(Vector3 From, Vector3 To, double By); //Linearly interpolate 'from' 'to' 'by' a percent (0 to 1)
	Vector3 DevideComponentsByComponentsOf(Vector3 vect);
	Vector3 MultiplyComponentsByComponentsOf(Vector3 vect);
	GLKQuaternion RotationToVector(Vector3 vect);
	Vector3 RotatedBy(GLKQuaternion rot);
	double AngleToVector(Vector3 vect);
	static double RadiusOfSphereRepresentedByPoints(Vector3 P1, Vector3 P2, Vector3 P3);
	Vector3 CartesianToSpherical();
	Vector3 SphericalToCartesian();
	void ClampFromTo(Vector3 from, Vector3 to);
	void ClampFrom(Vector3 from);
	void ClampTo(Vector3 to);
	
	//Operators
	Vector3 operator+ (Vector3 vect);
	Vector3 operator+ (double parm);
	void operator+= (Vector3 vect);
	Vector3 operator- (Vector3 vect);
	Vector3 operator-();
	void operator-= (Vector3 vect);
	Vector3 operator* (double parm);
	Vector3 operator/ (double parm);
	bool operator== (Vector3 vect);
	bool operator!= (Vector3 vect);
	
	//Convershions
	GLKVector3 AsGLKVector3();
	cv::Matx13d HozMat();
	cv::Matx31d VerMat();
	cv::Point3f cvPoint3f();
	Vector2 AsVector2();
private:
};

#endif