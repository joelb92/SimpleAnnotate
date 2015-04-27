//
//  ZhengFaceDetection.m
//  EBOLO
//
//  Created by Joel Brogan on 3/13/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "ZhengFaceDetection.h"

@implementation ZhengFaceDetection

-(id)init
{
    self = [super init];
    if (self) {
        imageWidth = 10;
        imageHeight = 10;
        bitsPerFeature = 12;
        int stages = 3;
        featureAmountsForStage = std::vector<int> (stages);
        AforStage = std::vector<std::vector<float> > (stages);
        ASumForStage = std::vector<float> (stages);
        featureErrorsForStage = std::vector<std::vector<float> > (stages);
        featureAmountsForStage[0] = 15;
        featureAmountsForStage[1] = 45;
        featureAmountsForStage[2] = 90;
        featureLocationsForStage = std::vector<std::vector<int> >(stages);
    }
    return self;
}

-(int)classify:(cv::Mat)img
{
    if (img.cols == imageWidth && img.rows == imageHeight) {
        for(int i = 0; i < featureAmountsForStage.size(); i++)
        {
            float result = [self ClassifyImage:img ForStage:i];
            if (result <= 0) {
                return 0;
            }
        }
        return 1;
    }
    else NSLog(@"BAD SIZE");
    return false;
}
-(float)classifyandRate:(cv::Mat)img
{
    if (img.cols == imageWidth && img.rows == imageHeight) {
        float sum = 0;
        for(int i = 0; i < featureAmountsForStage.size(); i++)
        {
            float result = [self ClassifyImage:img ForStage:i];
            if (result <= 0) {
                return 0;
            }
            sum+=result;
        }
        return sum;
    }
    else NSLog(@"BAD SIZE");
    return false;
}

-(float)ClassifyImage:(cv::Mat)img ForStage:(int)stage
{
    float sumWeakClassifiers = 0;
    
    for (int k = 0; k < featureAmountsForStage[stage]; k++) {
        int featurePosition = featureLocationsForStage[stage][k];
        int featureVal = img.at<unsigned short>(featurePosition);
        int classifierResult = gpk.at<float>(featurePosition,featureVal) > gnk.at<float>(featurePosition,featureVal);
        if (classifierResult == 1) sumWeakClassifiers+=AforStage[stage][k];
    }
    //    if (finalVal > 0) NSLog(@"%f",finalVal);
    return sumWeakClassifiers-.5*ASumForStage[stage];
    //    return sumWeakClassifiers > .8*ASumForStage[stage];
}

