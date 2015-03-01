//
//  Threshold.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/10/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import "Threshold.h"

@implementation Threshold
@synthesize set_thresh,set_maxVal,set_type;
-(id)init
{
	self = [super init];
	if (self) {
		functionName = @"Threshold";
		functionTreePath = @"OpenCV/Basic Operations";
		//Defaults
		set_thresh = 127;
		set_maxVal =254;
		propertySettings = @{@"set_type":@{@"items":@{@"Combo1":@(0),@"Combo2":@(2)}}};
		inputType = OpenImageHandler.class;
		outputType = inputType;
		[self applyParameterViewSettings];
		[self loadParametersToView];
	}
	return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		set_thresh = [aDecoder decodeDoubleForKey:@"thresh"];
		set_maxVal = [aDecoder decodeDoubleForKey:@"maxVal"];
//		set_type = [aDecoder decodeDoubleForKey:@"type"];
		propertySettings = @{@"set_maxVal": @{@"max":@(255)}};
		[self loadParametersToView];
	}
	return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeDouble:set_thresh forKey:@"thresh"];
	[aCoder encodeDouble:set_maxVal forKey:@"maxVal"];
//	[aCoder encodeDouble:set_type forKey:@"type"];
	
}
-(id)copyWithZone:(NSZone *)zone
{
	Threshold *newFunc = [super copyWithZone:zone];
	newFunc.set_thresh = set_thresh;
	newFunc.set_maxVal = set_maxVal;
	newFunc.set_type = set_type.copy;
	[newFunc loadParametersToView];
	return newFunc;
}
-(id)runMethod:(id)input
{
	id output = nil;
	if ([input isKindOfClass:inputType]) {
		OpenImageHandler *img = (OpenImageHandler *)input;
		cv::threshold(img.Cv, img.Cv, set_thresh, set_maxVal, 1);
		output = input;
		if(displayStepAsLayer)
		{
			[GLViewListCommand AddObject:img.copy ToViewKeyPath:@"MainView" ForKeyPath:functionName];
		}
	}
	else{
		[self sendError];
	}
	return output;
}
@end
