//
//  ComboView.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/13/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FunctionVisualTableCellView.h"
@interface ComboView : FunctionVisualTableCellView
{
	IBOutlet NSComboBox *comboBox;
	NSMutableDictionary *items;
}
@property NSMutableDictionary *items;
-(id)selectedValue;
@end
