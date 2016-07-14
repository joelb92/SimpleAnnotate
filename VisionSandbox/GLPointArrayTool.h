//
//  GLPointArrayTool.h
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 6/20/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLViewTool.h"
#import "GL2DGeometryDrawer.h"
#include <dlib/image_processing.h>
#include "opencv2/opencv.hpp"
#import "IntelligentScissors.h"

@interface GLPointArrayTool : GLViewTool
{
bool initialized;
int draggedIndex;
int mousedOverPointIndex;
int mousedOverLineIndex;
int mousedOverEllipseIndex;
bool isVertical;
    NSString *currentAdditionKey;
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
    bool isMagnetic;
    IntelligentScissors *scissorTool;
NSMutableDictionary *rectPositionsForKeys;
    NSMutableArray *isMagneticArray;
    std::vector<Vector2Arr> pointSets;
    Vector2Arr allPoints;
    NSMutableArray *pointStructureMap;
    NSMutableArray *pointStructureIndexMap;
}
@property NSString *currentKey;
@property int mousedOverRectIndex;
@property IntelligentScissors *scissorTool;
- (id)initWithOutputView:(InfoOutputController *)infoOutput;
-(NSMutableArray *)getKeys;
-(void)clearAll;
@end