-(void)trainStage:(int)stage
{
    //initialize weights
    weights.clear();
    std::vector<float> currentWeights(trainingSet.size());
    for (int i = 0; i < trainingSet.size(); i++) {
        if (trainingSetTruth[i] == 0) currentWeights[i] = 1.0/(2*numNegative);
        else currentWeights[i] = 1.0/(2*numPositive);
    }
    weights.push_back(currentWeights);
    [self buildTables];
    //main boosting loop
    std::vector<float> A(featureAmountsForStage[stage]);
    std::vector<int> featureLocations;
    std::vector<float> featureErrors;
    featureLocationsForStage[stage] = featureLocations;
    float Asum = 0;
    NSLog(@"Begin Training Loop for %i features...",featureAmountsForStage[stage]);
    for (int k = 0; k < featureAmountsForStage[stage]; k++) {
        std::cout << ".";
        //Generate a weak classifer with lowest error
        float bestError = FLT_MAX;
        float bestFeatureIndex = -1;
        for (int loop = 0; loop < imageWidth*imageHeight; loop++) { //loop to determine feature location with lowest error
            bool badIndex = false;
            for(int i = 0; i < featureLocations.size(); i++)
            {
                if (loop == featureLocations[i])
                {
                    badIndex = true;
                    break;
                }
            }
            if (!badIndex) {
                float error = 0;
                for (int i = 0; i < trainingSet.size(); i++) {
                    cv::Mat img = trainingSet[i];
                    int featureVal = img.at<unsigned short>(loop);
                    int classifierResult = gpk.at<float>(loop,featureVal) > gnk.at<float>(loop,featureVal);
                    if(classifierResult != trainingSetTruth[i]) error+=currentWeights[i];
                }
                if (error < bestError) {
                    bestError = error;
                    bestFeatureIndex = loop;
                }
                
            }
        }
        if (bestFeatureIndex >= 0) {
            
            featureLocations.push_back(bestFeatureIndex);
            featureErrors.push_back(bestError);
            //Create a value (weight for final classifier, as error gets smaller, a gets larger, giving more weight to classifiers with lower error)
            float a = 89; //This is the maximum value a could approach via FLT_MAX (if besterror == 0)
            if (a > 0) a = .5*log((1-bestError)/bestError);
            A[k] = a;
            Asum += a;
            //update weights for next iteration.  The weights of images that are correctly classified are lowered, to make incorrectly classified images more important to the boosting algorithm
            std::vector<float> newWeights(trainingSet.size());
            float zP = 0;
            float zN = 0;
            for(int i = 0; i < trainingSet.size(); i++)
            {
                float newVal = currentWeights[i];
                cv::Mat img = trainingSet[i];
                int featureVal = img.at<unsigned short>(bestFeatureIndex);
                int classifierResult = gpk.at<float>(bestFeatureIndex,featureVal) > gnk.at<float>(bestFeatureIndex,featureVal);
                if (classifierResult == trainingSetTruth[i]) newVal*=expf(-a);
                else newVal*=expf(a);
                if (trainingSetTruth[i] == 1) zP += newVal;
                else zN += newVal;
                newWeights[i] = newVal;
            }
            //re-normalize weights
            for (int i = 0; i < trainingSet.size(); i++)
            {
                
                if(trainingSetTruth[i] == 1)newWeights[i] = newWeights[i]/zP;
                else newWeights[i] = newWeights[i]/zN;
            }
            weights.push_back(newWeights);
            currentWeights = newWeights;
            [self updateTables];
        }
        else{
            NSLog(@"YOU HAD NO GOOD FEATURES! THIS IS BAD!");
        }
    }
    std::cout << std::endl;
    ASumForStage[stage] = Asum;
    AforStage[stage] = A;
    featureLocationsForStage[stage] = featureLocations;
    featureErrorsForStage[stage] = featureErrors;
    int error = 0;
    for (int i = 0; i < trainingSet.size(); i++) {
        cv::Mat img = trainingSet[i];
        int result = [self ClassifyImage:img ForStage:0];
        if (result != trainingSetTruth[i]) error++;
    }
    NSLog(@"final stage error is: %i",error);
    cv::Mat img = cv::Mat::zeros(imageHeight, imageWidth, CV_8UC1);
    for (int i = 0; i < featureLocations.size(); i++) {
        img.at<uchar>(featureLocations[i]) = 255;
    }
    IplImage *imgI = new IplImage(img);
    IplImage *newImgI = new IplImage(cv::Mat(100,100,CV_8UC1));
    cvResize(imgI, newImgI,CV_INTER_NN);
    img = cv::Mat(newImgI);
    cv::imwrite([NSString stringWithFormat:@"/Users/joel/Documents/TrainingFaces/10x10/MediumSet/Stage%i_locations.jpg",stage].UTF8String, img);
}

