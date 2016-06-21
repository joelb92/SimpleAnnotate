//
//  GLEllipseTool.h
//  SimpleAnnotate
//
//  Created by Joel Brogan on 6/15/16.
//  Copyright (c) 2016 University of Notre Dame. All rights reserved.
//

#import "GLViewTool.h"
#import "GL2DGeometryDrawer.h"
#include <dlib/image_processing.h>
#include "opencv2/opencv.hpp"
#define DEG2RAD 3.14159/180.0

struct EllipseVis
{
    std::vector<cv::Point> imagePoints;
    float angle;
    Vector2 leftAnchor,rightAnchor,topAnchor,bottomAnchor,rotationAnchor,center,axis;
    void recalc()
    {
        float a = angle;
        float t0,t1,t2,t3;
        t0 = cos(a);
        t1 = -sin(a);
        t2 = -t1;
        t3 = t0;
        //Draw the ellipse
        for(int j=0; j<360; j+=3)
        {
            float rad = j*DEG2RAD;
            Vector2 v = Vector2(cos(rad)*axis.x,sin(rad)*axis.y);
            v = Vector2(v.x*t0+v.y*t2+this->center.x,v.x*t1+v.y*t3+center.y);
            this->imagePoints[j/3] = v.AsCvPoint();
        }
        
        //Draw ellipse drag handles if within the correct area
        this->topAnchor= Vector2(sin(a)*axis.y,cos(a)*axis.y);
        this->bottomAnchor = -topAnchor;
        this->leftAnchor = Vector2(cos(-a)*axis.x,sin(-a)*axis.x);
        rightAnchor = -leftAnchor;
        this->rotationAnchor = Vector2(cos(-a)*(this->axis.x+15),sin(-a)*(this->axis.x+15))+this->center;
        this->topAnchor+= this->center;
        this->bottomAnchor+=this->center;
        this->rightAnchor+=this->center;
        this->leftAnchor+=this->center;

    }
//    Vector2 leftAnchorCamera,rightAnchorCamera,topAnchorCamera,bottomAnchorCamera;
    void setAngle(float a)
    {
        angle = a;
        recalc();
    }
    void setxaxis(float xa)
    {
        axis.x = xa;
        recalc();
    }
    void setyaxis(float ya)
    {
        axis.y = ya;
        recalc();
    }
};

@interface GLEllipseTool : GLViewTool
{
    float a;
    bool initialized;
    int draggedIndex;
    int mousedOverPointIndex;
    int mousedOverLineIndex;
    int mousedOverEllipseIndex;
    bool isVertical;
    colorArr*segColors;
    std::vector<EllipseVis> ellipses;
    Color previousColor;
    NSMutableArray *keys;
    intArr skippedRects;
    bool madeNewRect;
    bool dragRectBegin;
    Vector2 initialDragDistances[4];
    Vector2 dragStartPoint;
    float dragStartAngle;
    bool dragStarted;
    int xDifference;
    int yDifference;
    float angleDifference;
    float axisDifference;
    bool draggingDiffIsSet;
    NSMutableDictionary *rectPositionsForKeys;
    NSMutableArray *usedRectangleNumberKeys;

}
@property NSString *currentKey;
@property int mousedOverRectIndex;
- (id)initWithOutputView:(InfoOutputController *)infoOutput;
-(NSMutableArray *)getKeys;
-(void)clearAll;
@end

