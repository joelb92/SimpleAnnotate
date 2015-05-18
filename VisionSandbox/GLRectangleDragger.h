//
//  RectangleDragger.h
//  DIF Map Decoder
//
//  Created by Joel Brogan on 7/10/14.
//
//

#import "GLViewTool.h"
#import "GL2DGeometryDrawer.h"
@interface GLRectangleDragger : GLViewTool
{
	bool initialized;
	int draggedIndex;
	int mousedOverPointIndex;
	int mousedOverLineIndex;
	int mousedOverRectIndex;
	bool isVertical;
	colorArr*segColors;
	Vector2Arr points;
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
}
@property NSString *currentKey;
@property int mousedOverRectIndex;
@property int rectWidth;
@property int rectHeight;
@property bool linkedDims;
@property NSMutableDictionary *rectPositionsForKeys;
- (id)initWithOutputView:(InfoOutputController *)infoOutput;
-(void)addRect:(NSRect)r color:(Color)c forKey:(NSString *)key;
-(void)removeRectAtIndex:(int)i;
-(void)setRectKey:(NSString *)key forIndex:(int)i;
-(NSDictionary *)getRects;
-(void)setRects:(NSDictionary *)rects;
-(NSMutableArray *)getKeys;
-(void)clearAll;
@end
