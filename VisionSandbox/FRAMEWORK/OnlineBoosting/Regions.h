#pragma once

#include <assert.h>
#include <math.h>

#include <opencv2/opencv.hpp>
//#include "opencv2/legacy/legacy.hpp"

class Point2D;
class Size2;

class Color2
{
public: 

	Color2();
	Color2(int red, int green, int blue);
	Color2(int idx);

	int red;
	int green;
	int blue;
};

class Rect2
{
public:

	Rect2();
	Rect2(int upper, int left, int height, int width);

	int upper;
	int left;
	int height;
	int width;

	float confidence;

	Rect2 operator+ (Point2D p);
	Rect2 operator+ (Rect2 r);
	Rect2 operator- (Point2D p);
	Rect2 operator* (float f);
	Rect2 operator= (Size2 s);
	Rect2 operator= (Rect2 r);
	bool operator== (Rect2 r);
	bool isValid (Rect2 validROI);
	
	int checkOverlap (Rect2 rect);
	int getArea(){return height*width;};
    bool isDetection(Rect2 eval, unsigned char *labeledImg, int imgWidth);

	CvRect getCvRect();
}; 

class Size2
{
public:

	Size2();
	Size2(int height, int width);

	int height;
	int width;

	Size2 operator= (Rect2 r);
	Size2 operator= (Size2 s);
	Size2 operator* (float f);
	bool operator== (Size2 s);

	int getArea();
};


class Point2D
{
public:

	Point2D();
	Point2D(int row, int col);

	int row;
	int col;

	Point2D operator+ (Point2D p);
	Point2D operator- (Point2D p);
	Point2D operator= (Point2D p);
	Point2D operator= (Rect2 r);

};