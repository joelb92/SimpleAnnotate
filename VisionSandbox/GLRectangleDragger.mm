//
//  RectangleDragger.m
//  DIF Map Decoder
//
//  Created by Joel Brogan on 7/10/14.
//
//

#import "GLRectangleDragger.h"
@implementation GLRectangleDragger
@synthesize rectPositionsForKeys,camShiftTrackers,rectTrackingForRectsWithKeys;
- (id)initWithOutputView:(InfoOutputController *)inf
{
    self = [super init];
    if(self)
    {
        mousedOverLineIndex = mousedOverPointIndex = mousedOverElementIndex = -1;
        camShiftTrackers = [[NSMutableArray alloc] init];
        initialized = false;
        points = Vector2Arr();
        segColors = [[colorArr alloc] init];
        keys = [[NSMutableArray alloc] init];
        currentKey = @"nil";
        skippedRects = intArr();
        infoOutput = inf;
        rectPositionsForKeys = [[NSMutableDictionary alloc] init];
        rectTrackingForRectsWithKeys = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableHoverRect:) name:@"TableViewHoverChanged" object:nil];
    }
    return self;
}

-(void)addElement:(NSRect)r color:(Color)c forKey:(NSString *)key
{
    [self addElement:r color:c forKey:key andType:currentAnnotationType];
}

-(void)addElement:(NSRect)r color:(Color)c forKey:(NSString *)key andType:(NSString *)type
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
    [elementTypes addObject:type];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

