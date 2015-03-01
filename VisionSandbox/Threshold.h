//
//  Threshold.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/10/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import "Function.h"
//#import "OpenImageHandler.h"

@interface Threshold : Function
{
	double set_thresh;
	double set_maxVal;
	NSString *set_type;
}
@property double set_thresh;
@property double set_maxVal;
@property NSString *set_type;

@end
