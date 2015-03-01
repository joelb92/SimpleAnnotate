//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GL2DGeometryDrawer.h"

@implementation GL2DGeometryDrawer
@synthesize pointColors;
@synthesize points;

@synthesize segColors;
@synthesize lineSegments;

@synthesize ammsColors;

- (id)init
{
	self = [super init];
	if(self)
	{
		minZ=0;
		maxZ=0;
		previousColor = Color();
		
		pointColors = [[colorArr alloc] init];
		points = Vector2Arr();

		segColors = [[colorArr alloc] init];
		lineSegments = LineSegment2Arr();
		
		ammsColors = [[colorArr alloc] init];
	}
	return self;
}
- (id)initWithCapacity:(int)capacity
{
	self = [super init];
	if(self)
	{
		minZ=0;
		maxZ=0;
		previousColor = Color();
		
		pointColors = [[colorArr alloc] initWithCapacity:capacity];
		points = Vector2Arr(capacity);
		
		segColors = [[colorArr alloc] initWithCapacity:capacity];
		lineSegments = LineSegment2Arr(capacity);
		
		ammsColors = [[colorArr alloc] initWithCapacity:capacity];
	}
	return self;
}

- (void)AddPoint:(Vector2)point WithColor:(Color)col
{
	[lock lockForWriting];
	points.AddItemToEnd(point);
	[pointColors addElement:col];
	[lock unlock];
}
- (void)AddPoints:(Vector2Arr)ps WithColor:(Color)col
{
	[lock lockForWriting];
	points.AddItemsToEnd(ps);
	for(int i=0; i<ps.Length; i++)
	{
		[pointColors addElement:col];
	}
	[lock unlock];
}
- (void)AddLineSegment:(LineSegment2)seg WithColor:(Color)col
{
	[lock lockForWriting];
	lineSegments.AddItemToEnd(seg);
	[segColors addElement:col];
	[lock unlock];
}

- (void)ReplaceObjectsAndColorsWithThoseFromGeometryDrawer:(GL2DGeometryDrawer*)drawer
{
	[lock lockForWriting];
	minZ=0;
	maxZ=0;
	previousColor = Color();
	
	[pointColors Reset];
	points.Reset();
	
	[segColors Reset];
	lineSegments.Reset();
	
	[ammsColors Reset];
	
	points.AddItemsToEnd(drawer.points);
	[pointColors addElements:drawer.pointColors];
	
	lineSegments.AddItemsToEnd(drawer.lineSegments);
	[segColors addElements:drawer.segColors];
	[lock unlock];
}

- (void)Reset
{
	[lock lockForWriting];
	minZ=0;
	maxZ=0;
	previousColor = Color();
	
	[pointColors Reset];
	points.Reset();
	
	[segColors Reset];
	lineSegments.Reset();
	
	[ammsColors Reset];
	[lock unlock];
}
- (NSString*)MouseOverInfoAtScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	Vector2 imagePoint = spaceConverter.ScreenToImageVector(screenPoint);
	
	
	return nil;
}
- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	if([self BeginGraphingUsingSpaceConverter:spaceConverter])
	{
		previousColor = Color(NAN,NAN,NAN);
		[lock lock];
		glEnable(GL_POINT_SMOOTH);
		glPointSize(5);
		glBegin(GL_POINTS);
		{
			for(int i=0; i<points.Length; i++)
			{
				[self SetCurrentColor:[pointColors elementAtIndex:i]];
				Vector2 point = spaceConverter.ImageToCameraVector(points[i]);
				glVertex3f(point.x, point.y, minZ);
			}
		}
		glEnd();
		
		glLineWidth(1);
		glBegin(GL_LINES);
		{
			for(int i=0; i<lineSegments.Length; i++)
			{
				[self SetCurrentColor:[segColors elementAtIndex:i]];
				LineSegment2 seg = lineSegments[i];
				Vector2 point1 = spaceConverter.ImageToCameraVector(seg.origin);
				Vector2 point2 = spaceConverter.ImageToCameraVector(seg.termintation);
				glVertex3f(point1.x, point1.y, minZ);
				glVertex3f(point2.x, point2.y, minZ);
			}
		}
		glEnd();
		[lock unlock];
	}
	[self EndGraphing];
}

- (void)SetCurrentColor:(Color)C
{
	if(C!=previousColor)
	{
		previousColor = C;
		glColor3f(C.r/255.0, C.g/255.0, C.b/255.0);
	}
}
- (void)dealloc
{
	points.Deallocate();
	lineSegments.Deallocate();
}
@end
