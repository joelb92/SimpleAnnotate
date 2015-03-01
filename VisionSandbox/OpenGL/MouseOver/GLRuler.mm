//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLRuler.h"

@implementation GLRuler

- (id)init
{
	self = [super init];
	if(self)
	{
		mousedOverIndex = -1;
		points = Vector3Arr(2,Vector3(NAN,NAN,NAN));
		initialized = false;
	}
	return self;
}

- (float)Distance
{
	return (points[1]-points[0]).Magnitude();
}

- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	glEnable(GL_POINT_SMOOTH);
	{
		Vector3 point1 = points[0];
		Vector3 point2 = points[1];
		if(spaceConverter.type==_2d)
		{
			point1 = Vector3( spaceConverter.ImageToCameraVector(point1.AsVector2()), point2.z);
			point2 = Vector3( spaceConverter.ImageToCameraVector(point2.AsVector2()), point2.z);
		}
		
		glPointSize(15);
		glBegin(GL_POINTS);
		{
			if(mousedOverIndex==0) glColor3f(1.0, 1.0, 0.0); else glColor3f(0.1, 1.0, 0.2);
			glVertex3f(point1.x, point1.y, point1.z);
			
			if(mousedOverIndex==1) glColor3f(1.0, 1.0, 0.0); else glColor3f(1.0, 0.1, 0.2);
			glVertex3f(point2.x, point2.y, point2.z);
		}
		glEnd();
		
		glLineWidth(3);
		glBegin(GL_LINES);
		{
			glColor3f(0.1, 1.0, 0.2);
			glVertex3f(point1.x, point1.y, point1.z);
			
			glColor3f(1.0, 0.1, 0.2);
			glVertex3f(point2.x, point2.y, point2.z);
		}
		glEnd();
	}
}
- (void)InitializeWithSpaceConverter:(SpaceConverter)spaceConverter
{
	Ray3 projectionRay = spaceConverter.RayFromScreenPoint( Vector2(spaceConverter.screenSize.width/3, spaceConverter.screenSize.height/2) );
	Vector3 projectedPoint = projectionRay.direction*(spaceConverter.type==_3d?10:-0.1+spaceConverter.NearClip)+projectionRay.origin;
	points[0] = projectedPoint;
	
	projectionRay = spaceConverter.RayFromScreenPoint( Vector2(spaceConverter.screenSize.width*2/3, spaceConverter.screenSize.height/2) );
	projectedPoint = projectionRay.direction*(spaceConverter.type==_3d?10:-0.1+spaceConverter.NearClip)+projectionRay.origin;
	points[1] = projectedPoint;
	
	initialized = true;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverToolValueChanged" object:nil];
}
- (void)SetMousePosition:(Vector2)mouseP UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	[super SetMousePosition:mouseP UsingSpaceConverter:spaceConverter];
	
	if(!initialized) [self InitializeWithSpaceConverter:spaceConverter];
	
	Ray3 ray = spaceConverter.RayFromScreenPoint(mousePos);
	
	switch(spaceConverter.type)
	{
		case _2d:
		{
			Vector2Arr pointsNeglectingZ = Vector2Arr(points);
			mousedOverIndex = pointsNeglectingZ.ClosestIndexToPoint(ray.origin.AsVector2());
			Vector2 closest = spaceConverter.ImageToScreenVector(pointsNeglectingZ[mousedOverIndex]);
			if(closest.SqDistanceTo(mouseP)>56.25) //If further than 7.5 screen pixels from the closest point:
			{
				mousedOverIndex = -1;
			}
		} break;
			
		case _3d:
		{
			intArr hitPoints = points.RaycastPointsForIndexesWithRadiusRay(0.2,ray);
			mousedOverIndex = points.ClosestIndexToPointOfIndexes(ray.origin, hitPoints);
			hitPoints.Deallocate();
		} break;
	}
}
- (void)DragTo:(Vector3)point
{
	if(!point.isNull() && draggedIndex>=0)
	{
		points[draggedIndex] = point;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverToolValueChanged" object:nil];
	}
}
- (void)ResetHandles
{
	initialized = false;
}

- (bool)StartDragging:(NSUInteger)withKeys
{
	if(mousedOverIndex>=0)
	{
		draggedIndex = mousedOverIndex;
		return [super StartDragging:withKeys];
	}
	return false;
}
- (void)StopDragging
{
	[super StopDragging];
	mousedOverIndex = -1;
	draggedIndex = -1;
}

- (void)dealloc
{
	points.Deallocate();
	[super dealloc];
}
@end
