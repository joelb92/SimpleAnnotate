//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//


#import <Foundation/Foundation.h>

#ifndef Color_H_
#define Color_H_
class Color
{
public:
	//Components
	short int r,g,b;
	
	//Constructors
	Color();
	Color(short int red, short int green, short int blue);
	Color(NSColor * c);
    float sqMagnitude();
    float magnitude();
	Color LerpToColorBy(Color color, float by);
    
	//Operators
	Color operator+ (Color col);
	void operator+= (Color col);
	Color operator- (Color col);
	void operator-= (Color col);
	Color operator* (float parm);
	Color operator/ (float parm);
	bool operator== (Color col);
	bool operator!= (Color col);
	
	NSColor* AsNSColor();
	cv::Scalar AsCVScaler();
	NSString*csv();
private:
};

#endif

static const Color White = Color(255,255,255);
static const Color LightGrey = Color(191,191,191);
static const Color Grey = Color(128,128,128);
static const Color DarkGrey = Color(64,64,64);
static const Color Black = Color(0,0,0);

static const Color Red = Color(255,0,0);
static const Color Green = Color(0,255,0);
static const Color Blue = Color(0,0,255);

static const Color Yellow = Color(255,255,0);
static const Color Magenta = Color(255,0,255);
static const Color Cyan = Color(0,255,255);