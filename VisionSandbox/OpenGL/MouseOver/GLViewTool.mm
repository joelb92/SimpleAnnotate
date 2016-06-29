//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLViewTool.h"

@implementation GLViewTool
@synthesize dragging,infoOutput,linkedDims,defaultWidth,defaultHeight,currentKey,mousedOverElementIndex,elementMenus,testmenu,superView,tooltip,currentAnnotationType,comboBoxIsOpen,currentAnnotationTypeIndex;

- (id)init
{
	self = [super init];
	if(self)
	{
        keys = [[NSMutableArray alloc] init];
        segColors = [[colorArr alloc] init];
		mousePos = Vector2(NAN,NAN);
		startMousePos = Vector2(NAN,NAN);
		dragging = false;
        elementTypes = [[NSMutableArray alloc] init];
        usedRectangleNumberKeys = [[NSMutableArray alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableHoverRect:) name:@"TableViewHoverChanged" object:nil];
	}
	return self;
}

-(void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	
}
- (void)SetMousePosition:(Vector2)mouseP UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	previousMousePos = mousePos;
	mousePos = mouseP;
}
- (void)DragTo:(Vector3)point Event:(NSEvent *)event
{
	
}

-(void)setElementKey:(NSString *)key forIndex:(int)i
{
    if (i < keys.count) {
        [keys replaceObjectAtIndex:i withObject:key];
    }
    
}

- (void)SetCurrentColor:(Color)C
{
    if(C!=previousColor)
    {
        previousColor = C;
        glColor3f(C.r/255.0, C.g/255.0, C.b/255.0);
    }
}

-(void)setCurrentElementKey:(NSString *)key
{
    [keys replaceObjectAtIndex:mousedOverElementIndex withObject:key];
}

-(void)setCurrentElementType:(NSString *) type;
{
    if(mousedOverElementIndex >= 0 && mousedOverElementIndex < elementTypes.count){
        [elementTypes replaceObjectAtIndex:mousedOverElementIndex withObject:type];
    }
}

-(void)tableHoverRect:(NSNotification *)notification
{
    id obj = notification.object;
    mousedOverElementIndex = [(NSNumber *)obj intValue];
}

- (bool)StartDragging:(NSUInteger)withKeys
{
	dragging = true;
    [tooltip setHidden:YES];
	startMousePos = mousePos;
	shiftHeld = withKeys & NSShiftKeyMask;
	return true;
}
- (void)StopDragging
{
    [tooltip setHidden:NO];
	dragging = false;
	stopMousePos = mousePos;
}

-(void)drawToolTipAtPosition:(Vector2)position Corner:(int)corner
{
    //display tooltip
        NSRect newframe  = NSMakeRect(position.x, position.y, tooltip.frame.size.width, tooltip.frame.size.height);
    if (corner == 0) {
        //anchor to bottom left
    }
    if (corner == 1){
        //anchor to bottom right
        newframe.origin.x -= newframe.size.width;
    }
    if (corner == 2) {
        //anchor to top right
        newframe.origin.x -= newframe.size.width;
        newframe.origin.y -= newframe.size.height;
    }
    if (corner == 3) {
        //anchor to top left
        newframe.origin.y -= newframe.size.height;
    }
    [tooltip.nameField setStringValue:[keys objectAtIndex:mousedOverElementIndex] ];
    int ind =(int)[tooltip.typeSelectionBox.objectValues indexOfObject:[elementTypes objectAtIndex:mousedOverElementIndex]];
    if (ind < 0 ) ind = (int)[tooltip.typeSelectionBox.objectValues indexOfObject:@"None"];
    [tooltip.typeSelectionBox selectItemAtIndex:ind];
    [tooltip setFrame:newframe];
    [superView addSubview:tooltip];
    [tooltip setHidden:NO];
}

-(bool)checkToolTipMouseOverForMousePoint:(Vector2)mouseP
{
    return false;
}

-(NSMutableArray *)getKeys
{
    return keys;
}

-(NSUInteger)count
{
    return keys.count;
}

- (NSString *) stringForKey:(NSObject *)key;
{
    return nil;
}

-(NSString *)stringForIndex:(int)i
{
    return nil;
}


@end
