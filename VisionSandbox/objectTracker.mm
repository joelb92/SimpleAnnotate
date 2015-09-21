//
//  objectTracker.m
//  SimpleAnnotate
//
//  Created by Joel Brogan on 8/25/15.
//  Copyright (c) 2015 University of Notre Dame. All rights reserved.
//

#import "objectTracker.h"
using namespace cv;
using namespace std;
@implementation objectTracker
-(id)initWithImage:(cv::Mat) img ROI:(NSRect)r
{
    self = [super init];
    if (self) {
//        cv::Mat startImage;
//        if (img.channels() > 1) {
//             cv::cvtColor(img, startImage, CV_BGR2GRAY);
//        }
//        else startImage = img;
//        dlib::cv_image<uchar> dImg(startImage);
//        tracker.start_track(img, dlib::centered_rect(dlib::point(r.origin.x+r.size.width/2,r.origin.y+r.size.height/2), r.size.width, r.size.height));
//        currentRectNS = r;
//        currentRectCV = cv::Rect(currentRectNS.origin.x,currentRectNS.origin.y,currentRectNS.size.width,currentRectNS.size.height);
//        isInitialized = true;
    }
    return self;
}

-(void)updateTracker:(cv::Mat) image
{
//    cv::Mat img;
//    if (img.channels() > 1) {
//        cv::cvtColor(img, image, CV_BGR2GRAY);
//    }
//    else img = image;
//    dlib::cv_image<uchar> dImg(img);
//    tracker.update(img);
//    dlib::drectangle newRect =  tracker.get_position();
//    currentRectNS = NSMakeRect(newRect.left(), newRect.top(), newRect.width(), newRect.height());
//    currentRectCV = cv::Rect(currentRectNS.origin.x,currentRectNS.origin.y,currentRectNS.size.width,currentRectNS.size.height);
}
@end
