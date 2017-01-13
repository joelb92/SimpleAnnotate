//
//  ImageAnnotationView.h
//  SimpleAnnotate
//
//  Created by Joel Brogan on 11/25/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#include <opencv2/opencv.hpp>
@interface ImageAnnotationView : NSImageView
{
    NSRect eyebox;
    NSRect trackingRect;
}
- (void)setDisplayedImage:(NSImage *)im;
@end
