//
//  objectTracker.h
//  SimpleAnnotate
//
//  Created by Joel Brogan on 8/25/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "opencv2/opencv.hpp"
#include <dlib/image_processing.h>
#include <dlib/gui_widgets.h>
#include <dlib/image_io.h>
#include <dlib/dir_nav.h>
#include <dlib/opencv/cv_image.h>
@interface objectTracker : NSObject
{
    dlib::correlation_tracker tracker;
    bool isInitialized;
    cv::Rect currentRectCV;
    NSRect currentRectNS;
    
}
@end
