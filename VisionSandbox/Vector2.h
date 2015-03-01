//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "math.h"
#import "Vector3.h"
#ifndef Vector2_H_
#define Vector2_H_
typedef enum
{
	Up = 1,
	Down = 2,
	Left = 4,
	Right = 8
} Direction;

class Vector3;

class Vector2
{
public:
	//Components
	float x, y;
	
	//Constructors
	Vector2();
	Vector2(float X, float Y);
	Vector2(CGSize size);
	Vector2(cv::Size size);
	Vector2(CGPoint point);
	Vector2(Direction dir);
	Vector2(double radAngle);
	Vector2(cv::Point point);
	Vector2(Vector3 point);
//	Vector2(NSPoint point);
	Vector2(NSString* string);
	static Vector2 Slope(int quantizedAngle, int numQuantizedAngles);
	
	//Functions
	bool isNull();
	void setNull();
	float SqMagnitude();
	double SqDistanceTo(Vector2 endPoint);
	float Magnitude();
	float Area();
	float Dot(Vector2 vect);
	float Cross(Vector2 vect);
	Vector2 Perpendicular();
	Vector2 Normalized();
	Vector2 normalize();
	Vector2 FromToBy(Vector2 From, Vector2 To, float By); //Linearly interpolate 'from' 'to' 'by' a percent (0 to 1)
	Vector2 DevideComponentsByComponentsOf(Vector2 vect);
	Vector2 MultiplyComponentsByComponentsOf(Vector2 vect);
	Vector2 Rounded();
	Vector2 SwitchedComponents();
	Vector2 RotatedBy(float radAngle);
	Vector2 RotatedBy(float c,float s);
	Direction orthogonalDirection();
	float AngleToVector(Vector2 vect);
	float ClockwiseAngleToVector(Vector2 vect);
	static double RadiusOfCircleRepresentedByPoints(Vector2 P1, Vector2 P2, Vector2 P3);
	Vector2 ProjectOnto(Vector2 vect);
	double AngleFromZero();
	void setWithin(cv::Mat*img);
	Vector2 FlippedHorizontally();
	Vector2 FlippedVertically();
	Vector2 OrthogonalVectorPos();
	Vector2 OrthogonalVectorNeg();
	Vector2 Floored();
	
	//Operators
	Vector2 operator+ (Vector2 vect);
	void operator+= (Vector2 vect);
	Vector2 operator- (Vector2 vect);
	Vector2 operator-();
	void operator-= (Vector2 vect);
	Vector2 operator* (float parm);
    Vector2 operator* (Vector2 vect);
	Vector2 operator/ (float parm);
    Vector2 operator/ (Vector2 vect);
	bool operator== (Vector2 vect);
	bool operator!= (Vector2 vect);
	
	//Convershions
	CGPoint AsCGPoint();
	CGSize AsCGSize();
	cv::Size AsCVSize();
	cv::Point AsCvPoint();
	NSPoint AsNSPoint();
	NSString* csv();
	//Tests
private:
};

//struct Vector2SortByDistance
//{
//	Vector2SortByDistance(Vector2 refPoint) { this->refPoint = refPoint; }
//    inline bool operator() (const Vector2& vec1, const Vector2& vec2)
//    {
//        return (Vector2(vec1).SqDistanceTo(refPoint) < Vector2(vec2).SqDistanceTo(refPoint));
//    }
//	Vector2 refPoint;
//};
//
//namespace std
//{
//	namespace tr1
//	{
//    // Specializations for unordered containers
//	
//    template <>
//    struct hash<Vector2> : public unary_function<Vector2, size_t>
//    {
//        size_t operator()(const Vector2& value) const
//        {
//			std::tr1::hash<float> fHash;
//			return (51 + fHash(value.x)) * 51 + fHash(value.y);
//        }
//
//    };
//	
//	} // namespace tr1
//	
//	template <>
//	struct equal_to<Vector2> : public unary_function<Vector2, bool>
//	{
//		bool operator()(const Vector2& x, const Vector2& y) const
//		{
//			return x.x == y.x && x.y == y.y;
//		}
//	};
//	
//} // namespace std

#endif