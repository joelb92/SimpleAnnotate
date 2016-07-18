//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLObject.h"
#import "InfoOutputController.h"
#import "Tooltip.h"
#import "colorArr.h"
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
    int draggedIndex;
	InfoOutputController *infoOutput;
    bool linkedDims;
    NSString *currentKey;
    NSMutableArray *elementTypes;
    NSMutableArray *keys;
    NSMutableArray *usedRectangleNumberKeys;
    colorArr*segColors;
    Color previousColor;
    NSView *superView;
    Tooltip *tooltip;
    NSString *currentAnnotationType;
    int currentAnnotationTypeIndex;
    bool comboBoxIsOpen;
    BOOL wasHiddenBeforeDrag;
    float screenPixelLength;
    cv::Mat currentImage;
    NSUInteger modifierFlags;
}
@property (readwrite) int mousedOverElementIndex;
@property (readonly) bool dragging;
@property (readonly) bool shiftHeld;
@property (readwrite) bool linkedDims;
@property (readwrite) int defaultWidth;
@property (readwrite) int defaultHeight;
@property (retain) NSTextField *testmenu;
@property (readwrite) NSString *currentKey;
@property (assign) NSMutableArray *elementMenus;
@property (retain) NSView *superView;
@property (assign) Tooltip *tooltip;
@property (readwrite) NSString *currentAnnotationType;
@property InfoOutputController *infoOutput;
@property (readwrite) bool comboBoxIsOpen;
@property (readwrite) int currentAnnotationTypeIndex;
@property (readwrite) NSUInteger modifierFlags;
- (void)DragTo:(Vector3)point Event:(NSEvent *)event;
- (void)SetMousePosition:(Vector2)mouseP UsingSpaceConverter:(SpaceConverter)spaceConverter;
- (bool)StartDragging:(NSUInteger)withKeys;
- (void)StopDragging;
- (void)mouseClickedAtPoint:(Vector2)p superPoint:(Vector2)SP withEvent:(NSEvent *)event;
- (NSMutableArray *)getKeys;
- (NSString *) stringForKey:(NSObject *)key;
- (NSString *)stringForIndex:(int)i;
- (NSUInteger)count;
- (void)tableHoverRect:(NSNotification *)notification;
- (void)clearAll;
- (void)addElement:(NSRect)r color:(Color)c forKey:(NSString *)key;
- (void)addElement:(NSRect)r color:(Color)c forKey:(NSString *)key andType:(NSString *)etype;
- (void)removeElementAtIndex:(int)i;
- (void)setElementKey:(NSString *)key forIndex:(int)i;
- (void)setCurrentElementKey:(NSString *) key;
- (void)setCurrentElementType:(NSString *) type;
- (NSDictionary *)getElements;
- (void)setElements:(NSDictionary *)rects;
- (void)setElementKey:(NSString *)key forIndex:(int)i;
- (void)SetCurrentColor:(Color)C;
- (void)setCurrentElementKey:(NSString *)key;
- (void)setCurrentElementType:(NSString *) type;
- (bool)StartDragging:(NSUInteger)withKeys;
- (void)setKey:(NSString *)key atIndexed:(int)index;
- (void) drawToolTipAtPosition:(Vector2) position Corner:(int)corner;
- (bool) checkToolTipMouseOverForMousePoint:(Vector2)mouseP;
- (void)keyDownHappened:(NSNotification *)notification;

@end