-(void)removeElementAtIndex:(int)i
{
    if (i < points.Length/4) {
        [keys removeObjectAtIndex:i];
        [elementTypes removeObjectAtIndex:i];
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
        mousedOverElementIndex = -1;
        mousedOverLineIndex = -1;
        skippedRects.AddItemToBegining(i);
         [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@(mousedOverElementIndex)];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}



-(NSDictionary *)getElements
{
    NSMutableDictionary *rectDict = [NSMutableDictionary dictionaryWithCapacity:points.Length/4];
    for(int i = 0; i < points.Length; i+=4)
    {
        NSRect r = NSMakeRect(points[i].x, points[i].y, points[i+1].x-points[i].x, points[i+2].y-points[i].y);
        NSDictionary *d = [NSDictionary dictionaryWithObjects:@[@(r.origin.x),@(r.origin.y),@(r.size.width),@(r.size.height),[elementTypes objectAtIndex:i/4]] forKeys:@[@"x coord",@"y coord",@"width",@"height",@"type"]];
        [rectDict setObject:d forKey:[keys objectAtIndex:i/4]];
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
        [self addElement:r color:Blue forKey:(NSString *)key andType:[d objectForKey:@"type"]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

- (NSString *) stringForKey:(NSObject *)key
{
    int i = (int)[keys indexOfObject:key];
    return [self stringForIndex:i];
}

-(NSString *)stringForIndex:(int)i
{
    i = i*4;
    NSRect r = NSMakeRect(points[i].x, points[i].y, points[i+1].x-points[i].x, points[i+2].y-points[i].y);
    NSString *s =  [NSString stringWithFormat:@"%i,%i,%i,%i",(int)r.origin.x,(int)r.origin.y,(int)r.size.width,(int)r.size.height];
    return s;
}

-(void)clearAll
{
    mousedOverLineIndex = mousedOverPointIndex = mousedOverElementIndex = -1;
     [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@(mousedOverElementIndex)];
    points = Vector2Arr();
    if (segColors) {
    }
    if (keys) {
    }
    segColors = [[colorArr alloc] init];
    keys = [[NSMutableArray alloc] init];
    currentKey = @"nil";
    [elementTypes removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
    screenPixelLength = spaceConverter.ScreenToCameraVector(Vector2(1,0)).x;
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
                if ([rectTrackingForRectsWithKeys containsObject:[keys objectAtIndex:i/4]])
                    [self SetCurrentColor:Color(255, 0, 255)];
                if (mousedOverElementIndex == i/4 || (mousedOverPointIndex > 0  &&mousedOverPointIndex/4 == i/4)) {
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

-(void)tableHoverRect:(NSNotification *)notification
{
    [super tableHoverRect:notification];
    id obj = notification.object;
    mousedOverElementIndex = [(NSNumber *)obj intValue];
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
        float newDist = spaceConverter.ImageToScreenVector(points[i]).SqDistanceTo(spaceConverter.ImageToScreenVector(imagePoint));
        if (newDist < pointDist) {
            pointDist = newDist;
            mousedOverPointIndex = i;
            
        }
    }
    if (pointDist > 20*20) {
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
        if (contourDistance >= -1) {
            mousedOverElementIndex	= i/4;
            float rectWidth = (points[mousedOverElementIndex*4+1].x-points[mousedOverElementIndex*4].x);
            float rectHeight = (points[mousedOverElementIndex*4+2].y-points[mousedOverElementIndex*4+1].y);
            [infoOutput.xCoordRectLabel setStringValue:[NSString stringWithFormat:@"%i",(int)points[mousedOverElementIndex*4].x]];
            [infoOutput.yCoordRectLabel setStringValue:[NSString stringWithFormat:@"%i",(int)points[mousedOverElementIndex*4].y]];
            [infoOutput.widthLabel setStringValue:[NSString stringWithFormat:@"%i",(int)rectWidth]];
            [infoOutput.heightLabel	setStringValue:[NSString stringWithFormat:@"%i",(int)rectHeight]];
            [infoOutput.trackNumberLabel setStringValue:[keys objectAtIndex:mousedOverElementIndex]];
            currentKey = [keys objectAtIndex:mousedOverElementIndex];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverToolValueChanged" object:nil];
            
            //display tooltip
            Vector2 tooltipVect = spaceConverter.ImageToScreenVector(Vector2(points[mousedOverElementIndex*4+1].x,points[mousedOverElementIndex*4+1].y));
            NSRect newframe  = NSMakeRect(tooltipVect.x, tooltipVect.y, tooltip.frame.size.width, tooltip.frame.size.height);
            
            [tooltip.nameField setStringValue:[keys objectAtIndex:mousedOverElementIndex] ];
            int ind =(int)[tooltip.typeSelectionBox.objectValues indexOfObject:[elementTypes objectAtIndex:mousedOverElementIndex]];
            if (ind < 0 ) ind = (int)[tooltip.typeSelectionBox.objectValues indexOfObject:@"None"];
            [tooltip.typeSelectionBox selectItemAtIndex:ind];
            [tooltip setFrame:newframe];
            [superView addSubview:tooltip];
            [tooltip setHidden:NO];
            inCont = true;
            continue;
        }
        
    }
    //check if mouse is in the tooltip
    std::vector<cv::Point>cont;
    int border = 20;
    Vector2 bottomLeft(tooltip.frame.origin.x-border,tooltip.frame.origin.y-border);
    Vector2 bottomRight(bottomLeft.x+tooltip.frame.size.width+border*2,bottomLeft.y);
    Vector2 topRight(bottomRight.x,bottomRight.y+tooltip.frame.size.height+border*2);
    Vector2 topLeft(bottomLeft.x,topRight.y);
    if (comboBoxIsOpen) {
        bottomRight.y -= tooltip.typeSelectionBox.itemHeight*tooltip.typeSelectionBox.objectValues.count;
        bottomLeft.y -= tooltip.typeSelectionBox.itemHeight*tooltip.typeSelectionBox.objectValues.count;
    }
    cont.push_back(topLeft.AsCvPoint());
    cont.push_back(topRight.AsCvPoint());
    cont.push_back(bottomRight.AsCvPoint());
    cont.push_back(bottomLeft.AsCvPoint());
    float dist = cv::pointPolygonTest(cont, mouseP.AsCvPoint(), true);
    if (dist >= 0) {
        inCont = true;
    }
    
    if (!inCont) {
        currentKey = @"nil";
        mousedOverElementIndex = -1;
        [infoOutput.xCoordRectLabel setStringValue:@"NA"];
        [infoOutput.yCoordRectLabel setStringValue:@"NA"];
        [infoOutput.widthLabel setStringValue:@"NA"];
        [infoOutput.heightLabel	setStringValue:@"NA"];
        [tooltip setHidden:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverToolValueChanged" object:nil];
    }
    if(distance<-5) //If further than 5 screen pixels from the closest point:
    {
        mousedOverLineIndex = -1;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@(mousedOverElementIndex)];
    
    
}
- (void)DragTo:(Vector3)point Event:(NSEvent *)event
{
    point.x = floor(point.x);
    point.y = floor(point.y);
    float ratio = 1;
    if (defaultHeight != 0) {
        ratio = (defaultWidth+0.0)/(defaultHeight+0.0);
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
    else if(mousedOverElementIndex >= 0)
    {
        if (!dragRectBegin)//We are just beginning the rect drag, store initial mouse position
        {
            dragRectBegin = true;
            Vector2 p1 = points[mousedOverElementIndex*4];
            Vector2 p2 = points[mousedOverElementIndex*4+1];
            Vector2 p3 = points[mousedOverElementIndex*4+2];
            Vector2 p4 = points[mousedOverElementIndex*4+3];
            initialDragDistances[0] = (point-p1);
            initialDragDistances[1] = (point-p2);
            initialDragDistances[2] = (point-p3);
            initialDragDistances[3] = (point-p4);
        }
        else
        {
            points[mousedOverElementIndex*4]   = point-initialDragDistances[0];
            points[mousedOverElementIndex*4+1] = point-initialDragDistances[1];
            points[mousedOverElementIndex*4+2] = point-initialDragDistances[2];
            points[mousedOverElementIndex*4+3] = point-initialDragDistances[3];
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
            [self addElement:r color:Blue forKey:newRectKey];
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

- (void)mouseClickedAtPoint:(Vector2)p superPoint:(Vector2)SP withEvent:(NSEvent *)event
{
    if ([event modifierFlags] & NSCommandKeyMask) {
        if (!madeNewRect) {
            int currentKeyNum =points.Length/4;
            while ([usedRectangleNumberKeys containsObject:@(currentKeyNum)]) {
                currentKeyNum++;
            }
            [usedRectangleNumberKeys addObject:@(currentKeyNum)];
            NSString *newRectKey =[NSString stringWithFormat:@"Rectangle %i",currentKeyNum];
            [self addElement:NSMakeRect(floor(p.x-defaultWidth/2), floor(p.y-defaultHeight/2), defaultWidth, defaultHeight) color:Blue forKey:newRectKey];
        }
        
    }

    if ([event modifierFlags] & NSShiftKeyMask) {
        if (mousedOverElementIndex >= 0) {
            [self removeElementAtIndex:mousedOverElementIndex];
        }
    }
    if ([event modifierFlags] & NSFunctionKeyMask) {
        if (mousedOverElementIndex >= 0) {
            if (![rectTrackingForRectsWithKeys containsObject:[keys objectAtIndex:mousedOverElementIndex]]) {
                [rectTrackingForRectsWithKeys addObject:[keys objectAtIndex:mousedOverElementIndex]];
            }
            else
            {
                [rectTrackingForRectsWithKeys removeObject:[keys objectAtIndex:mousedOverElementIndex]];
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
    if (mousedOverElementIndex >=0) {
        draggedIndex = mousedOverElementIndex;
        return [super StartDragging:withKeys];
    }
    
    else
    {
        if(mousedOverElementIndex<0)
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

    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

- (void)StopDragging
{
    dragStarted = false;
    draggingDiffIsSet = false;
    [self reOrderPointArray];
    dragRectBegin = false;
    [super StopDragging];
    mousedOverLineIndex = -1;
    
    draggedIndex = -1;
    madeNewRect = false;
}

@end
