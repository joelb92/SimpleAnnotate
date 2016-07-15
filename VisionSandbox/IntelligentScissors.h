//
//  IntelligentScissors.h
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 7/14/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <opencv2/opencv.hpp>
#include <iostream>
#include <fstream>
#include <queue>          // std::priority_queue
#include <vector>         // std::vector
#include <functional>     // std::greater
#include "Vector2.h"
#include "smootour.hpp"
class SpecialType
{
public:
    float num;
    int theX;
    int theY;
    
    SpecialType(float a, int x, int y )
    {
        num = a;
        theX = x;
        theY = y;
    }
    
};


class mycomparison
{
    bool reverse;
public:
    mycomparison(const bool& revparam=false)
    {reverse=revparam;}
    bool operator() (const SpecialType& lhs, const SpecialType&rhs) const
    {
        if (reverse) return (lhs.num<rhs.num);
        else return (lhs.num>rhs.num);
    }
};

@interface IntelligentScissors : NSObject
{
    cv::Mat im;
    cv::Mat outim;
    double scaleFactor; //scale factor
    
    //to hold list of all the clicks
    int currentSize;
    int maxSize;
    int * allClicksX;
    int * allClicksY;
    std::vector<cv::Point> pathPoints;
    NSString *sessionName;
    //create float Mat
    //8-Mats to store weights of 8 neighbours
    //       top is Mat[0], top-right is Mat[1]
    cv::Mat * graphWeights;
    cv::Point startPoint;
    
    
    cv::Mat isVisited;
    cv::Mat dijstrasCost;
    //cv::Mat parentX;
    //cv::Mat parentY;
    cv::Mat previous;
    int previousPointSize;
    cv::Mat path;
    cv::Mat mask;

    //Tools->Activate Scissor. Checkable button. Run the algorithms only if this is true
    bool scissorActive;
    Smootour smootour;
    //Tools->overlayPathActive. If this is true display with path if any. If false show only the original image.
    bool overlayPathActive;
}
@property (readonly) cv::Point startPoint;
@property (readwrite) cv::Mat im;
@property (readonly) std::vector<cv::Point> pathPoints;
@property (readonly) bool scissorActive;
//Computes the weights for each node. note that each pixel is considered as a node of graph.
//image is gray (1-channel).
-(void) computeGraphWeights;
-(void) doDijstrasForX:(int)clickedX andY:(int) clickedY;
-(void) backTrackFromX:(int) startX andY:(int) startY;
-(void) registerPathAtX:(int) startX andY:(int) startY;
-(void) on_actionScissor_triggered:(bool) checked;
-(bool)mouseMove:(Vector2)mouseP;
-(bool)mouseClickedAtScreenPoint:(Vector2)mouseP;
-(void) resetStateVariables;
-(NSDictionary *)getPointArray;
-(void)startScissorSessionWithName:(NSString *)name;
-(void) endScissorSession;

void overlayPath( cv::Mat a, cv::Mat path, cv::Vec3b intensity , cv::Mat out );


void mergeChannels(cv::Mat &tmp, cv::Mat &dst, float epsilon);

@end
