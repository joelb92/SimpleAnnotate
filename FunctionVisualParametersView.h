//
//  FunctionVisualParametersView.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/9/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ColorTableCellView.h"
@interface FunctionVisualParametersView : ColorTableCellView
{
	NSMutableDictionary *subViewDictionary;
	int totalRunningHeight;
}
-(void)addSubview:(NSTableCellView *)aView forKey:(NSString *)key;
-(NSTableCellView *)subviewForKey:(NSString *)key;
@end
