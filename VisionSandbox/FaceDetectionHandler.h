//
//  FaceDetectionHandler.h
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 6/23/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenImageHandler.h"
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing.h>
//#include <dlib/image_processing/render_face_detections.h>
#include <dlib/opencv.h>

@interface FaceDetectionHandler : NSObject
{
    OpenImageHandler * image;
    dlib::shape_predictor sp;
    dlib::frontal_face_detector detector;
    std::vector<NSRect> dets;
    bool loadedLandmarker;
    NSMutableDictionary *faceRectDict;
}
@property (readonly) std::vector<NSRect> dets;
@property (readonly) NSDictionary *faceRectDict;
-(id)initWithShapePredictorFile:(NSString *) spFile;
-(void)detectFacesInImage:(OpenImageHandler *)img atScale:(int)scale;
-(void)detectFacesInMatImage:(cv::Mat )img atScale:(int)scale;

@end
