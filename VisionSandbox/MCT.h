//
//  MCT.h
//  EBOLO
//
//  Created by Joel Brogan on 2/10/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
@interface MCT : NSObject
-(cv::Mat) CensusTransform:(cv::Mat)imgIn;
-(cv::Mat) ModifiedCensusTransform:(cv::Mat)imgIn;
-(cv::Mat) ModifiedColorCensusTransform:(cv::Mat)imgIn;

@end
