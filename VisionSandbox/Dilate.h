//
//  Dilate.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/15/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import "Function.h"

@interface Dilate : Function
{
	int set_kernelSize;
	int set_iterations;
}
@property int set_kernelSize;
@property int set_iterations;
@end
