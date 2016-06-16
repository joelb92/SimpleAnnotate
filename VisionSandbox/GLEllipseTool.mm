//
//  GLEllipseTool.m
//  SimpleAnnotate
//
//  Created by Joel Brogan on 6/15/16.
//  Copyright (c) 2016 University of Notre Dame. All rights reserved.
//

#import "GLEllipseTool.h"
#define DEG2RAD 3.14159/180.0
@implementation GLEllipseTool
@synthesize currentKey,mousedOverRectIndex,rectWidth,rectHeight,rectPositionsForKeys,camShiftTrackers,rectTrackingForRectsWithKeys;
@synthesize linkedDims;
- (id)initWithOutputView:(InfoOutputController *)inf
{
    self = [super init];
    if(self)
    {
        a=0;
        mousedOverLineIndex = mousedOverPointIndex = mousedOverRectIndex = -1;
        camShiftTrackers = [[NSMutableArray alloc] init];
        initialized = false;
        points = Vector2Arr();
        majorMinorAxis = Vector2Arr();
        segColors = [[colorArr alloc] init];
        keys = [[NSMutableArray alloc] init];
        currentKey = @"nil";
        skippedRects = intArr();
        infoOutput = inf;
        rectPositionsForKeys = [[NSMutableDictionary alloc] init];
        rectTrackingForRectsWithKeys = [[NSMutableArray alloc] init];
        usedRectangleNumberKeys = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableHoverRect:) name:@"TableViewHoverChanged" object:nil];
    }
    return self;
}

-(void)addEllipse:(NSRect)er color:(Color)c forKey:(NSString *)key
{
    //Calculate ellipse angle transform
    float angle = 0;
    float t0,t1,t2,t3;
    Vector2 point(er.origin.x,er.origin.y);
    Vector2 axis(er.size.width,er.size.height);
    t0 = cos(angle);
    t1 = -sin(angle);
    t2 = -t1;
    t3 = t0;
    EllipseVis e;
    e.imagePoints = std::vector<cv::Point>(360/6);
    
    //Draw the ellipse
    for(int j=0; j<360; j+=6)
    {
        float rad = j*DEG2RAD;
        Vector2 v = Vector2(cos(rad)*axis.x,sin(rad)*axis.y);
        v = Vector2(v.x*t0+v.y*t2+point.x,v.x*t1+v.y*t3+point.y);
        e.imagePoints[j/6] = v.AsCvPoint();
    }
    
    //Draw ellipse drag handles if within the correct area
        e.topAnchor= Vector2(sin(angle)*axis.y,cos(angle)*axis.y);
        e.bottomAnchor = -e.topAnchor;
        e.leftAnchor = Vector2(cos(-angle)*axis.x,sin(-angle)*axis.x);
        e.rightAnchor = -e.leftAnchor;
        e.rotationAnchor = Vector2(cos(-angle)*(axis.x+15),sin(-angle)*(axis.x+15));
    
}

