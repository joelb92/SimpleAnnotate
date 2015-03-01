//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLProtractor.h"

@implementation GLProtractor

- (id)init
{
	self = [super init];
	if(self)
	{
		mousedOverIndex = -1;
		points = Vector3Arr(4,Vector3(NAN,NAN,NAN));
		initialized = false;
	}
	return self;
}

- (float)Angle
{
	return (points[1]-points[0]).AngleToVector((points[3]-points[2]))/M_PI*180;
}

- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	glEnable(GL_POINT_SMOOTH);
	{
		Vector3 point1 = points[0];
		Vector3 point2 = points[1];
		Vector3 point3 = points[2];
		Vector3 point4 = points[3];
		
		if(spaceConverter.type==_2d)
		{
			point1 = Vector3( spaceConverter.ImageToCameraVector(point1.AsVector2()), point2.z);
			point2 = Vector3( spaceConverter.ImageToCameraVector(point2.AsVector2()), point2.z);
			point3 = Vector3( spaceConverter.ImageToCameraVector(point3.AsVector2()), point3.z);
			point4 = Vector3( spaceConverter.ImageToCameraVector(point4.AsVector2()), point4.z);
		}
		
		glPointSize(15);
		glBegin(GL_POINTS);
		{
			if(mousedOverIndex==0) glColor3f(1.0, 1.0, 0.0); else glColor3f(0.1, 1.0, 0.2);
			glVertex3f(point1.x, point1.y, point1.z);
			
			if(mousedOverIndex==1) glColor3f(1.0, 1.0, 0.0); else glColor3f(1.0, 0.1, 0.2);
			glVertex3f(point2.x, point2.y, point2.z);
			
			if(mousedOverIndex==2) glColor3f(1.0, 1.0, 0.0); else glColor3f(0.1, 1.0, 0.2);
			glVertex3f(point3.x, point3.y, point3.z);
			
			if(mousedOverIndex==3) glColor3f(1.0, 1.0, 0.0); else glColor3f(1.0, 0.1, 0.2);
			glVertex3f(point4.x, point4.y, point4.z);
		}
		glEnd();
		
		glLineWidth(3);
		glBegin(GL_LINES);
		{
			glColor3f(0.1, 1.0, 0.2);
			glVertex3f(point1.x, point1.y, point1.z);
			
			glColor3f(1.0, 0.1, 0.2);
			glVertex3f(point2.x, point2.y, point2.z);
			
			
			glColor3f(0.1, 1.0, 0.2);
			glVertex3f(point3.x, point3.y, point3.z);
			
			glColor3f(1.0, 0.1, 0.2);
			glVertex3f(point4.x, point4.y, point4.z);
			
			
			Vector3 termination = (point2-point1)/2+point3;
			glColor3f(0.1, 1.0, 0.2);
			glVertex3f(point3.x, point3.y, point3.z);
			
			glColor3f(1.0, 0.1, 0.2);
			glVertex3f(termination.x, termination.y, termination.z);
			
			
			termination = (point4-point3)/2+point1;
			glColor3f(0.1, 1.0, 0.2);
			glVertex3f(point1.x, point1.y, point1.z);
			
			glColor3f(1.0, 0.1, 0.2);
			glVertex3f(termination.x, termination.y, termination.z);
		}
		glEnd();
	}
}
- (void)InitializeWithSpaceConverter:(SpaceConverter)spaceConverter
{
	Ray3 projectionRay = spaceConverter.RayFromScreenPoint( Vector2(spaceConverter.screenSize.width/5, spaceConverter.screenSize.height/2) );
	Vector3 projectedPoint = projectionRay.direction*(spaceConverter.type==_3d?10:-0.1+spaceConverter.NearClip)+projectionRay.origin;
	points[0] = projectedPoint;
	
	projectionRay = spaceConverter.RayFromScreenPoint( Vector2(spaceConverter.screenSize.width*2/5, spaceConverter.screenSize.height/2) );
	projectedPoint = projectionRay.direction*(spaceConverter.type==_3d?10:-0.1+spaceConverter.NearClip)+projectionRay.origin;
	points[1] = projectedPoint;
	
	projectionRay = spaceConverter.RayFromScreenPoint( Vector2(spaceConverter.screenSize.width*3/5, spaceConverter.screenSize.height/2) );
	projectedPoint = projectionRay.direction*(spaceConverter.type==_3d?10:-0.1+spaceConverter.NearClip)+projectionRay.origin;
	points[2] = projectedPoint;
	
	projectionRay = spaceConverter.RayFromScreenPoint( Vector2(spaceConverter.screenSize.width*4/5, spaceConverter.screenSize.height/2) );
	projectedPoint = projectionRay.direction*(spaceConverter.type==_3d?10:-0.1+spaceConverter.NearClip)+projectionRay.origin;
	points[3] = projectedPoint;
	
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
		[super StartDragging:withKeys];
		return true;
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
