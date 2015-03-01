//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//


#import "Color.h"
 
Color::Color()
{
	r=0;
	g=0;
	b=0;
}

Color::Color(short int red, short int green, short int blue)
{
	r=red;
	g=green;
	b=blue;
}

Color::Color(NSColor *c)
{
	const CGFloat*colorComponents = CGColorGetComponents(c.CGColor);
	r = colorComponents[0]*255.0;
	g = colorComponents[1]*255.0;
	b = colorComponents[2]*255.0;
}

float Color::sqMagnitude()
{
    return (r^2+g^2+b^2);
}
float Color::magnitude()
{
    return sqrt(r^2+g^2+b^2);
}
Color Color::LerpToColorBy(Color color, float by)
{
	return Color(((float)(color.r-r))*by+r, ((float)(color.g-g))*by+g, ((float)(color.b-b))*by+b);
}

//Operators
Color Color::operator+ (Color col)
{
	return Color(r+col.r, g+col.g, b+col.b);
}
void Color::operator+= (Color col)
{
	r+=col.r;
	g+=col.g;
	b+=col.b;
}
Color Color::operator- (Color col)
{
	return Color(r-col.r, g-col.g, b-col.b);
}
void Color::operator-= (Color col)
{
	r-=col.r;
	g-=col.g;
	b-=col.b;
}
Color Color::operator* (float parm)
{
	return Color(r*parm, g*parm, b*parm);
}
Color Color::operator/ (float parm)
{
	return Color(r/parm, g/parm, b/parm);
}
bool Color::operator== (Color col)
{
	return r==col.r && g==col.g && b==col.b;
}
bool Color::operator!= (Color col)
{
	return r!=col.r || g!=col.g || b!=col.b;
}

NSColor* Color::AsNSColor()
{
	float rf = ((float)r)/255.0;
	float gf = ((float)g)/255.0;
	float bf = ((float)b)/255.0;
	return [NSColor colorWithDeviceRed:rf green:gf blue:bf alpha:1];
}
cv::Scalar Color::AsCVScaler()
{
	return cv::Scalar(r,g,b);
}
NSString* Color::csv()
{
	return [NSString stringWithFormat:@"%i,%i,%i",r,g,b];
}