-(std::vector<cv::Rect>)slidingWindowDetection:(cv::Mat)img vals:(std::vector<float> *)vals
{
    
    std::vector<cv::Rect> rects;
    MCT *mct = [[MCT alloc] init];
    cv::Mat mctImg = [mct ModifiedColorCensusTransform:img];
    int windowWidth = 10;
    int windowHeight = 10;
    for (int x = 0; x < mctImg.cols-windowWidth; x++) {
        for (int y = 0; y < mctImg.rows-windowHeight; y++)
        {
            cv::Rect r(x,y,windowWidth,windowHeight);
            cv::Mat window = mctImg(r);
            float result = [self classifyandRate:window];
            if (result > 0) {
                rects.push_back(r);
                vals->push_back(result);
            }
        }
    }
    return rects;
}
-(void)createNegativeTrainingImagesFromScene:(NSString *)imagePath ofSize:(NSSize) s intervalSize:(int)interval
{
    
    cv::Mat mctImg = cv::imread(imagePath.UTF8String);
    int windowWidth = s.width;
    int windowHeight = s.height;
    int i = 0;
    for (int x = 0; x < mctImg.cols-windowWidth-interval; x = x+1+interval ) {
        for (int y = 0; y < mctImg.rows-windowHeight; y=y+1+interval)
        {
            cv::Rect r(x,y,windowWidth,windowHeight);
            cv::Mat window = mctImg(r);
            NSString *newPath = [[imagePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%i",imagePath.stringByDeletingPathExtension.lastPathComponent,i]] stringByAppendingPathExtension:imagePath.pathExtension];
            cv::imwrite(newPath.UTF8String, window);
            i++;
        }
    }
    NSLog(@"Done builing negative images");
}


-(void)loadTablesFromFolder:(NSString *)folderPath
{
    NSString *gpkString =[NSString stringWithContentsOfFile:[[folderPath stringByAppendingPathComponent:@"PositiveTable"] stringByAppendingPathExtension:@"csv"] encoding:NSUTF8StringEncoding error:nil];
    NSString *gnkString =[NSString stringWithContentsOfFile:[[folderPath stringByAppendingPathComponent:@"PositiveTable"] stringByAppendingPathExtension:@"csv"] encoding:NSUTF8StringEncoding error:nil];
    //build gpk table
    
    NSArray *rows = [gpkString componentsSeparatedByString:@"\n"];
    bool initialized=false;
    for (int i = 0; i < rows.count; i++) {
        NSArray *cols = [[rows objectAtIndex:i] componentsSeparatedByString:@","];
        if(!initialized)
        {
            gpk = cv::Mat::zeros((int)rows.count,(int) cols.count, CV_32FC1);
            gnk = cv::Mat::zeros((int)rows.count, (int)cols.count, CV_32FC1);
            initialized = true;
        }
        for (int j = 0; j < cols.count; j++) {
            NSString *s = [cols objectAtIndex:j];
            if ( s.length > 0) {
                float num = s.floatValue;
                gpk.at<float>(i,j) = num;
            }
        }
    }
    rows = [gnkString componentsSeparatedByString:@"\n"];
    for (int i = 0; i < rows.count; i++) {
        NSArray *cols = [[rows objectAtIndex:i] componentsSeparatedByString:@","];
        for (int j = 0; j < cols.count; j++) {
            NSString *s = [cols objectAtIndex:j];
            if ( s.length > 0) {
                float num = s.floatValue;
                gnk.at<float>(i,j) = num;
            }
        }
    }
}

-(void)saveTablesToFolder:(NSString *)folderPath
{
    NSMutableString *gpkString = [[NSMutableString alloc] init];
    NSMutableString *gnkString = [[NSMutableString alloc] init];
    for (int i = 0; i < featureAmount; i++) {
        NSMutableString *s1 = [[NSMutableString alloc] init];
        for (int j = 0; j < featureRange; j++) {
            if (j != featureRange-1) {
                [s1 appendFormat:@"%f,",gpk.at<float>(i,j)];
            }
            else [s1 appendFormat:@"%f\n",gpk.at<float>(i,j)];
        }
        NSMutableString *s2 = [[NSMutableString alloc] init];
        for (int j = 0; j < featureRange; j++) {
            if (j != featureRange-1) {
                [s2 appendFormat:@"%f,",gnk.at<float>(i,j)];
            }
            else [s2 appendFormat:@"%f\n",gnk.at<float>(i,j)];
        }
        [gpkString appendString:s1];
        [gnkString appendString:s2];
    }
    [gpkString writeToFile:[[folderPath stringByAppendingPathComponent:@"PositiveTable"] stringByAppendingPathExtension:@"csv" ] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [gnkString writeToFile:[[folderPath stringByAppendingPathComponent:@"NegativeTable"] stringByAppendingPathExtension:@"csv" ] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void)buildTables
{
    featureRange = pow(2, bitsPerFeature);
    featureAmount = imageWidth*imageHeight;
    gpk = cv::Mat::zeros(featureAmount, featureRange, CV_32FC1);
    gnk = cv::Mat::zeros(featureAmount, featureRange, CV_32FC1);
    NSLog(@"building tables");
    for(int i = 0; i < trainingSet.size(); i++)
    {
        float newWeight = weights[weights.size()-1][i];
        std::cout << ".";
        cv::Mat img = trainingSet[i];
        if (img.cols != 10) {
            NSLog(@"");
        }
        for (int k = 0; k <featureAmount; k++) {
            unsigned int val = img.at<unsigned short>(k);
            if (trainingSetTruth[i] == 1) gpk.at<float>(k,val) += 1*newWeight;
            else gnk.at<float>(k,val) += 1;
        }
    }
    std::cout << std::endl;
    NSLog(@"done!");
}

-(void)updateTables
{
    featureRange = pow(2, bitsPerFeature);
    featureAmount = imageWidth*imageHeight;
    for(int i = 0; i < trainingSet.size(); i++)
    {
        float prevWeight = weights[weights.size()-2][i];
        float newWeight = weights[weights.size()-1][i];
        
        cv::Mat img = trainingSet[i];
        if (img.cols != 10) {
            NSLog(@"");
        }
        for (int k = 0; k <featureAmount; k++) {
            unsigned int val = img.at<unsigned short>(k);
            if (trainingSetTruth[i] == 1) gpk.at<float>(k,val) *= newWeight/prevWeight;
            else gnk.at<float>(k,val) *= newWeight/prevWeight;
        }
    }
}

-(void)buildTrainingSet:(NSString *)folderPath
{
    MCT *mct = [[MCT alloc]  init];
    
    NSString *faceFolderPath = [folderPath stringByAppendingPathComponent:@"Faces"];
    NSString *nonFaceFolderPath = [folderPath stringByAppendingPathComponent:@"NonFaces"];
    numPositive = numNegative = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:faceFolderPath error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"];
    NSArray *onlyppms = [dirContents filteredArrayUsingPredicate:fltr];
    NSLog(@"Loading face set");
    int i = 0;
    for(NSString *fileName in onlyppms)
    {
        NSString *fullPath = [faceFolderPath stringByAppendingPathComponent:fileName];
        std::cout << ".";
        
        cv::Mat img = cv::imread(fullPath.UTF8String);
        img = [mct ModifiedColorCensusTransform:img];
        
        trainingSet.push_back(img.clone());
        trainingSetTruth.push_back(1);
        numPositive++;
        i++;
    }
    std::cout << std::endl;
    NSLog(@"loading non-face set");
    dirContents = [fm contentsOfDirectoryAtPath:nonFaceFolderPath error:nil];
    fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"];
    NSArray *onlyjpgs = [dirContents filteredArrayUsingPredicate:fltr];
    for(NSString *fileName in onlyjpgs)
    {
        NSString *fullPath = [nonFaceFolderPath stringByAppendingPathComponent:fileName];
        std::cout << ".";
        cv::Mat img = cv::imread(fullPath.UTF8String);
        
        img = [mct ModifiedColorCensusTransform:img];
        trainingSet.push_back(img);
        trainingSetTruth.push_back(0);
        numNegative++;
        i++;
    }
    std::cout << std::endl;
}

-(void)buildAverageFace:(NSString *)folderPath
{
    MCT *mct = [[MCT alloc]  init];
    
    NSString *faceFolderPath = [folderPath stringByAppendingPathComponent:@"Faces"];
    NSString *nonFaceFolderPath = [folderPath stringByAppendingPathComponent:@"NonFaces"];
    numPositive = numNegative = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:faceFolderPath error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"];
    NSArray *onlyppms = [dirContents filteredArrayUsingPredicate:fltr];
    NSLog(@"Loading face set");
    int i = 0;
    cv::Mat avg = cv::Mat::zeros(imageHeight, imageWidth, CV_32FC1);
    
    for(NSString *fileName in onlyppms)
    {
        NSString *fullPath = [faceFolderPath stringByAppendingPathComponent:fileName];
        std::cout << ".";
        
        cv::Mat img = cv::imread(fullPath.UTF8String,0);
        img.convertTo(img, CV_32FC1);
        avg += img;
        trainingSet.push_back(img.clone());
        trainingSetTruth.push_back(1);
        numPositive++;
        i++;
    }
    avg /= onlyppms.count;
    avg.convertTo(avg, CV_8UC1);
    cv::imwrite([folderPath stringByAppendingPathComponent:@"averageFace.png"].UTF8String, avg);
    cv::imshow("average", avg);
    cv::waitKey();
    std::cout << std::endl;
}
@end
