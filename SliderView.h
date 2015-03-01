//
//  SliderView.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/13/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FunctionVisualTableCellView.h"
@interface SliderView : FunctionVisualTableCellView <NSTextFieldDelegate>
{
	IBOutlet NSTextField *field;
	IBOutlet NSSlider *slider;
	double min,max;
}
@property NSString *numType;
@property double min;
@property double max;
- (int)intVal;

@end
