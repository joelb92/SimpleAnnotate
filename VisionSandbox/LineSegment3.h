//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector3.h"

#ifndef LineSegment3_H_
#define LineSegment3_H_
class LineSegment3
{
public:
	//Components
	Vector3 origin;
	Vector3 termintation;
	
	//Constructors
	LineSegment3();
	LineSegment3(Vector3 ORIGIN, Vector3 TERMINATION);
	
	//Functions
	Vector3 DirectionUnNormalized();
	Vector3 DirectionNormalized();
	
	Vector3 ProjectionOfPoint(Vector3 point); //Untested in 3D!
	
	//Operators
	bool operator== (LineSegment3 seg);
	bool operator!= (LineSegment3 seg);
private:
};

#endif