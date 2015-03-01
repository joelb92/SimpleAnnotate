//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLObject.h"
#import "colorArr.h"
#import "floatArr.h"
#import "Vector2Arr.h"
#import "Ray3Arr.h"
#import "LineSegment2Arr.h"

@interface GL2DGeometryDrawer : GLObject
{
	Color previousColor;
	
	colorArr*pointColors;
	Vector2Arr points;
	
	colorArr*segColors;
	LineSegment2Arr lineSegments;
	
	colorArr*ammsColors;
}
@property (readonly) colorArr*pointColors;
@property (readonly) Vector2Arr points;

@property (readonly) colorArr*segColors;
@property (readonly) LineSegment2Arr lineSegments;

@property (readonly) colorArr*ammsColors;

- (id)initWithCapacity:(int)capacity;

- (void)AddPoint:(Vector2)point WithColor:(Color)col;
- (void)AddPoints:(Vector2Arr)ps WithColor:(Color)col;

- (void)AddLineSegment:(LineSegment2)seg WithColor:(Color)col;

- (void)ReplaceObjectsAndColorsWithThoseFromGeometryDrawer:(GL2DGeometryDrawer*)drawer;

- (void)Reset;
@end
