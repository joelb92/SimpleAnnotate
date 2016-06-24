//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLViewTool.h"

@implementation GLViewTool
@synthesize dragging,infoOutput,linkedDims,defaultWidth,defaultHeight,currentKey,mousedOverElementIndex,elementMenus,testmenu,superView;

- (id)init
{
	self = [super init];
	if(self)
	{
		mousePos = Vector2(NAN,NAN);
		startMousePos = Vector2(NAN,NAN);
        elementMenus = [[NSMutableArray alloc] init];
		dragging = false;
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

-(void)tableHoverRect:(NSNotification *)notification
{
    id obj = notification.object;
    mousedOverElementIndex = [(NSNumber *)obj intValue];
}

- (bool)StartDragging:(NSUInteger)withKeys
{
	dragging = true;
	startMousePos = mousePos;
	shiftHeld = withKeys & NSShiftKeyMask;
	return true;
}
- (void)StopDragging
{
	dragging = false;
	stopMousePos = mousePos;
}

- (NSMutableArray *)getKeys
{
    return nil;
}

- (NSString *) stringForKey:(NSObject *)key;
{
    return nil;
}

-(NSString *)stringForIndex:(int)i
{
    return nil;
}

-(NSUInteger)count{
    return 0;
}
@end