-(void)addRect:(NSRect)r color:(Color)c forKey:(NSString *)key
{
    Vector2 p1,p2,p3,p4;
    p1 =Vector2(r.origin.x, r.origin.y);
    p2 = Vector2(r.size.width,r.size.height);
    points.AddItemToEnd(p1);
    majorMinorAxis.AddItemToEnd(p2);
    angles.push_back(a*DEG2RAD);
    a+=10;
    [segColors addElement:c];

    [keys addObject:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@(mousedOverRectIndex)];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

-(NSMutableArray *)getKeys
{
    return keys;
}

-(void)clearAll
{
    mousedOverLineIndex = mousedOverPointIndex = mousedOverRectIndex = -1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@(mousedOverRectIndex)];
    points = Vector2Arr();
    if (segColors) {
    }
    if (keys) {
    }
    segColors = [[colorArr alloc] init];
    keys = [[NSMutableArray alloc] init];
    currentKey = @"nil";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
    Vector2 mousePoint = spaceConverter.ScreenToImageVector(mousePos);
    previousColor = Color(NAN,NAN,NAN);
    [lock lock];
    glEnable(GL_POINT_SMOOTH);
    glLineWidth(3);
    glPointSize(15);

    {
        for(int i=0; i<points.Length; i++)
        {
            
            [self SetCurrentColor:[segColors elementAtIndex:i]];
            
            Vector2 point = points[i];
            Vector2 cameraPoint = spaceConverter.ImageToCameraVector(point);
            Vector2 axis = majorMinorAxis[i];
            axis.y = 40;
            Vector2Arr circlePoints = Vector2Arr();
            //Calculate ellipse angle transform
            float angle = angles[i];
            float t0,t1,t2,t3;
            t0 = cos(angle);
            t1 = -sin(angle);
            t2 = -t1;
            t3 = t0;
            glLineWidth(2);
            glBegin(GL_LINE_LOOP);
            [self SetCurrentColor:Yellow];
            std::vector<cv::Point> elPoints(360/6);
            //Draw the ellipse
            for(int j=0; j<360; j+=6)
            {
                float rad = j*DEG2RAD;
                Vector2 v = Vector2(cos(rad)*axis.x,sin(rad)*axis.y);
                v = Vector2(v.x*t0+v.y*t2+point.x,v.x*t1+v.y*t3+point.y);
                elPoints[j/6] = v.AsCvPoint();
                v = spaceConverter.ImageToCameraVector(v);
                glVertex3d(v.x, v.y, minZ);
            }
            [self SetCurrentColor:[segColors elementAtIndex:i]];
            glEnd();
            
            //Draw ellipse drag handles if within the correct area
            if (cv::pointPolygonTest(elPoints, mousePoint.AsCvPoint(), true) > -30) {
                mousedOverEllipseIndex = i;
                Vector2 topAnchor= Vector2(sin(angle)*axis.y,cos(angle)*axis.y);
                Vector2 bottomAnchor = -topAnchor;
                Vector2 leftAnchor = Vector2(cos(-angle)*axis.x,sin(-angle)*axis.x);
                Vector2 rightAnchor = -leftAnchor;
                Vector2 rotateAnchor = Vector2(cos(-angle)*(axis.x+15),sin(-angle)*(axis.x+15));
                topAnchor = spaceConverter.ImageToCameraVector(topAnchor+point);
                bottomAnchor = spaceConverter.ImageToCameraVector(bottomAnchor+point);
                leftAnchor = spaceConverter.ImageToCameraVector(leftAnchor+point);
                rightAnchor= spaceConverter.ImageToCameraVector(rightAnchor+point);
                rotateAnchor = spaceConverter.ImageToCameraVector(rotateAnchor+point);
                glPointSize(10);
                glBegin(GL_POINTS);
                //draw anchor points
                glVertex3d(topAnchor.x, topAnchor.y, minZ);
                glVertex3d(bottomAnchor.x, bottomAnchor.y, minZ);
                glVertex3d(leftAnchor.x, leftAnchor.y, minZ);
                glVertex3d(rightAnchor.x, rightAnchor.y, minZ);
                
                
                //draw rotation anchor
                glVertex3d(rotateAnchor.x, rotateAnchor.y, minZ);
                glEnd();
                glLineWidth(3);
                glBegin(GL_LINES);
                glVertex3d(leftAnchor.x, leftAnchor.y, minZ);
                glVertex3d(rotateAnchor.x, rotateAnchor.y, minZ);
                glEnd();
                
                
            }
            


        }
    }

    
    [lock unlock];
}

