//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLObject.h"
#import "InfoOutputController.h"
@interface GLViewTool : GLObject
{
	Vector2 mousePos;
	Vector2 previousMousePos;
	Vector2 startMousePos;
	Vector2 stopMousePos;
    int mousedOverElementIndex;
    int defaultWidth;
    int defaultHeight;
	bool dragging;
	bool shiftHeld;
	InfoOutputController *infoOutput;
    bool linkedDims;
    NSString *currentKey;
}
@property (readwrite) int mousedOverElementIndex;
@property (readonly) bool dragging;
@property (readonly) bool shiftHeld;
@property (readwrite) bool linkedDims;
@property (readwrite) int defaultWidth;
@property (readwrite) int defaultHeight;
@property (readwrite) NSString *currentKey;
@property InfoOutputController *infoOutput;
- (void)DragTo:(Vector3)point Event:(NSEvent *)event;
- (void)SetMousePosition:(Vector2)mouseP UsingSpaceConverter:(SpaceConverter)spaceConverter;
- (bool)StartDragging:(NSUInteger)withKeys;
- (void)StopDragging;
- (void)mouseClickedAtPoint:(Vector2)p withEvent:(NSEvent *)event;
- (NSMutableArray *)getKeys;
- (NSString *) stringForKey:(NSObject *)key;
- (NSString *)stringForIndex:(int)i;
- (NSUInteger)count;
-(void)tableHoverRect:(NSNotification *)notification;
-(void)clearAll;

@end
