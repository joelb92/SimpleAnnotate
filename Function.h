//
//  Function.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/9/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunctionVisualParametersView.h"
#import "Timer.h"
#import "VisualFunctionViewHolder.h"
#import "ComboView.h"
#import "SliderView.h"
#import "SliderDoubleView.h"
#import "CheckboxView.h"
#import "PropertyUtility.h"
#import <objc/runtime.h>
#import "OpenImageHandler.h"
#import "GLViewListCommand.h"
@interface Function : NSObject <NSCoding,NSCopying,NSPasteboardWriting,NSPasteboardReading>
{
	FunctionVisualParametersView *parametersView;
	NSString *functionName;
	NSString *functionTreePath;
	NSString *documentation;
	NSMutableDictionary *dynamicProps;
	Timer *timer;
	double runTime;
	bool hasSettingsWindow;
	bool displayStepAsLayer;
	Class inputType;
	Class outputType;
	NSDictionary *propertySettings;
}
@property FunctionVisualParametersView *parametersView;
@property NSString *functionName;
@property NSString *documentation;
@property double runTime;
@property bool displayStepAsLayer;
@property bool hasSettingsWindow;
@property (readonly) Class inputType;
@property (readonly) Class outputType;
@property NSString *functionTreePath;
- (id)init;
-(id)runMethod:(id)input;
- (id)run:(id)input;
- (void)beginRun;
- (void)endRun;
- (void)sendError;
- (void)applyParameterViewSettings;
-(void)loadParametersToView;
@end