-(void)tableHoverRect:(NSNotification *)notification
{
    id obj = notification.object;
    mousedOverRectIndex = [(NSNumber *)obj intValue];
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
     
}
- (void)DragTo:(Vector3)point Event:(NSEvent *)event
{
    point.x = floor(point.x);
    point.y = floor(point.y);
    float ratio = 1;
    if (rectHeight != 0) {
        ratio = (rectWidth+0.0)/(rectHeight+0.0);
    }
    if(!point.isNull() && mousedOverPointIndex>=0)
    {
        
        int rectIndex = mousedOverPointIndex%4;
        if(!draggingDiffIsSet){
            xDifference = points[mousedOverPointIndex].x-point.x;
            yDifference = points[mousedOverPointIndex].y-point.y;
            draggingDiffIsSet = true;
        }
        if (rectIndex == 1 || rectIndex == 3) {
            ratio = -ratio;
        }
        float newYPoint = point.y+yDifference;
        float newXPoint = point.x+xDifference;
        if (!dragStarted) {
            dragStartPoint = Vector2(newXPoint,newYPoint);
            dragStarted = true;
        }
        if (linkedDims) {
            Vector2 changeVect = Vector2(newXPoint,newYPoint)-dragStartPoint;
            if (abs(changeVect.x) > abs(changeVect.y)) {
                newYPoint = changeVect.x/ratio+dragStartPoint.y;
            }
            else
            {
                newXPoint = changeVect.y*ratio+dragStartPoint.x;
            }
        }
        points[mousedOverPointIndex].x = newXPoint;
        points[mousedOverPointIndex].y = newYPoint;
        if(rectIndex == 0) //top left corner
        {
            points[mousedOverPointIndex+1].y = newYPoint;
            points[mousedOverPointIndex+3].x = newXPoint;
        }
        if (rectIndex == 1)
        {
            points[mousedOverPointIndex-1].y = newYPoint;
            points[mousedOverPointIndex+1].x = newXPoint;
        }
        if (rectIndex == 2)
        {
            points[mousedOverPointIndex-1].x = newXPoint;
            points[mousedOverPointIndex+1].y = newYPoint;
        }
        if (rectIndex == 3)
        {
            points[mousedOverPointIndex-1].y = newYPoint;
            points[mousedOverPointIndex-3].x = newXPoint;
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
            int currentKeyNum =points.Length/4;
            while ([usedRectangleNumberKeys containsObject:@(currentKeyNum)]) {
                currentKeyNum++;
            }
            [usedRectangleNumberKeys addObject:@(currentKeyNum)];
            NSString *newRectKey =[NSString stringWithFormat:@"Rectangle %i",currentKeyNum];
            NSRect r = NSMakeRect(point.x, point.y, 1, 1);
            [self addRect:r color:Blue forKey:newRectKey];
            //            [keys addObject:newRectKey];
            mousedOverPointIndex = points.Length-4;
            madeNewRect = true;
            [self DragTo:point Event:event];
        }
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
    
}



- (void)ResetHandles
{
    initialized = false;
}

- (void)mouseClickedAtPoint:(Vector2)p withEvent:(NSEvent *)event
{
    if ([event modifierFlags] & NSCommandKeyMask) {
        if (!madeNewRect) {
            int currentKeyNum =int(ellipses.size());
            while ([usedRectangleNumberKeys containsObject:@(currentKeyNum)]) {
                currentKeyNum++;
            }
            [usedRectangleNumberKeys addObject:@(currentKeyNum)];
            NSString *newRectKey =[NSString stringWithFormat:@"Ellipse %i",currentKeyNum];
            [self addRect:NSMakeRect(p.x, p.y, rectWidth, rectHeight) color:Blue forKey:newRectKey];
        }
        
    }
    
    if ([event modifierFlags] & NSShiftKeyMask) {
        if (mousedOverRectIndex >= 0) {
            [self removeRectAtIndex:mousedOverRectIndex];
        }
    }
    if ([event modifierFlags] & NSFunctionKeyMask) {
        if (mousedOverRectIndex >= 0) {
            if (![rectTrackingForRectsWithKeys containsObject:[keys objectAtIndex:mousedOverRectIndex]]) {
                [rectTrackingForRectsWithKeys addObject:[keys objectAtIndex:mousedOverRectIndex]];
            }
            else
            {
                [rectTrackingForRectsWithKeys removeObject:[keys objectAtIndex:mousedOverRectIndex]];
            }
        }
    }
    //    NSLog([event characters]);
    //    if ([[[event characters] componentsSeparatedByString:@""] containsObject:@"t"]) {
    //
    //    }
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


- (void)StopDragging
{
    dragStarted = false;
    draggingDiffIsSet = false;
    dragRectBegin = false;
    [super StopDragging];
    mousedOverLineIndex = -1;
    draggedIndex = -1;
    madeNewRect = false;
}

@end

