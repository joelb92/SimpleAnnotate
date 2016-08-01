//
//  Landmarker.cpp
//  Frontalizer
//
//  Created by Joel Brogan on 2/21/16.
//  Copyright (c) 2016 Joel Brogan. All rights reserved.
//

#include "Landmarker.h"

Landmarker::Landmarker (){
    numLandmarks = 68;
    name = "None";
}

std::vector<cv::Point> Landmarker::findLandmarks(cv::Mat img) {
	std::cout << "You called an empty landmarker..." << std::endl;
    return std::vector<cv::Point> ();
}
