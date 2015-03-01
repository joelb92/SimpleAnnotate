//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GL3DGeometryDrawer.h"

@implementation GL3DGeometryDrawer
- (id)init
{
	self = [super init];
	if(self)
	{
		minZ=0;
		maxZ=0;
		previousColor = Color();
		
		pointColors = [[colorArr alloc] init];
		points = Vector3Arr();
		
		rayColors = [[colorArr alloc] init];
		rays = [[Ray3Arr alloc] init];
		
		segColors = [[colorArr alloc] init];
		segs = LineSegment3Arr();
		
		planeColors = [[colorArr alloc] init];
		planes = [[PlaneArr alloc] init];
		
		sphereColors = [[colorArr alloc] init];
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
		points = Vector3Arr(capacity);
		
		rayColors = [[colorArr alloc] initWithCapacity:capacity];
		rays = [[Ray3Arr alloc] initWithCapacity:capacity];
		
		segColors = [[colorArr alloc] initWithCapacity:capacity];
		segs = LineSegment3Arr(capacity);
		
		planeColors = [[colorArr alloc] initWithCapacity:capacity];
		planes = [[PlaneArr alloc] initWithCapacity:capacity];
	}
	return self;
}

- (void)AddPoint:(Vector3)point WithColor:(Color)col
{
	[lock lockForWriting];
	points.AddItemToEnd(point);
	[pointColors addElement:col];
	[lock unlock];
}
- (void)AddPoints:(Vector3Arr)ps WithColor:(Color)col
{
	points.AddItemsToEnd(ps);
	for(int i=0; i<ps.Length; i++)
	{
		[pointColors addElement:col];
	}
}
- (void)AddRay:(Ray3)ray WithColor:(Color)col
{
	[lock lockForWriting];
	[rays addElement:ray];
	[rayColors addElement:col];
	[lock unlock];
}
- (void)AddLineSegment:(LineSegment3)seg WithColor:(Color)col
{
	[lock lockForWriting];
	segs.AddItemToEnd(seg);
	[segColors addElement:col];
	[lock unlock];
}
- (void)AddPlane:(Plane)plane WithColor:(Color)col
{
	[lock lockForWriting];
	[planes addElement:plane];
	[planeColors addElement:col];
	[lock unlock];
}

- (NSString*)MouseOverInfoAtScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	[lock lock];
	Ray3 ray = spaceConverter.RayFromScreenPoint(screenPoint);
	[self SetCurrentColor:Color(255,255,255)];
	glPointSize(15);
	Vector3Arr hits = Vector3Arr();
	Vector3Arr pointHits = points.RaycastPointsForPointsWithRadiusRay(5,ray);
	Vector3Arr segHits = segs.RaycastSegsForSegsEndingWithinRadiusOfRay(5,ray);
//	Vector3Arr planeHits = points.RaycastPointsForPointsWithRadiusRay(5,ray);
	hits.AddItemsToEnd(pointHits);
	hits.AddItemsToEnd(segHits);
//	hits.AddItemsToEnd(planeHits);
	
	glBegin(GL_POINTS);
	{
		for(int i=0; i<hits.Length; i++)
		{
			Vector3 hit = hits[i];
			glVertex3f(hit.x, hit.y, hit.z);
		}
	}
	glEnd();
	hits.Deallocate();
	[lock unlock];
	
	pointHits.Deallocate();
	segHits.Deallocate();
//	planeHits.Deallocate();
	
	return nil;
}

- (Vector3)MouseOverPointForScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	[lock lock];
	Ray3 ray = spaceConverter.RayFromScreenPoint(screenPoint);
	Vector3Arr hits = Vector3Arr();
	
	Vector3Arr pointHits = points.RaycastPointsForPointsWithRadiusRay(5, ray);
	hits.AddItemToEnd(pointHits.ClosestPointToRay(ray));
	pointHits.Deallocate();
	
	Vector3Arr rayHits = [rays RaycastRaysForRayEndsWithRadius:5 Ray:ray];
	hits.AddItemToEnd(rayHits.ClosestPointToRay(ray));
	rayHits.Deallocate();
	
	Vector3Arr segHits = segs.RaycastSegsForSegsEndingWithinRadiusOfRay(5, ray);
	hits.AddItemToEnd(segHits.ClosestPointToRay(ray));
	segHits.Deallocate();
	
	Vector3Arr planeHits = [planes RaycastPlanesForPlanePointsWithRadius:5 Ray:ray];
	hits.AddItemToEnd(planeHits.ClosestPointToRay(ray));
	planeHits.Deallocate();
	[lock unlock];
	
	Vector3 closest = hits.ClosestPointToRay(ray);
	hits.Deallocate();
	return closest;
}

- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	previousColor = Color(NAN,NAN,NAN);
	if([self BeginGraphingUsingSpaceConverter:spaceConverter])
	{
		[lock lock];
		glEnable(GL_POINT_SMOOTH);
		glPointSize(7);
		glBegin(GL_POINTS);
		{
			for(int i=0; i<points.Length; i++)
			{
				[self SetCurrentColor:[pointColors elementAtIndex:i]];
				Vector3 point = points[i];
				glVertex3f(point.x, point.y, point.z);
			}
		}
		glEnd();
		
		glLineWidth(1);
		glBegin(GL_LINES);
		{
			for(int i=0; i<rays.Length; i++)
			{
				[self SetCurrentColor:[rayColors elementAtIndex:i]];
				Ray3 ray = [rays elementAtIndex:i];
				
				glVertex3f(ray.origin.x, ray.origin.y, ray.origin.z);
				glVertex3f(ray.origin.x+ray.direction.x*10.0, ray.origin.y+ray.direction.y*10.0, ray.origin.z+ray.direction.z*10.0);
			}
			
			for(int i=0; i<segs.Length; i++)
			{
				[self SetCurrentColor:[segColors elementAtIndex:i]];
				LineSegment3 seg = segs[i];
				
				glVertex3f(seg.origin.x, seg.origin.y, seg.origin.z);
				glVertex3f(seg.termintation.x, seg.termintation.y, seg.termintation.z);
			}
			
			for(int i=0; i<planes.Length; i++)
			{
				[self SetCurrentColor:[planeColors elementAtIndex:i]/2];
				Plane plane = [planes elementAtIndex:i];
				
				glVertex3f(plane.position.x, plane.position.y, plane.position.z);
				glVertex3f(plane.normal.x+plane.position.x, plane.normal.y+plane.position.y, plane.normal.z+plane.position.z);
				
				if(plane.xTangent!=Vector3())
				{
					glVertex3f(plane.position.x, plane.position.y, plane.position.z);
					glVertex3f(plane.xTangent.x*5+plane.position.x, plane.xTangent.y*5+plane.position.y, plane.xTangent.z*5+plane.position.z);
					
					glVertex3f(plane.position.x, plane.position.y, plane.position.z);
					glVertex3f(plane.yTangent.x*5+plane.position.x, plane.yTangent.y*5+plane.position.y, plane.yTangent.z*5+plane.position.z);
				}
			}
		}
		glEnd();
		
		glBegin(GL_QUADS);
		{
			float planeSize = 1;
			for(int i=0; i<planes.Length; i++)
			{
				[self SetCurrentColor:[planeColors elementAtIndex:i]];
				Plane plane = [planes elementAtIndex:i];
				
				Vector3 planeXDirection = Vector3(0,1,0).Cross(plane.normal);
				Vector3 planeYDirection = Vector3(1,0,0).Cross(plane.normal);
				Vector3 planeLL = (-planeXDirection + -planeYDirection)*planeSize;
				Vector3 planeUL = (-planeXDirection + planeYDirection)*planeSize;
				Vector3 planeUR = (planeXDirection + planeYDirection)*planeSize;
				Vector3 planeLR = (planeXDirection + -planeYDirection)*planeSize;
				glVertex3f(plane.position.x+planeLL.x, plane.position.y+planeLL.y, plane.position.z+planeLL.z);
				glVertex3f(plane.position.x+planeUL.x, plane.position.y+planeUL.y, plane.position.z+planeUL.z);
				glVertex3f(plane.position.x+planeUR.x, plane.position.y+planeUR.y, plane.position.z+planeUR.z);
				glVertex3f(plane.position.x+planeLR.x, plane.position.y+planeLR.y, plane.position.z+planeLR.z);
			}
		}
		glEnd();
		
		GLfloat colorArr[] = {1,1,1,1};
		glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, colorArr);
		
		glEnable(GL_LIGHTING);
		glEnable(GL_LIGHT0);
		glEnable(GL_COLOR_MATERIAL);
		glDisable(GL_LIGHTING);
		glDisable(GL_LIGHT0);
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
	[pointColors release];
	points.Deallocate();
	
	[rayColors release];
	[rays release];
	
	[segColors release];
	segs.Deallocate();
	
	[planeColors release];
	[planes release];
	
	[sphereColors release];
	[super dealloc];
}
@end
