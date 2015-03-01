//
//  RectangleDragger.m
//  DIF Map Decoder
//
//  Created by Joel Brogan on 7/10/14.
//
//

#import "GLRectangleDragger.h"
@implementation GLRectangleDragger
@synthesize currentKey,mousedOverRectIndex;
- (id)initWithOutputView:(InfoOutputController *)inf
{
	self = [super init];
	if(self)
	{
		mousedOverLineIndex = mousedOverPointIndex = mousedOverRectIndex = -1;
		initialized = false;
		points = Vector2Arr();
		segColors = [[colorArr alloc] init];
		keys = [[NSMutableArray alloc] init];
		currentKey = @"nil";
		skippedRects = intArr();
		infoOutput = inf;
	}
	return self;
}

-(void)addRect:(NSRect)r color:(Color)c forKey:(NSString *)key
{
	Vector2 p1,p2,p3,p4;
	p1 =Vector2(r.origin.x, r.origin.y);
	p2 =Vector2(r.origin.x+r.size.width,r.origin.y);
	p3 =Vector2(r.origin.x+r.size.width,r.origin.y+r.size.height);
	p4 =Vector2(r.origin.x,r.origin.y+r.size.height);
	points.AddItemToEnd(p1);
	points.AddItemToEnd(p2);
	points.AddItemToEnd(p3);
	points.AddItemToEnd(p4);
	
	[segColors addElement:c];
	[segColors addElement:c];
	[segColors addElement:c];
	[segColors addElement:c];
	[keys addObject:key];
}

-(void)removeRectAtIndex:(int)i
{
	if (i < points.Length/4) {
		[keys removeObjectAtIndex:i];
		i*=4;
		Vector2Arr newArr = Vector2Arr();
		for (int j = 0; j < points.Length; j++)
		{
			if (!(j >= i && j <i+4))
			{
				newArr.AddItemToEnd(points[j]);
			}
		}
		points = newArr;
		mousedOverRectIndex = -1;
		mousedOverLineIndex = -1;
		skippedRects.AddItemToBegining(i);
		
	}
}

-(void)setRectKey:(NSString *)key forIndex:(int)i
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

-(NSDictionary *)getRects
{
	NSMutableDictionary *rectDict = [NSMutableDictionary dictionaryWithCapacity:points.Length/4];
	for(int i = 0; i < points.Length; i+=4)
	{
		[rectDict setObject:[NSValue valueWithRect:NSMakeRect(points[i].x, points[i].y, points[i+1].x-points[i].x, points[i+2].y-points[i].y)] forKey:[keys objectAtIndex:i/4]];
	}
	return rectDict;
}

-(void)setRects:(NSDictionary *)rects
{
	[self clearAll];
	for(int i = 0; i < rects.count; i++)
	{
		NSObject *key = [rects.allKeys objectAtIndex:i];
		NSRect r = [[rects objectForKey:key] rectValue];
		[self addRect:r color:Blue forKey:key];
	}
}

-(NSArray *)getKeys
{
	return keys;
}

-(void)clearAll
{
	mousedOverLineIndex = mousedOverPointIndex = mousedOverRectIndex = -1;
	points = Vector2Arr();
	if (segColors) {
	}
	if (keys) {
	}
	segColors = [[colorArr alloc] init];
	keys = [[NSMutableArray alloc] init];
	currentKey = @"nil";
}

- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	previousColor = Color(NAN,NAN,NAN);
	[lock lock];
	glEnable(GL_POINT_SMOOTH);
	glPointSize(15);
	glBegin(GL_POINTS);
	{
		[self SetCurrentColor:Red];
		for(int i=0; i<points.Length; i++)
		{
			Vector2 point = spaceConverter.ImageToCameraVector(points[i]-Vector2(.5,.5));
			if (i == mousedOverPointIndex)
			{
				[self SetCurrentColor:Yellow];
				glVertex3f(point.x, point.y, minZ);
				[self SetCurrentColor:Red];
			}
			else
			{
				glVertex3f(point.x, point.y, minZ);
			}
		}
		
	}
	glEnd();
	
	glLineWidth(1);
	glBegin(GL_LINES);
	{
		for(int i=0; i<points.Length; i+=4)
		{
			
			[self SetCurrentColor:[segColors elementAtIndex:i]];
			
			Vector2 pointsArr[4];
			pointsArr[0] = spaceConverter.ImageToCameraVector(points[i]-Vector2(.5,.5));
			pointsArr[1] = spaceConverter.ImageToCameraVector(points[i+1]-Vector2(.5,.5));
			pointsArr[2]= spaceConverter.ImageToCameraVector(points[i+2]-Vector2(.5,.5));
			pointsArr[3]= spaceConverter.ImageToCameraVector(points[i+3]-Vector2(.5,.5));
			for (int j = 0; j < 4; j++) {
				int jmod = (j+1)%4;
				if (mousedOverRectIndex == i/4 || (mousedOverPointIndex > 0  &&mousedOverPointIndex/4 == i/4)) {
					[self SetCurrentColor:Green];
					glVertex3f(pointsArr[j].x, pointsArr[j].y, minZ);
					glVertex3f(pointsArr[jmod].x, pointsArr[jmod].y, minZ);
				}
				if (mousedOverLineIndex == i+j) {
					glVertex3f(pointsArr[j].x, pointsArr[j].y, minZ);
					glVertex3f(pointsArr[jmod].x, pointsArr[jmod].y, minZ);
					[self SetCurrentColor:[segColors elementAtIndex:i]];
				}
				else
				{
					glVertex3f(pointsArr[j].x, pointsArr[j].y, minZ);
					glVertex3f(pointsArr[jmod].x, pointsArr[jmod].y, minZ);
				}
				
				
			}
		}
	}
	glEnd();
	
	[lock unlock];
}



