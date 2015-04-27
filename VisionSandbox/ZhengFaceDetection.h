//
//  ZhengFaceDetection.h
//  EBOLO
//
//  Created by Joel Brogan on 3/13/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import "MCT.h"
@interface ZhengFaceDetection : NSObject
{
    std::vector<cv::Mat> trainingSet;
    std::vector<int> trainingSetTruth;
    std::vector<std::vector<float> >weights;
    std::vector<std::vector<int> >classifiers;
    std::vector<int> featureAmountsForStage;
    std::vector<std::vector<float> >AforStage;
    std::vector<float>ASumForStage;
    std::vector<std::vector<int> >featureLocationsForStage;
    std::vector<std::vector<float> >featureErrorsForStage;
    cv::Mat gpk;
    cv::Mat gnk;
    int imageHeight;
    int imageWidth;
    int bitsPerFeature;
    int featureRange;
    int featureAmount;
    int numPositive,numNegative;
    int numStageClassifiers;
    
    
}
-(void)buildAverageFace:(NSString *)folderPath;
-(void)buildTrainingSet:(NSString *)folderPath;
-(void)buildTables;
-(void)trainStage:(int)stage;
-(void)saveTablesToFolder:(NSString *)folderPath;
-(void)loadTablesFromFolder:(NSString *)folderPath;
-(std::vector<cv::Rect>)slidingWindowDetection:(cv::Mat)img vals:(std::vector<float> *)vals;
-(void)createNegativeTrainingImagesFromScene:(NSString *)imagePath ofSize:(NSSize) s intervalSize:(int)interval;
@end
