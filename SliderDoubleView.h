//
//  SliderDoubleView.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/14/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "FunctionVisualTableCellView.h"
@interface SliderDoubleView : FunctionVisualTableCellView
{
	IBOutlet NSTextField *field;
	IBOutlet NSSlider *slider;
	double min,max;
}
@property NSString *numType;
@property double min;
@property double max;
- (double)doubleVal;
@end
