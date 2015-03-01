//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#include "vector2Rect.h"

//Constructors
vector2Rect::vector2Rect()
{
	
}
vector2Rect::vector2Rect(Vector2 Origin, Vector2 Size)
{
	origin = Origin;
	size = Size;
}
vector2Rect::vector2Rect(float x, float y, float width, float height)
{
	origin = Vector2(x,y);
	size = Vector2(width,height);
}
vector2Rect::vector2Rect(NSRect r)
{
	origin = Vector2(r.origin.x,r.origin.y);
	size = Vector2(r.size.width,r.size.height);
}
//vector2Rect::vector2Rect(CGRect r)
//{
//	origin = Vector2(r.origin.x,r.origin.y);
//	size = Vector2(r.size.width,r.size.height);
//}

//Functions
bool vector2Rect::ContainsPoint(Vector2 point)
{
	if(point.x>=origin.x && point.x<=origin.x+size.x && point.y>=origin.y && point.y<=origin.y+size.y) return true;
	return false;
}
float vector2Rect::AspectRatio()
{
	return size.x/size.y;
}

//Operators
vector2Rect vector2Rect::operator+ (vector2Rect rect)
{
	vector2Rect newRect;
	
	if(origin.x<rect.origin.x) newRect.origin.x = origin.x;
	else newRect.origin.x = rect.origin.x;
	if(origin.y<rect.origin.y) newRect.origin.y = origin.y;
	else newRect.origin.y = rect.origin.y;
	
	if(origin.x+size.x > rect.origin.x+rect.size.x) newRect.size.x = origin.x+size.x-newRect.origin.x;
	else newRect.size.x = rect.origin.x+rect.size.x-newRect.origin.x;
	if(origin.y+size.y > rect.origin.y+rect.size.y) newRect.size.y = origin.y+size.y-newRect.origin.y;
	else newRect.size.y = rect.origin.y+rect.size.y-newRect.origin.y;
	
	return newRect;
}
vector2Rect vector2Rect::operator+ (Vector2 vect)
{
	vector2Rect newRect;
	
	if(origin.x<vect.x) newRect.origin.x = origin.x;
	else newRect.origin.x = vect.x;
	if(origin.y<vect.y) newRect.origin.y = origin.y;
	else newRect.origin.y = vect.y;
	
	if(origin.x+size.x > vect.x) newRect.size.x = origin.x+size.x-newRect.origin.x;
	else newRect.size.x = vect.x-newRect.origin.x;
	if(origin.y+size.y > vect.y) newRect.size.y = origin.y+size.y-newRect.origin.y;
	else newRect.size.y = vect.y-newRect.origin.y;
	
	return newRect;
}
void vector2Rect::operator+= (vector2Rect rect)
{
	if(origin.x>rect.origin.x) origin.x = rect.origin.x;
	if(origin.y>rect.origin.y) origin.y = rect.origin.y;
	
	if(origin.x+size.x < rect.origin.x+rect.size.x) size.x = rect.origin.x+rect.size.x-origin.x;
	if(origin.y+size.y < rect.origin.y+rect.size.y) size.y = rect.origin.y+rect.size.y-origin.y;
}
void vector2Rect::operator+= (Vector2 vect)
{
	if(origin.x>vect.x) origin.x = vect.x;
	if(origin.y>vect.y) origin.y = vect.y;
	
	if(origin.x+size.x < vect.x) size.x = vect.x-origin.x;
	if(origin.y+size.y < vect.y) size.y = vect.y-origin.y;
}
bool vector2Rect::operator== (vector2Rect rect)
{
	if(rect.origin==origin && rect.size==rect.size) return true;
	return false;
}
bool vector2Rect::operator!= (vector2Rect rect)
{
	if(rect.origin!=origin || rect.size!=rect.size) return true;
	return false;
}

//Convershions
CGRect vector2Rect::AsCGRect()
{
	CGRect rect;
	rect.origin.x = origin.x;
	rect.origin.y = origin.y;
	rect.size.width = size.x;
	rect.size.height = size.y;
	return rect;
}

std::vector<cv::Point> vector2Rect::AsContour()
{
	std::vector<cv::Point> contour;
	contour.push_back(cv::Point(origin.x,origin.y));
	contour.push_back(cv::Point(origin.x+size.x-1,origin.y));
	contour.push_back(cv::Point(origin.x+size.x,origin.y+size.y-1));
	contour.push_back(cv::Point(origin.x,origin.y+size.y-1));
	return contour;
}

