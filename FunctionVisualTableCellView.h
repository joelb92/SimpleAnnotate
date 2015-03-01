//
//  FunctionVisualTableCellView.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/9/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ColorTableCellView.h"
@interface FunctionVisualTableCellView : ColorTableCellView
-(void)applySetting:(id)setting forKey:(NSString *)key;
-(void)applyValue:(id)val;
-(id)getValue;
-(void)settingChanged;
@end
