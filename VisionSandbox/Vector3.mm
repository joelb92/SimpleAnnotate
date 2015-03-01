//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//


#import "Vector3.h"

//Constructors
Vector3::Vector3()
{
	x=0;
	y=0;
	z=0;
}
Vector3::Vector3(Vector2 point)
{
	x=point.x;
	y=point.y;
	z=0;
}
Vector3::Vector3(Vector2 point, double Z)
{
	x=point.x;
	y=point.y;
	z=Z;
}
Vector3::Vector3(double X, double Y, double Z)
{
	x=X;
	y=Y;
	z=Z;
}
Vector3::Vector3(GLKVector3 vect)
{
	x=vect.x;
	y=vect.y;
	z=vect.z;
}
Vector3::Vector3(cv::Matx13d mat)
{
	x = mat.val[0];
	y = mat.val[1];
	z = mat.val[2];
}
Vector3::Vector3(cv::Matx31d mat)
{
	x = mat.val[0];
	y = mat.val[1];
	z = mat.val[2];
}
Vector3::Vector3(cv::Point3f point)
{
	x = point.x;
	y = point.y;
	z = point.z;
}

Vector3::Vector3(cv::Vec3b vect)
{
	x = vect[0];
	x = vect[1];
	x = vect[2];
}
//Functions
bool Vector3::isNull()
{
	return !(x==x && y==y && z==z);
}
double Vector3::SqMagnitude()
{
	return x*x + y*y + z*z;
}
double Vector3::Magnitude()
{
	return sqrt(SqMagnitude());
}
double Vector3::Volume()
{
	return x*y*z;
}
double Vector3::Dot(Vector3 vect)
{
	return x*vect.x + y*vect.y + z*vect.z;
}
Vector3 Vector3::Cross(Vector3 vect)
{
	return Vector3(y*vect.z-z*vect.y, z*vect.x-x*vect.z, x*vect.y-y*vect.x);
}
Vector3 Vector3::Normalized()
{
	return Vector3(x, y, z)/Magnitude();
}
Vector3 Vector3::FromToBy(Vector3 From, Vector3 To, double By)
{
	return (To-From).Normalized()*By+From;
}
Vector3 Vector3::DevideComponentsByComponentsOf(Vector3 vect)
{
	return Vector3(x/vect.x, y/vect.y, z/vect.z);
}
Vector3 Vector3::MultiplyComponentsByComponentsOf(Vector3 vect)
{
	return Vector3(x*vect.x, y*vect.y, z*vect.z);
}
GLKQuaternion Vector3::RotationToVector(Vector3 vect)
{
	GLKQuaternion q;
	Vector3 a = Cross(vect);
	q.x=a.x;
	q.y=a.y;
	q.z=a.z;
	q.w=sqrt(SqMagnitude() * vect.SqMagnitude()) + Dot(vect);
	
	double mag = sqrt(a.SqMagnitude()+q.w*q.w);
	q.x = q.x/mag;
	q.y = q.y/mag;
	q.z = q.z/mag;
	q.w = q.w/mag;
	
	return q;
}
Vector3 Vector3::RotatedBy(GLKQuaternion rot)
{
	return Vector3( GLKQuaternionRotateVector3(rot, AsGLKVector3()) );
}
double Vector3::AngleToVector(Vector3 vect)
{
	float denominator = (Magnitude() * vect.Magnitude());
	if(denominator==0) return NAN;
	else
	{
		float numerator = Dot(vect);
		float quotient = numerator/denominator;
		if(quotient==-1) return M_PI;
		else if(quotient==1) return 0;
		return acos( quotient );
	}
}
double Vector3::RadiusOfSphereRepresentedByPoints(Vector3 P1, Vector3 P2, Vector3 P3)
{
	float theta = (P1-P2).AngleToVector(P3-P2);
	return (P1-P3).Magnitude()/(2*sin( theta ));
}
Vector3 Vector3::CartesianToSpherical()
{
	double r = Magnitude();
	double theta = acos(z/r);
	double phi = atan(y/x);
	
	return Vector3(r,theta,phi);
}
Vector3 Vector3::SphericalToCartesian()
{
//	double r = x;
//	double theta = y;
//	double phi = z;
	
	double X = x * sin(y) * cos(z);
	double Y = x * sin(y) * sin(z);
	double Z = x * cos(y);
	
	return Vector3(X,Y,Z);
}
void Vector3::ClampFromTo(Vector3 from, Vector3 to)
{
	if(x<from.x) x=from.x;
	if(y<from.y) y=from.y;
	if(z<from.z) z=from.z;
	if(x>to.x) x=to.x;
	if(y>to.y) y=to.y;
	if(z>to.z) z=to.z;
}
void Vector3::ClampFrom(Vector3 from)
{
	if(x<from.x) x=from.x;
	if(y<from.y) y=from.y;
	if(z<from.z) z=from.z;
}
void Vector3::ClampTo(Vector3 to)
{
	if(x>to.x) x=to.x;
	if(y>to.y) y=to.y;
	if(z>to.z) z=to.z;
}

//Operators
Vector3 Vector3::operator+ (Vector3 vect)
{
	return Vector3( x+vect.x, y+vect.y, z+vect.z );
}
Vector3 Vector3::operator+ (double parm)
{
	return Vector3(x+parm,y+parm,z+parm);
}
void Vector3::operator+= (Vector3 vect)
{
	x+=vect.x;
	y+=vect.y;
	z+=vect.z;
}
Vector3 Vector3::operator- (Vector3 vect)
{
	return Vector3( x-vect.x, y-vect.y, z-vect.z);
}
Vector3 Vector3::operator-()
{
	return Vector3(-x,-y,-z);
}
void Vector3::operator-= (Vector3 vect)
{
	x-=vect.x;
	y-=vect.y;
	z-=vect.z;
}
Vector3 Vector3::operator* (double parm)
{
	return Vector3( x*parm, y*parm, z*parm );
}
Vector3 Vector3::operator/ (double parm)
{
	return Vector3( x/parm, y/parm, z/parm );
}
bool Vector3::operator== (Vector3 vect)
{
	return x==vect.x && y==vect.y && z==vect.z;
}
bool Vector3::operator!= (Vector3 vect)
{
	return x!=vect.x || y!=vect.y || z!=vect.z;
}

//Convershions
GLKVector3 Vector3::AsGLKVector3()
{
	return GLKVector3Make(x, y, z);
}
cv::Matx13d Vector3::HozMat()
{
	return cv::Matx13d(x,y,z);
}
cv::Matx31d Vector3::VerMat()
{
	return cv::Matx31d(x,y,z);
}
cv::Point3f Vector3::cvPoint3f()
{
	return cv::Point3f(x,y,z);
}
Vector2 Vector3::AsVector2()
{
	return Vector2(x,y);
}

