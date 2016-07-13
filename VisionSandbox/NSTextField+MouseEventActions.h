//
//  NSTextFiled+MouseEventActions.h
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 7/13/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTextField (NSTextField_MouseEventActions)

- (id)initWithCVMat:(const cv::Mat&)cvMat;
- (id)initWithOpenImageHandler:(OpenImageHandler *)img;

+ (NSImage*)imageWithCVMat:(const cv::Mat&)cvMat;
+ (NSImage*)imageWithOpenImageHandler:(OpenImageHandler *)img;

- (cv::Mat)CVMat;
- (CGImageRef)CGImage;
- (cv::Mat)CVGrayscaleMat;
- (OpenImageHandler*)OpenImageHandler;

@end

