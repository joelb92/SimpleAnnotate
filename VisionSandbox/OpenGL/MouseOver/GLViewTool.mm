//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLViewTool.h"

@implementation GLViewTool
@synthesize dragging,infoOutput,linkedDims,defaultWidth,defaultHeight,currentKey;

- (id)init
{
	self = [super init];
	if(self)
	{
		mousePos = Vector2(NAN,NAN);
		startMousePos = Vector2(NAN,NAN);
		dragging = false;
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
