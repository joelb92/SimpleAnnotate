//
//  NSImage+OpenCV.h
//  DIF Map Decoder
//
//  Created by Joel Brogan on 9/13/13.
//
//	Partially Coppied from http://stackoverflow.com/questions/8563356/nsimage-to-cvmat-and-vice-versa

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "OpenImageHandler.h"
#import "NSImage+OpenCV.h"

@interface NSImage (NSImage_OpenCV)

- (id)initWithCVMat:(const cv::Mat&)cvMat;
- (id)initWithOpenImageHandler:(OpenImageHandler *)img;

+ (NSImage*)imageWithCVMat:(const cv::Mat&)cvMat;
+ (NSImage*)imageWithOpenImageHandler:(OpenImageHandler *)img;

- (cv::Mat)CVMat;
- (CGImageRef)CGImage;
- (cv::Mat)CVGrayscaleMat;
- (OpenImageHandler*)OpenImageHandler;

@end
