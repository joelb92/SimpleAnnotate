//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "Vector2.h"

#ifndef AvVector2_H
#define AvVector2_H

class AvVector2
{
public:
	Vector2 Average;
	int NumberOfPoints;
	
	AvVector2();
	AvVector2(Vector2 vect);
	
	void AddVector2(Vector2 p);
	void AddAvVector2(AvVector2 p);
	void resetWithVector2(Vector2 vect);
};

#endif