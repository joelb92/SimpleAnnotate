//
//  GLEllipseTool.m
//  SimpleAnnotate
//
//  Created by Joel Brogan on 6/15/16.
//  Copyright (c) 2016 University of Notre Dame. All rights reserved.
//

#import "GLEllipseTool.h"
@implementation GLEllipseTool
@synthesize mousedOverRectIndex;
- (id)initWithOutputView:(InfoOutputController *)inf
{
    self = [super init];
    if(self)
    {
        mousedOverLineIndex = mousedOverPointIndex = mousedOverRectIndex = -1;
        initialized = false;
        segColors = [[colorArr alloc] init];
        keys = [[NSMutableArray alloc] init];
        currentKey = @"nil";
        skippedRects = intArr();
        infoOutput = inf;
        rectPositionsForKeys = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableHoverRect:) name:@"TableViewHoverChanged" object:nil];
    }
    return self;
}

-(void)addElement:(NSRect)er color:(Color)c forKey:(NSString *)key
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
    e.imagePoints = std::vector<cv::Point>(360/3);
    
    //Draw the ellipse
    for(int j=0; j<360; j+=3)
    {
        float rad = j*DEG2RAD;
        Vector2 v = Vector2(cos(rad)*axis.x,sin(rad)*axis.y);
        v = Vector2(v.x*t0+v.y*t2+point.x,v.x*t1+v.y*t3+point.y);
        e.imagePoints[j/3] = v.AsCvPoint();
    }
    
    //Draw ellipse drag handles if within the correct area
    e.topAnchor= Vector2(sin(angle)*axis.y,cos(angle)*axis.y);
    e.bottomAnchor = -e.topAnchor;
    e.leftAnchor = Vector2(cos(-angle)*axis.x,sin(-angle)*axis.x);
    e.rightAnchor = -e.leftAnchor;
    e.rotationAnchor = Vector2(cos(-angle)*(axis.x+15),sin(-angle)*(axis.x+15))+point;
    e.topAnchor+=point;
    e.bottomAnchor+=point;
    e.rightAnchor+=point;
    e.leftAnchor+=point;
    e.center = point;
    e.axis = axis;
    e.angle = 0;
    ellipses.push_back(e);
    [keys addObject:key];
    [segColors addElement:c];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];

}


