//
//  CamShiftTracker.h
//  SimpleAnnotate
//
//  Created by Joel Brogan on 8/4/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "opencv2/opencv.hpp"
@interface CamShiftTracker : NSObject
{
//    cv::Mat frame, hsv, hue, mask, hist, histimg, backproj;
//    cv::Mat image;
//    cv::Rect trackWindow;
//    Point origin;
//    cv::Rect selection;
//    int vmin, vmax, smin;
//    float hranges[2];
//    const float* phranges;
//    bool backprojMode;
//    bool paused;
//    int hsize;
}
-(void) inputImage:(cv::Mat)input selectedArea:(cv::Rect)selectedArea;
-(cv::Rect) trackOnImage:(cv::Mat)img;
int runTracking();
@end
