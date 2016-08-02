//
//  Landmarker.h
//  Frontalizer
//
//  Created by Joel Brogan on 2/21/16.
//  Copyright (c) 2016 Joel Brogan. All rights reserved.
//

#ifndef __Frontalizer__Landmarker__
#define __Frontalizer__Landmarker__
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <opencv2/opencv.hpp>
class Landmarker {

public:
	int numLandmarks;
	std::string name;

//    virtual std::vector<std::vector<cv::Point> > findLandmarks(cv::Mat img);
    Landmarker();

};


#endif /* defined(__Frontalizer__Landmarker__) */