-(void)InitializeWithSpaceConverter:(SpaceConverter)spaceConverter
{
	Ray3 projectionRay = spaceConverter.RayFromScreenPoint( Vector2(spaceConverter.screenSize.width/3, spaceConverter.screenSize.height/2) );
	Vector3 projectedPoint = projectionRay.direction*(spaceConverter.type==_3d?10:-0.1+spaceConverter.NearClip)+projectionRay.origin;
	
	projectionRay = spaceConverter.RayFromScreenPoint( Vector2(spaceConverter.screenSize.width*2/3, spaceConverter.screenSize.height/2) );
	projectedPoint = projectionRay.direction*(spaceConverter.type==_3d?10:-0.1+spaceConverter.NearClip)+projectionRay.origin;
	
	initialized = true;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverToolValueChanged" object:nil];
}
- (void)SetMousePosition:(Vector2)mouseP UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	[super SetMousePosition:mouseP UsingSpaceConverter:spaceConverter];
	
	if(!initialized) [self InitializeWithSpaceConverter:spaceConverter];
	
	Ray3 ray = spaceConverter.RayFromScreenPoint(mousePos);
	Vector2 imagePoint = ray.origin.AsVector2();
	//Find closest point to mouse
	float pointDist = FLT_MAX;
	for (int i = 0; i < points.Length; i++)
	{
		float newDist = points[i].SqDistanceTo(imagePoint);
		if (newDist < pointDist) {
			pointDist = newDist;
			mousedOverPointIndex = i;
		}
	}
	if (pointDist > 3*3) {
		mousedOverPointIndex = -1;
	}
	//Find closest line to point
	float distance = FLT_MAX;
	Vector2 projectedPoint;
	for (int i = 0; i < points.Length; i+=4) {
		for (int j = 0; j < 4; j++)
		{
			int jmod = (j+1)%4;
			LineSegment2 seg(points[i+j],points[i+jmod]);
			Vector2 proj = seg.ProjectionOfPoint(imagePoint);
			float dist =(imagePoint-proj).SqMagnitude();
			if (dist < distance && seg.ContainsProjectionOfPoint(imagePoint))
			{
				mousedOverLineIndex = i+j;
				distance = dist;
				if (seg.termintation.x == seg.origin.x) {
					isVertical = true;
				}
				else isVertical = false;
			}
		}
	}
	bool inCont = false;
	for(int i = 0; i < points.Length; i+=4)
	{
		std::vector<cv::Point>cont;
		for (int j = 0; j < 4; j++)
		{
			cont.push_back(points[i+j].AsCvPoint());
		}
		double contourDistance = cv::pointPolygonTest(cont, imagePoint.AsCvPoint(), true);
		
		if (contourDistance > 0) {
			mousedOverRectIndex	= i/4;
			float rectWidth = (points[mousedOverRectIndex*4+1].x-points[mousedOverRectIndex*4].x);
			float rectHeight = (points[mousedOverRectIndex*4+2].y-points[mousedOverRectIndex*4+1].y);
			[infoOutput.xCoordRectLabel setStringValue:[NSString stringWithFormat:@"%i",(int)points[mousedOverRectIndex*4].x]];
			[infoOutput.yCoordRectLabel setStringValue:[NSString stringWithFormat:@"%i",(int)points[mousedOverRectIndex*4].y]];
			[infoOutput.widthLabel setStringValue:[NSString stringWithFormat:@"%i",(int)rectWidth]];
			[infoOutput.heightLabel	setStringValue:[NSString stringWithFormat:@"%i",(int)rectHeight]];
			[infoOutput.trackNumberLabel setStringValue:[keys objectAtIndex:mousedOverRectIndex]];
			currentKey = [keys objectAtIndex:mousedOverRectIndex];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverToolValueChanged" object:nil];
			inCont = true;
			continue;
		}
		
	}
	if (!inCont) {
		currentKey = @"nil";
		mousedOverRectIndex = -1;
		[infoOutput.xCoordRectLabel setStringValue:@"NA"];
		[infoOutput.yCoordRectLabel setStringValue:@"NA"];
		[infoOutput.widthLabel setStringValue:@"NA"];
		[infoOutput.heightLabel	setStringValue:@"NA"];
		

		[[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverToolValueChanged" object:nil];
	}
	if(distance>25) //If further than 5 screen pixels from the closest point:
	{
		mousedOverLineIndex = -1;
	}
	
	
	
}
- (void)DragTo:(Vector3)point Event:(NSEvent *)event
{
	if(!point.isNull() && mousedOverPointIndex>=0)
	{
		int rectIndex = mousedOverPointIndex%4;
		points[mousedOverPointIndex].x = point.x;
		points[mousedOverPointIndex].y = point.y;
		if(rectIndex == 0) //top left corner
		{
			points[mousedOverPointIndex+1].y = point.y;
			points[mousedOverPointIndex+3].x = point.x;
		}
		if (rectIndex == 1)
		{
			points[mousedOverPointIndex-1].y = point.y;
			points[mousedOverPointIndex+1].x = point.x;
		}
		if (rectIndex == 2)
		{
			points[mousedOverPointIndex-1].x = point.x;
			points[mousedOverPointIndex+1].y = point.y;
		}
		if (rectIndex == 3)
		{
			points[mousedOverPointIndex-1].y = point.y;
			points[mousedOverPointIndex-3].x = point.x;
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverToolValueChanged" object:nil];
	}
	else if(mousedOverRectIndex >= 0)
	{
		if (!dragRectBegin)//We are just beginning the rect drag, store initial mouse position
		{
			dragRectBegin = true;
			Vector2 p1 = points[mousedOverRectIndex*4];
			Vector2 p2 = points[mousedOverRectIndex*4+1];
			Vector2 p3 = points[mousedOverRectIndex*4+2];
			Vector2 p4 = points[mousedOverRectIndex*4+3];
			initialDragDistances[0] = (point-p1);
			initialDragDistances[1] = (point-p2);
			initialDragDistances[2] = (point-p3);
			initialDragDistances[3] = (point-p4);
		}
		else
		{
			points[mousedOverRectIndex*4]   = point-initialDragDistances[0];
			points[mousedOverRectIndex*4+1] = point-initialDragDistances[1];
			points[mousedOverRectIndex*4+2] = point-initialDragDistances[2];
			points[mousedOverRectIndex*4+3] = point-initialDragDistances[3];
		}
			}
	else if(!point.isNull() && draggedIndex < 0 && [event modifierFlags] & NSCommandKeyMask)
	{
		if (!madeNewRect) {
			[self addRect:NSMakeRect(point.x, point.y, 1, 1) color:Blue forKey:[NSString stringWithFormat:@"%i",points.Length/4]];
			mousedOverPointIndex = points.Length-4;
			madeNewRect = true;
			[self DragTo:point Event:event];
		}
		
	}
}

- (void)ResetHandles
{
	initialized = false;
}

- (void)mouseClickedAtPoint:(Vector2)p withEvent:(NSEvent *)event
{
	if ([event modifierFlags] & NSCommandKeyMask) {
		[self addRect:NSMakeRect(p.x, p.y, 20, 20) color:Blue forKey:[NSString stringWithFormat:@"%i",points.Length/4]];
	}
	if ([event modifierFlags] & NSShiftKeyMask) {
		if (mousedOverRectIndex >= 0) {
			[self removeRectAtIndex:mousedOverRectIndex];
		}
	}
}
- (bool)StartDragging:(NSUInteger)withKeys
{
	if (mousedOverRectIndex >=0) {
		draggedIndex = mousedOverRectIndex;
		return [super StartDragging:withKeys];
	}
	
	else
	{
		if(mousedOverRectIndex<0)
		{
			return [super StartDragging:withKeys];
		}
	}
	return false;
}
- (void)reOrderPointArray
{
	for(int i = 0; i < points.Length; i+=4)
	{
		[self reOrderRectangle:i/4];
	}
}
- (void)reOrderRectangle:(int)rectangleIndex
{
	std::vector<cv::Point> ps(4);
	ps[0] = points[rectangleIndex*4].AsCvPoint();
	ps[1] = points[rectangleIndex*4+1].AsCvPoint();
	ps[2] = points[rectangleIndex*4+2].AsCvPoint();
	ps[3] = points[rectangleIndex*4+3].AsCvPoint();
	cv::Rect r = cv::boundingRect(ps);
	points[rectangleIndex*4] = cv::Point(r.x,r.y);
	points[rectangleIndex*4+1] = cv::Point(r.x+r.width-1,r.y);
	points[rectangleIndex*4+2] = cv::Point(r.x+r.width-1,r.y+r.height-1);
	points[rectangleIndex*4+3] = cv::Point(r.x,r.y+r.height-1);
//	Vector2 reorderedP[4];
//	float greatestX = 0;
//	float greatestY = 0;
//	for (int i = 0; i < 4; i++) {
//		Vector2 p =points[rectangleIndex*4+i];
//		if(p.x >= greatestX)
//		{
//			greatestX = p.x;
//		}
//		if(p.y >= greatestY)
//		{
//			greatestY = p.y;
//		}
//	}
//	for (int i = 4; i < 4; i++) {
//		Vector2 p =points[rectangleIndex*4+i];
//		bool bigX = false;
//		bool bigY = false;
//		if(p.x >= greatestX)
//		{
//			bigX = true;
//		}
//		if(p.y >= greatestY)
//		{
//			bigY = true;
//		}
//		if (bigX && bigY) { //bottom Right corner
//			reorderedP[2] = p;
//		}
//		if (bigX && !bigY) { //top Right corner
//			reorderedP[1] = p;
//		}
//		if (!bigX && bigY) { //bottom Left corner
//			reorderedP[3] = p;
//		}
//		if (!bigX && !bigY) { //top Left corner
//			reorderedP[0] = p;
//		}
//	}
//	for (int i = 0; i < 4; i++) {
//		points[rectangleIndex*4+i] = reorderedP[i];
//	}
}

- (void)StopDragging
{
	[self reOrderPointArray];
	dragRectBegin = false;
	[super StopDragging];
	mousedOverLineIndex = -1;
	draggedIndex = -1;
	madeNewRect = false;
}

@end
