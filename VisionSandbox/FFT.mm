//
//  FFT.m
//  VisionSandbox
//
//  Created by Joel Brogan on 9/26/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import "FFT.h"

@implementation FFT
-(id)init
{
	self = [super init];
	if (self) {
		functionName = @"Fast Fourier Transform";
		functionTreePath = @"OpenCV/Basic Operations";
		//Defaults

		inputType = OpenImageHandler.class;
		outputType = inputType;
//		propertySettings = @{@"set_kernelSize": @{@"min":@(1)}};
		[self loadParametersToView];
		[self applyParameterViewSettings];
	}
	return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
//		set_kernelSize = [aDecoder decodeDoubleForKey:@"kernelSize"];
//		set_iterations = [aDecoder decodeDoubleForKey:@"iterations"];
//		propertySettings = @{@"set_kernelSize": @{@"min":@(1)}};
		[self applyParameterViewSettings];
	}
	return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
//	[aCoder encodeDouble:set_kernelSize forKey:@"kernelSize"];
//	[aCoder encodeDouble:set_iterations forKey:@"iterations"];
}
-(id)copyWithZone:(NSZone *)zone
{
	FFT *newFunc = [super copyWithZone:zone];
//	newFunc.set_kernelSize = set_kernelSize;
//	newFunc.set_iterations = set_iterations;
	[newFunc loadParametersToView];
	return newFunc;
}
-(id)runMethod:(id)input
{
	OpenImageHandler *img = (OpenImageHandler *)input;
	cv::Mat image = img.Cv;
	//	cv::Mat converted;
	//	cv::Mat transformed;
	//	image->convertTo(converted, CV_32F);
	//
	//	cv::dft(converted, transformed);
	cv::Mat I = image;
//	cv::cvtColor(I, I, CV_RGB2GRAY);
    if( I.empty())
		NSLog(@"bad");
	
	cv::Mat padded;                            //expand input image to optimal size
    int m = cv::getOptimalDFTSize( I.rows );
    int n = cv::getOptimalDFTSize( I.cols ); // on the border add zero values
	cv::copyMakeBorder(I, padded, 0, m - I.rows, 0, n - I.cols, cv::BORDER_CONSTANT, cv::Scalar::all(0));
	
	cv::Mat planes[] = {cv::Mat_<float>(padded), cv::Mat::zeros(padded.size(), CV_32F)};
	cv::Mat complexI;
    merge(planes, 2, complexI);         // Add to the expanded another plane with zeros
	
    dft(complexI, complexI);            // this way the result may fit in the source matrix
	
    // compute the magnitude and switch to logarithmic scale
    // => log(1 + sqrt(Re(DFT(I))^2 + Im(DFT(I))^2))
    split(complexI, planes);                   // planes[0] = Re(DFT(I), planes[1] = Im(DFT(I))
    magnitude(planes[0], planes[1], planes[0]);// planes[0] = magnitude
	cv::Mat magI = planes[0];
	
	magI += cv::Scalar::all(1);                    // switch to logarithmic scale
    log(magI, magI);
	
    // crop the spectrum, if it has an odd number of rows or columns
    magI = magI(cv::Rect(0, 0, magI.cols & -2, magI.rows & -2));
	
    // rearrange the quadrants of Fourier image  so that the origin is at the image center
    int cx = magI.cols/2;
    int cy = magI.rows/2;
	
	cv::Mat q0(magI, cv::Rect(0, 0, cx, cy));   // Top-Left - Create a ROI per quadrant
	cv::Mat q1(magI, cv::Rect(cx, 0, cx, cy));  // Top-Right
	cv::Mat q2(magI, cv::Rect(0, cy, cx, cy));  // Bottom-Left
	cv::Mat q3(magI, cv::Rect(cx, cy, cx, cy)); // Bottom-Right
	
	cv::Mat tmp;                           // swap quadrants (Top-Left with Bottom-Right)
    q0.copyTo(tmp);
    q3.copyTo(q0);
    tmp.copyTo(q3);
	
    q1.copyTo(tmp);                    // swap quadrant (Top-Right with Bottom-Left)
    q2.copyTo(q1);
    tmp.copyTo(q2);
	
    normalize(magI, magI, 0, 1, CV_MINMAX); // Transform the matrix with float values into a
	// viewable image form (float between values 0 and 1).
	cv::Mat converted;
	magI = magI*255;
	magI.convertTo(converted, CV_8UC1);
	img = [[OpenImageHandler alloc] initWithCVMat:converted Color:White BinaryImage:false];
	if(displayStepAsLayer)
	{
		[GLViewListCommand AddObject:img.Displayable ToViewKeyPath:@"MainView" ForKeyPath:@"Fourier Transform"];
	}
	return input;
}

@end
