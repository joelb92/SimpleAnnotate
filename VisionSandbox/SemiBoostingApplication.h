//
//  SemiBoostingApplication.h
//  EBOLO
//
//  Created by Joel Brogan on 8/5/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//
#include "math.h"
#include "string.h"
#include <time.h>
#if OS_type==2
#include <conio.h>
#include <io.h>
#endif

#include <sys/types.h>
#include <sys/stat.h>

#include "Patches.h"
#include "ImageRepresentation.h"

#include "StrongClassifierDirectSelection.h"
#include "StrongClassifierStandard.h"
#include "Detector.h"
#include "SemiBoostingTracker.h"

#include "ImageSource.h"
#include "ImageHandler.h"
#include "fstream"
#include "opencv2/opencv.hpp"
#include "opencv2/legacy/legacy.hpp"
class SemiBoostingApplication
{
public:
    void initTracker(int nBC, float overlp, float searchFctr, cv::Rect intBB,cv::Mat initialImage);
    cv::Rect RunTrackIteration(cv::Mat newImage);
    void release();
private:
    int mouse_pointX;
    int mouse_pointY;
    int mouse_value;
    bool mouse_exit;
    Rect2 trackingRect;
    bool keyboard_pressed = false;
    int counter = 0;
    bool trackerLost = false;
    ImageSource *imageSequenceSource;
    ImageHandler* imageSequence;
    unsigned char *curFrame;
    ImageRepresentation* curFrameRep;
    SemiBoostingTracker* tracker;
    float overlap, searchFactor;
    int numBaseClassifier;
    Rect2 initBB;
    Size2 trackingRectSize2;
    Rect2 wholeImage;
};
