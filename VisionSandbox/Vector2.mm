//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//


#include "Vector2.h"

//Constructors
Vector2::Vector2()
{
	x=0;
	y=0;
}
Vector2::Vector2(float X, float Y)
{
	x=X;
	y=Y;
}
Vector2::Vector2(CGSize size)
{
	x=size.width;
	y=size.height;
}
Vector2::Vector2(cv::Size size)
{
	x=size.width;
	y=size.height;
}
Vector2::Vector2(CGPoint point)
{
	x=point.x;
	y=point.y;
}
Vector2::Vector2(Direction dir)
{
	switch (dir)
	{
		case Up:
			x = 0;
			y = 1;
			break;
		case Down:
			x = 0;
			y = -1;
			break;
		case Left:
			x = -1;
			y = 0;
			break;
		case Right:
			x = 1;
			y = 0;
			break;
	}
}

Vector2::Vector2(double radAngle)
{
	x = cos(radAngle);
	y = sin(radAngle);
	normalize();
}

Vector2::Vector2(cv::Point point)
{
	x = point.x;
	y = point.y;
}
Vector2::Vector2(Vector3 point)
{
	x = point.x;
	y = point.y;
}
Vector2::Vector2(NSString* string)
{
	NSArray*components = [string componentsSeparatedByString:@","];
	if(components.count==2)
	{
		NSString*xString = [components objectAtIndex:0];
		NSString*yString = [components objectAtIndex:1];
		x = [[xString lowercaseString] isEqualToString:@"nan"]?NAN:[xString doubleValue];
		y = [[yString lowercaseString] isEqualToString:@"nan"]?NAN:[yString doubleValue];
	}
	else
	{
		x=NAN;
		y=NAN;
	}
}
Vector2 Vector2::Slope(int quantizedAngle, int numQuantizedAngles)
{
	double eulerAngle = fmod((quantizedAngle*360/numQuantizedAngles),360);
	double radAngle = eulerAngle*M_PI/180;
	if(eulerAngle > 0 && eulerAngle < 90) //in quandrent 1, rise and run positive
	{
		if(eulerAngle < 45)
		{
			return Vector2(1,tan(radAngle)).Normalized();
		}
		else
		{
			return Vector2(1/tan(radAngle),1).Normalized();
		}
	}
	else if(eulerAngle > 90 && eulerAngle < 180) //in quadrent 2, run is negative rise is positive
	{
		if(eulerAngle < 135)
		{
			return Vector2(1/tan(radAngle),1).Normalized();
		}
		else
		{
			return Vector2(-1,-1*tan(radAngle)).Normalized();
		}
	}
	else if(eulerAngle > 180 && eulerAngle < 270)//in quadrent 3, run is negative and rise is negative
	{
		if(eulerAngle < 225)
		{
			return Vector2(-1,-1*tan(radAngle)).Normalized();
		}
		else
		{
			return Vector2(-1/tan(radAngle),-1).Normalized();
		}
	}
	else if(eulerAngle > 270 && eulerAngle < 360)//in quadrent 4, run is positive and rise is negative
	{
		if(eulerAngle < 315)
		{
			return Vector2(-1/tan(radAngle),-1).Normalized();
		}
		else
		{
			return Vector2(1,tan(radAngle)).Normalized();
		}
	}
	else if(eulerAngle == 0)
	{
		return Vector2(1,0);
	}
	else if(eulerAngle == 90)
	{
		return Vector2(0,1);
	}
	else if(eulerAngle == 180)
	{
		return Vector2(-1,0);
	}
	else if(eulerAngle == 270)
	{
		return Vector2(0,-1);
	}
	else
	{
		return Vector2(NAN,NAN); //Never Should Happen
	}
}

