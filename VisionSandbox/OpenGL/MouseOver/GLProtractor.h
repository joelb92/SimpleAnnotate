//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLViewTool.h"
#import "Vector3Arr.h"

@interface GLProtractor : GLViewTool
{
	Vector3Arr points;
	
	int mousedOverIndex;
	
	bool initialized;
}

- (float)Angle;
- (void)ResetHandles;
@end
