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
	NSMutableArray *emptyKeys;
}
@property NSString *currentKey;
@property int mousedOverRectIndex;
- (id)initWithOutputView:(InfoOutputController *)infoOutput;
-(void)addRect:(NSRect)r color:(Color)c forKey:(NSString *)key;
-(void)removeRectAtIndex:(int)i;
-(void)setRectKey:(NSString *)key forIndex:(int)i;
-(NSDictionary *)getRects;
-(void)setRects:(NSDictionary *)rects;
-(NSArray *)getKeys;
-(void)clearAll;
@end