-(void)removeElementAtIndex:(int)i
{
    if (i < ellipses.size() && i >=0) {
        [keys removeObjectAtIndex:i];
        ellipses.erase(ellipses.begin()+i);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@(mousedOverEllipseIndex)];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
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

-(NSDictionary *)getElements
{
    NSMutableDictionary *rectDict = [NSMutableDictionary dictionaryWithCapacity:ellipses.size()];
    for(int i = 0; i < ellipses.size(); i++)
    {
        EllipseVis e = ellipses[i];
        NSDictionary * d = [NSDictionary dictionaryWithObjects:@[@(e.center.x),@(e.center.y),@(e.axis.x),@(e.axis.y),@(e.angle)] forKeys:@[@"x coord",@"y coord",@"width",@"height",@"rotation"]];
        [rectDict setValue:d forKey:[keys objectAtIndex:i]];
    }
    return rectDict;
}

-(void)setElements:(NSDictionary *)rects
{
    [self clearAll];
    for(int i = 0; i < rects.count; i++)
    {
        NSObject *key = [rects.allKeys objectAtIndex:i];
        NSDictionary *d = [rects objectForKey:key];
        NSRect r = NSMakeRect([[d objectForKey:@"x coord"] floatValue], [[d objectForKey:@"y coord"] floatValue], [[d objectForKey:@"width"] floatValue], [[d objectForKey:@"height"] floatValue]);
        [self addElement:r color:Blue forKey:(NSString *)key];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

-(NSString *)stringForKey:(NSObject *)key
{
    return [self stringForIndex:(int)[keys indexOfObject:key]];
}

-(NSString *)stringForIndex:(int)i
{
    EllipseVis e = ellipses[i];
    NSString * s = [NSString stringWithFormat:@"c: %i,%i w: %i h:%i r:%f",(int)e.center.x,(int)e.center.y,(int)e.axis.x,(int)e.axis.y,e.angle];
    return s;
}

-(NSMutableArray *)getKeys
{
    return keys;
}

-(NSUInteger)count{
    return ellipses.size();
}

-(void)clearAll
{
    mousedOverLineIndex = mousedOverPointIndex = mousedOverRectIndex = mousedOverEllipseIndex = -1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@(mousedOverRectIndex)];
    if (segColors) {
    }
    if (keys) {
    }
    segColors = [[colorArr alloc] init];
    keys = [[NSMutableArray alloc] init];
    ellipses.clear();
    currentKey = @"nil";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
    bool ismousedover = false;
    previousColor = Color(NAN,NAN,NAN);
    [lock lock];
    glEnable(GL_POINT_SMOOTH);
    glLineWidth(3);
    glPointSize(15);
    
    {
        for(int i=0; i<ellipses.size(); i++)
        {
            
            [self SetCurrentColor:[segColors elementAtIndex:i]];
            EllipseVis e = ellipses[i];
            glLineWidth(2);
            glBegin(GL_LINE_LOOP);
            //Draw the ellipse
            
            for(int j=0; j<e.imagePoints.size(); j++)
            {
                Vector2 v = spaceConverter.ImageToCameraVector(e.imagePoints[j]);
                glVertex3d(v.x, v.y, minZ);
            }
            [self SetCurrentColor:Red];
            glEnd();
            
            //Draw ellipse drag handles if within the correct area
            if (i == mousedOverEllipseIndex) {
                Vector2 topAnchor= spaceConverter.ImageToCameraVector(e.topAnchor);
                Vector2 bottomAnchor= spaceConverter.ImageToCameraVector(e.bottomAnchor);
                Vector2 leftAnchor= spaceConverter.ImageToCameraVector(e.leftAnchor);
                Vector2 rightAnchor= spaceConverter.ImageToCameraVector(e.rightAnchor);
                Vector2 rotateAnchor= spaceConverter.ImageToCameraVector(e.rotationAnchor);
                ismousedover = true;
                glPointSize(10);
                glBegin(GL_POINTS);
                //draw anchor points
                glVertex3d(topAnchor.x, topAnchor.y, minZ);
                glVertex3d(bottomAnchor.x, bottomAnchor.y, minZ);
                glVertex3d(leftAnchor.x, leftAnchor.y, minZ);
                glVertex3d(rightAnchor.x, rightAnchor.y, minZ);
                if(mousedOverPointIndex == 1){
                    [self SetCurrentColor:Yellow];
                     glVertex3d(topAnchor.x, topAnchor.y, minZ);
                }
                if(mousedOverPointIndex == 2){
                    [self SetCurrentColor:Yellow];
                    glVertex3d(bottomAnchor.x, bottomAnchor.y, minZ);
                }
                if(mousedOverPointIndex == 3){
                    [self SetCurrentColor:Yellow];
                    glVertex3d(leftAnchor.x, leftAnchor.y, minZ);
                }
                if(mousedOverPointIndex == 4){
                    [self SetCurrentColor:Yellow];
                    glVertex3d(rightAnchor.x, rightAnchor.y, minZ);
                }
                [self SetCurrentColor:Red];
                //draw rotation anchor
                if(mousedOverPointIndex == 5) [self SetCurrentColor:Yellow];
                glVertex3d(rotateAnchor.x, rotateAnchor.y, minZ);
                glEnd();
                glLineWidth(3);
                glBegin(GL_LINES);
                glVertex3d(leftAnchor.x, leftAnchor.y, minZ);
                glVertex3d(rotateAnchor.x, rotateAnchor.y, minZ);
                glEnd();
                [self SetCurrentColor:[segColors elementAtIndex:i]];

                
                
            }
            
            
        }
    }
    
    
    [lock unlock];
}

-(void)tableHoverRect:(NSNotification *)notification
{
    [super tableHoverRect:notification];
    id obj = notification.object;
    mousedOverEllipseIndex = [(NSNumber *)obj intValue];
    
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
    Vector2 imagePoint = spaceConverter.ScreenToImageVector(mouseP);
    bool inCont;
    [super SetMousePosition:mouseP UsingSpaceConverter:spaceConverter];
    for(int i=0; i < ellipses.size(); i++)
    {
        
        EllipseVis e = ellipses[i];
        float distval = cv::pointPolygonTest(e.imagePoints, imagePoint.AsCvPoint(), true);
        if (distval > -30) {
            inCont = true;
            mousedOverEllipseIndex = i;
            int mindist = 5*5;
            if(e.topAnchor.SqDistanceTo(imagePoint) < mindist) mousedOverPointIndex = 1;
            else if(e.bottomAnchor.SqDistanceTo(imagePoint) < mindist) mousedOverPointIndex = 2;
            else if(e.leftAnchor.SqDistanceTo(imagePoint) < mindist) mousedOverPointIndex = 3;
            else if(e.rightAnchor.SqDistanceTo(imagePoint) < mindist) mousedOverPointIndex = 4;
            else if(e.rotationAnchor.SqDistanceTo(imagePoint) < mindist) mousedOverPointIndex = 5;
            else{
                mousedOverPointIndex = -1;
            }
            if(distval >= 0)
            {
                [infoOutput.xCoordRectLabel setStringValue:[NSString stringWithFormat:@"%i",(int)e.center.x]];
                [infoOutput.yCoordRectLabel setStringValue:[NSString stringWithFormat:@"%i",(int)e.center.y]];
                [infoOutput.widthLabel setStringValue:[NSString stringWithFormat:@"%i",(int)e.axis.x]];
                [infoOutput.heightLabel	setStringValue:[NSString stringWithFormat:@"%i",(int)e.axis.y]];
                [infoOutput.trackNumberLabel setStringValue:[keys objectAtIndex:mousedOverEllipseIndex]];
                currentKey = [keys objectAtIndex:mousedOverEllipseIndex];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverToolValueChanged" object:nil];
                
            }
            break;
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
        mousedOverEllipseIndex = -1;
        
    }
    if(!initialized) [self InitializeWithSpaceConverter:spaceConverter];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@(mousedOverEllipseIndex)];
    
}
- (void)DragTo:(Vector3)point Event:(NSEvent *)event
{
    point.x = floor(point.x);
    point.y = floor(point.y);
    
    if(!point.isNull() && mousedOverEllipseIndex>=0 && mousedOverPointIndex >= 0)
    {
        
        int elIndex = mousedOverEllipseIndex;
        EllipseVis ellipse = ellipses[mousedOverEllipseIndex];
        if (mousedOverPointIndex == 5) { //rotation!
            float currentmouseangle = atan2(point.y-ellipse.center.y, point.x-ellipse.center.x);
            //            if( currentmouseangle < 0) currentmouseangle +=M_PI*2;
            if(!draggingDiffIsSet)
            {
                angleDifference = ellipse.angle-currentmouseangle;
                draggingDiffIsSet = true;
            }
            float newAngle = -(currentmouseangle);
            if(!dragStarted)
            {
                dragStartAngle = newAngle;
                
                dragStarted = true;
            }
            ellipse.setAngle(newAngle);
            ellipses[mousedOverEllipseIndex] = ellipse;
        }
        else{
            Vector2 anc,offsetanc, oppositenac;
            float ratio = ellipse.axis.x/ellipse.axis.y;
            if (mousedOverPointIndex == 1) {
                anc = ellipse.topAnchor;
                offsetanc = ellipse.rightAnchor;
            }
            if (mousedOverPointIndex == 2) {
                anc = ellipse.bottomAnchor;
                offsetanc = ellipse.rightAnchor;
            }
            if (mousedOverPointIndex == 3) {
                anc = ellipse.leftAnchor;
                offsetanc = ellipse.topAnchor;
            }
            if (mousedOverPointIndex == 4) {
                anc = ellipse.rightAnchor;
                offsetanc = ellipse.topAnchor;
            }
            offsetanc -= ellipse.center;
            float currentmouseangle,mouseDistance;
            
            
            currentmouseangle = atan2(point.y-ellipse.center.y, point.x-ellipse.center.x)-atan2(anc.y-ellipse.center.y,anc.x-ellipse.center.x);
            if (fabs(currentmouseangle) < M_PI/10 || fabs(M_PI-currentmouseangle) < M_PI/10){
                point.x += offsetanc.x*2;
                point.y += offsetanc.y*2;
                currentmouseangle = atan2(point.y-ellipse.center.y, point.x-ellipse.center.x)-atan2(anc.y-ellipse.center.y,anc.x-ellipse.center.x);
            }
            mouseDistance = sqrt((point.AsVector2()-anc).SqMagnitude())*cos(currentmouseangle);
            if (mouseDistance <= 0) {
                mouseDistance = 1;
            }
            //                NSLog(@"New axis: %f, %f",mouseDistance, ellipse.topAnchor.y- point.AsVector2().y);
            if (!dragStarted) {
                dragStartAngle = mouseDistance;
                dragStarted = true;
            }
            if (mousedOverPointIndex == 1 || mousedOverPointIndex == 2) {
                ellipse.setyaxis(mouseDistance);
                if (linkedDims) ellipse.setxaxis(ellipse.axis.y*ratio);
            }
            if (mousedOverPointIndex == 3 || mousedOverPointIndex == 4) {
                ellipse.setxaxis(mouseDistance);
                if (linkedDims) ellipse.setyaxis(ellipse.axis.x/ratio);
            }
            ellipses[mousedOverEllipseIndex] = ellipse;
            
        }
        
    }
    else if (!point.isNull() && mousedOverEllipseIndex >= 0)
    {
        int elIndex = mousedOverEllipseIndex;
        EllipseVis ellipse = ellipses[mousedOverEllipseIndex];
        if(!dragRectBegin)
        {
            dragRectBegin = true;
            initialDragDistances[0] = (point.AsVector2()-Vector2(ellipse.center));
        }
        else
        {
            ellipse.center = point-initialDragDistances[0];
            ellipse.recalc();
            ellipses[elIndex] = ellipse;
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
            [self addElement:NSMakeRect(p.x, p.y, defaultWidth, defaultHeight) color:Blue forKey:newRectKey];
        }
        
    }
    
    if ([event modifierFlags] & NSShiftKeyMask) {
        if (mousedOverRectIndex >= 0) {
            [self removeElementAtIndex:mousedOverRectIndex];
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

