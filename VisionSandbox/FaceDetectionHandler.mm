//
//  FaceDetectionHandler.m
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 6/23/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "FaceDetectionHandler.h"

@implementation FaceDetectionHandler
@synthesize dets,faceRectDict;
-(id)initWithShapePredictorFile:(NSString *)spFile
{
    self = [super init];
    if (self) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:spFile]) {
            dlib::deserialize(spFile.UTF8String) >> sp;
            loadedLandmarker = true;
        }
        else {
            NSLog(@"Warning: could not load facial landmarking model.  You will not be able to detect facial landmarks.");
            loadedLandmarker = false;
        }
        faceRectDict = [[NSMutableDictionary alloc] init];
        detector = dlib::get_frontal_face_detector();
    }
    return self;
}
-(void)detectFacesInImage:(OpenImageHandler *)img atScale:(int)scale
{
    if(scale < 0) scale = 0;
    [faceRectDict removeAllObjects];
    dlib::array2d<dlib::rgb_pixel> dImage;
    cv::Mat cvImg;
    cv::cvtColor(img.Cv, cvImg, CV_BGRA2BGR);
    dlib::assign_image(dImage, dlib::cv_image<dlib::bgr_pixel>(cvImg));
    std::vector<dlib::rectangle> ddets  = detector(dImage);
//    std::vector<NSRect> dets;
    for(int i = 0; i < ddets.size(); i++)
    {
        
        dlib::rectangle d = ddets[i];
        NSRect r = NSMakeRect(d.left(), d.top(), d.right()-d.left(), d.bottom()-d.top());
        dets.push_back(r);
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[@(r.origin.x),@(r.origin.y),@(r.size.width),@(r.size.height)] forKeys:@[@"x coord",@"y coord",@"width",@"height"]];
        [faceRectDict setObject:dict forKey:[NSString stringWithFormat:@"Face %i",i]];
    }
}

@end
