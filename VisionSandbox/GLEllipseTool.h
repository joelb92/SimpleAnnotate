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
@interface GLEllipseTool : GLViewTool
{
    bool initialized;
    int draggedIndex;
    int mousedOverPointIndex;
    int mousedOverLineIndex;
    int mousedOverRectIndex;
    bool isVertical;
    colorArr*segColors;
    Vector2Arr points;
    std::vector<float>angles;
    Vector2Arr majorMinorAxis;
    Color previousColor;
    NSMutableArray *keys;
    NSString *currentKey;
    intArr skippedRects;
    bool madeNewRect;
    bool dragRectBegin;
    Vector2 initialDragDistances[4];
    Vector2 dragStartPoint;
    bool dragStarted;
    int rectWidth;
    int rectHeight;
    bool linkedDims;
    int xDifference;
    int yDifference;
    bool draggingDiffIsSet;
    NSMutableDictionary *rectPositionsForKeys;
    NSMutableArray *usedRectangleNumberKeys;
    NSMutableArray *camShiftTrackers;
    NSMutableArray *rectTrackingForRectsWithKeys;
}
@property NSString *currentKey;
@property int mousedOverRectIndex;
@property NSMutableArray *camShiftTrackers;
@property int rectWidth;
@property int rectHeight;
@property bool linkedDims;
@property NSMutableDictionary *rectPositionsForKeys;
@property NSMutableArray *rectTrackingForRectsWithKeys;
- (id)initWithOutputView:(InfoOutputController *)infoOutput;
-(void)addRect:(NSRect)r color:(Color)c forKey:(NSString *)key;
-(void)removeRectAtIndex:(int)i;
-(void)setRectKey:(NSString *)key forIndex:(int)i;
-(NSDictionary *)getRects;
-(void)setRects:(NSDictionary *)rects;
-(NSMutableArray *)getKeys;
-(void)clearAll;
@end

