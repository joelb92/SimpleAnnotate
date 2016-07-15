//
//  smootour.hpp
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 7/15/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#ifndef smootour_hpp
#define smootour_hpp

#include <stdio.h>
#include <vector>
#include <opencv2/opencv.hpp>

#define SMOO_FADE_RATE 0.8

class Smootour {
protected:
    float fade_rate;
    
    cv::Mat implicit_image;
    //from which we get the implicit surface
    int image_count;
    
public:
    void init(int rows, int cols, float _fade_rate);
    
    Smootour(int rows, int cols, float _fade_rate);
    Smootour(int rows, int cols);
    Smootour();
    void update(cv::Mat thresholded_image);
    
    std::vector<std::vector<cv::Point> > get_contours();
    
    cv::Mat get_implicit_image();
};

#endif /* smootour_hpp */
