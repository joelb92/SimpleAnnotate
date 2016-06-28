//
//  RectangleDragger.h
//  DIF Map Decoder
//
//  Created by Joel Brogan on 7/10/14.
//
//

#import "GLViewTool.h"
#import "GL2DGeometryDrawer.h"
#include <dlib/image_processing.h>
#include "opencv2/opencv.hpp"
#include <dlib/gui_widgets.h>
#include <dlib/image_io.h>
#include <dlib/dir_nav.h>
#include <dlib/opencv/cv_image.h>
@interface GLRectangleDragger : GLViewTool
{
	bool initialized;
	int draggedIndex;
	int mousedOverPointIndex;
	int mousedOverLineIndex;
	bool isVertical;
	Vector2Arr points;
	intArr skippedRects;
	bool madeNewRect;
	bool dragRectBegin;
	Vector2 initialDragDistances[4];
    Vector2 dragStartPoint;
    bool dragStarted;
    int rectWidth;
    int rectHeight;
    int xDifference;
    int yDifference;
    bool draggingDiffIsSet;
    NSMutableDictionary *rectPositionsForKeys;
    NSMutableArray *usedRectangleNumberKeys;
    NSMutableArray *camShiftTrackers;
    NSMutableArray *rectTrackingForRectsWithKeys;
}
@property NSString *currentKey;
@property NSMutableArray *camShiftTrackers;
@property int rectWidth;
@property int rectHeight;
@property bool linkedDims;
@property NSMutableDictionary *rectPositionsForKeys;
@property NSMutableArray *rectTrackingForRectsWithKeys;
- (id)initWithOutputView:(InfoOutputController *)infoOutput;
-(NSMutableArray *)getKeys;
-(void)clearAll;
@end