//Functions
bool Vector2::isNull()
{
	return !(x==x && y==y);
}
void Vector2::setNull()
{
	x = NAN;
	y = NAN;
}
float Vector2::SqMagnitude()
{
	return x*x + y*y;
}
double Vector2::SqDistanceTo(Vector2 endPoint)
{
	return (x-endPoint.x)*(x-endPoint.x)+(y-endPoint.y)*(y-endPoint.y);
}
float Vector2::Magnitude()
{
	return sqrt(SqMagnitude());
}
float Vector2::Area()
{
	return x*y;
}
float Vector2::Dot(Vector2 vect)
{
	return x*vect.x + y*vect.y;
}
float Vector2::Cross(Vector2 vect)
{
	return x*vect.y-y*vect.x;
}
Vector2 Vector2::Perpendicular()
{
	return Vector2(y,-x);
}
Vector2 Vector2::Normalized()
{
	return Vector2(x, y)/Magnitude();
}
Vector2 Vector2::normalize()
{
	float mag = sqrtf(x*x+y*y);
	x /= mag;
	y /= mag;
	return *this;
}
Vector2 Vector2::FromToBy(Vector2 From, Vector2 To, float By)
{
	return (To-From).Normalized()*By+From;
}
Vector2 Vector2::DevideComponentsByComponentsOf(Vector2 vect)
{
	return Vector2(x/vect.x, y/vect.y);
}
Vector2 Vector2::MultiplyComponentsByComponentsOf(Vector2 vect)
{
	return Vector2(x*vect.x, y*vect.y);
}
Vector2 Vector2::Rounded()
{
	return Vector2(round(x),round(y));
}
Vector2 Vector2::SwitchedComponents()
{
	return Vector2(y,x);
}
Vector2 Vector2::RotatedBy(float radAngle)
{
	float c = cos(radAngle);
	float s = sin(radAngle);
	return Vector2(x*c-y*s, x*s+y*c);
}
Vector2 Vector2::RotatedBy(float c,float s)
{
	return Vector2(x*c-y*s, x*s+y*c);
}
Direction Vector2::orthogonalDirection()
{
	int X = x;
	if(X<0)X=-X;
	int Y = y;
	if(Y<0)Y=-Y;
	if(X >= Y)
	{
		if(x<0) return Left;
		else return Right;
	}
	else
	{
		if(y<0) return Down;
		else return Up;
	}
}

float Vector2::AngleToVector(Vector2 vect)
{
	float deltaDotPq = this->Dot(vect);
	float quotient = deltaDotPq/(this->Magnitude()*vect.Magnitude());
	if(quotient>1)quotient=1;
	if(quotient<-1)quotient=-1;
	return acos( quotient );
}
float Vector2::ClockwiseAngleToVector(Vector2 vect)
{
	return -atan2(Cross(vect), Dot(vect));
}
static double RadiusOfCircleRepresentedByPoints(Vector2 P1, Vector2 P2, Vector2 P3)
{
	float theta = (P1-P2).AngleToVector(P3-P2);
	return (P1-P3).Magnitude()/(2*sin( theta ));
}
Vector2 Vector2::ProjectOnto(Vector2 vect)
{
	double denom = vect.Magnitude();
	if (denom > 0)
	{
		return Dot(vect)/denom;
	}
	return Vector2(NAN, NAN);
}
double Vector2::AngleFromZero()
{
	return atan2(y, x);
}
void Vector2::setWithin(cv::Mat*img)
{
	if(x < 0) x = 0;
	if(x >= img->cols) x = img->cols-1;
	if(y < 0) y = 0;
	if(y >= img->rows) y = img->rows-1;
}
Vector2 Vector2::FlippedHorizontally()
{
	return Vector2(-x,y);
}
Vector2 Vector2::FlippedVertically()
{
	return Vector2(x,-y);
}
Vector2 Vector2::OrthogonalVectorPos()
{
	return Vector2(-y,x);
}
Vector2 Vector2::OrthogonalVectorNeg()
{
	return Vector2(y,-x);
}
NSString* Vector2::csv()
{
	return [NSString stringWithFormat:@"%f,%f",x,y];
}
Vector2 Vector2::Floored()
{
	return Vector2(floor(x), floor(y));
}

//Operators
Vector2 Vector2::operator+ (Vector2 vect)
{
	return Vector2( x+vect.x, y+vect.y );
}
void Vector2::operator+= (Vector2 vect)
{
	x+=vect.x;
	y+=vect.y;
}
Vector2 Vector2::operator- (Vector2 vect)
{
	return Vector2( x-vect.x, y-vect.y);
}
Vector2 Vector2::operator-()
{
	return Vector2(-x,-y);
}
void Vector2::operator-= (Vector2 vect)
{
	x-=vect.x;
	y-=vect.y;
}
Vector2 Vector2::operator* (float parm)
{
	return Vector2( x*parm, y*parm );
}

Vector2 Vector2::operator* (Vector2 vect)
{
    return Vector2(x*vect.x,y*vect.y);
}

Vector2 Vector2::operator/ (float parm)
{
	return Vector2( x/parm, y/parm );
}
Vector2 Vector2::operator/ (Vector2 vect)
{
	return Vector2( x/vect.x, y/vect.y );
}
bool Vector2::operator== (Vector2 vect)
{
	return x==vect.x && y==vect.y;
}
bool Vector2::operator!= (Vector2 vect)
{
	return x!=vect.x || y!=vect.y;
}

//Convershions
CGPoint Vector2::AsCGPoint()
{
	CGPoint p;
	p.x = x;
	p.y = y;
	return p;
}
CGSize Vector2::AsCGSize()
{
	return CGSizeMake(x, y);
}
cv::Size Vector2::AsCVSize()
{
	return cv::Size(x, y);
}
cv::Point Vector2::AsCvPoint()
{
	return cv::Point((float)x,(float)y);
}
NSPoint Vector2::AsNSPoint()
{
	return NSMakePoint(x, y);
}
