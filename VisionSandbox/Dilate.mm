//
//  Dilate.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/15/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import "Dilate.h"

@implementation Dilate
@synthesize set_iterations,set_kernelSize;
-(id)init
{
	self = [super init];
	if (self) {
		functionName = @"Dilate";
		functionTreePath = @"OpenCV/Basic Operations";
		//Defaults
		set_kernelSize = 3;
		set_iterations = 1;
		inputType = OpenImageHandler.class;
		outputType = inputType;
		propertySettings = @{@"set_kernelSize": @{@"min":@(1)}};
		[self loadParametersToView];
		[self applyParameterViewSettings];
	}
	return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		set_kernelSize = [aDecoder decodeDoubleForKey:@"kernelSize"];
		set_iterations = [aDecoder decodeDoubleForKey:@"iterations"];
		propertySettings = @{@"set_kernelSize": @{@"min":@(1)}};
		[self applyParameterViewSettings];
	}
	return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeDouble:set_kernelSize forKey:@"kernelSize"];
	[aCoder encodeDouble:set_iterations forKey:@"iterations"];
}
-(id)copyWithZone:(NSZone *)zone
{
	Dilate *newFunc = [super copyWithZone:zone];
	newFunc.set_kernelSize = set_kernelSize;
	newFunc.set_iterations = set_iterations;
	[newFunc loadParametersToView];
	return newFunc;
}
-(id)runMethod:(id)input
{
	OpenImageHandler *img = (OpenImageHandler *)input;
	cv::dilate(img.Cv, img.Cv, cv::getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(set_kernelSize,set_kernelSize)),cv::Point(-1,-1),set_iterations);
	if(displayStepAsLayer)
	{
		[GLViewListCommand AddObject:img.copy ToViewKeyPath:@"MainView" ForKeyPath:@"Dilate"];
	}
	return input;
}
@end
