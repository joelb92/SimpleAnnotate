//
//  GLPointArrayTool.m
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 6/20/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "GLPointArrayTool.h"

@implementation GLPointArrayTool
@synthesize scissorTool;
- (id)initWithOutputView:(InfoOutputController *)inf
{
    self = [super init];
    if(self)
    {
        mousedOverLineIndex = mousedOverPointIndex = mousedOverElementIndex = -1;
        initialized = false;
        segColors = [[colorArr alloc] init];
        keys = [[NSMutableArray alloc] init];
        currentKey = @"nil";
        skippedRects = intArr();
        infoOutput = inf;
        rectPositionsForKeys = [[NSMutableDictionary alloc] init];
        pointStructureMap = [[NSMutableArray alloc] init];
        pointStructureIndexMap = [[NSMutableArray alloc] init];
        scissorTool = [[IntelligentScissors alloc] init];
        isMagneticArray = [[NSMutableArray alloc] init];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableHoverRect:) name:@"TableViewHoverChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lassoTypeDidChange:) name:@"LassoSelectionChanged" object:nil];

    }
    return self;
}

-(void)keyDownHappened:(NSNotification *)notification
{
    NSEvent * event = notification.object;
    if(event.keyCode == 36)
    {
    if (scissorTool.scissorActive)
    {
        [scissorTool endScissorSession];
        [self appendElements:scissorTool.getPointArray];
//        isMagnetic = false;
    }
    }
}

-(void)addElement:(NSRect)er color:(Color)c forKey:(NSString *)key
{
    [self addElement:er color:c forKey:key andType:currentAnnotationType];
}

-(void)addElement:(NSRect)er color:(Color)c forKey:(NSString *)key andType:(NSString *)type
{
    Vector2 v(er.origin.x,er.origin.y);
    Vector2Arr p;
    if([keys containsObject:key])
    {
        int index = (int)[keys indexOfObject:key];
        p = pointSets[index];
        p.AddItemToEnd(v);
        pointSets[index] = p;
        
    }
    else
    {
        p = Vector2Arr();
        p.AddItemToEnd(v);
        pointSets.push_back(p);
        [keys addObject:key];
        [elementTypes addObject:type];
        [segColors addElement:c];
    }
    [isMagneticArray addObject:[NSNumber numberWithBool:isMagnetic]];
    allPoints.AddItemToEnd(v);
    [pointStructureMap addObject:key];
    [pointStructureIndexMap addObject:@(p.Length-1)];
}



-(void)removeElementAtIndex:(int)i
{
    if (i < allPoints.Length && i >=0) {
        NSString *key = [pointStructureMap objectAtIndex:i];
        int structureIndex = (int)[keys indexOfObject:key];
        Vector2Arr p = pointSets[structureIndex];
        int pIndex = [[pointStructureIndexMap objectAtIndex:i] intValue];
        
        for(int j = 0; j < pointStructureIndexMap.count; j++)
        {
            int val =[[pointStructureIndexMap objectAtIndex:j] intValue];
            if ([[pointStructureMap objectAtIndex:j] isEqualToString:key] &&  val > [[pointStructureIndexMap objectAtIndex:i] intValue] && val > 0) {
                [pointStructureIndexMap replaceObjectAtIndex:j withObject:@(val-1)];
            }
        }
        
        [pointStructureMap removeObjectAtIndex:i];
        [pointStructureIndexMap removeObjectAtIndex:i];
        
        p.RemoveItemAtIndex(pIndex);
        pointSets[structureIndex] = p;
        [isMagneticArray removeObjectAtIndex:i];

        if(p.Length == 0){
            [keys removeObject:key];
            [elementTypes removeObjectAtIndex:structureIndex];
            pointSets.erase(pointSets.begin()+structureIndex);
            [segColors removeElementAtIndex:structureIndex];
        }
        
        allPoints.RemoveItemAtIndex(i);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@[self,@(mousedOverElementIndex)]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

-(NSDictionary *)getElements
{
    NSMutableDictionary *pointsDict = [NSMutableDictionary dictionaryWithCapacity:pointSets.size()];
    for(int i = 0; i < pointSets.size(); i++)
    {
        Vector2Arr p = pointSets[i];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(int j = 0; j < p.Length; j++)
        {
            Vector2 point = p[j];
            [arr addObject:[NSValue valueWithPoint:point.AsNSPoint()]];
        }
        NSDictionary *setDict = [NSDictionary dictionaryWithObjects:@[arr,[elementTypes objectAtIndex:i]] forKeys:@[@"coords",@"type"]];
        [pointsDict setValue:setDict forKey:[keys objectAtIndex:i]];
    }
    return pointsDict;
}

-(void)setElements:(NSDictionary *)rects
{
    [self clearAll];
    for(int i = 0; i < rects.count; i++)
    {
        NSObject *key = [rects.allKeys objectAtIndex:i];
        NSDictionary *dict = [rects objectForKey:key];
        NSArray *arr = [dict objectForKey:@"coords"];
        [segColors addElement:Blue];
        Vector2Arr p = Vector2Arr();
        for (int j = 0; j < arr.count; j++) {
            NSPoint np = [[arr objectAtIndex:j] pointValue];
            [self addElement:NSMakeRect(np.x, np.y, 0, 0) color:Blue forKey:key andType:[dict objectForKey:@"type"]];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

-(void)appendElements:(NSDictionary *)rects
{
    for(int i = 0; i < rects.count; i++)
    {
        NSObject *key = [rects.allKeys objectAtIndex:i];
        NSDictionary *dict = [rects objectForKey:key];
        NSArray *arr = [dict objectForKey:@"coords"];
        [segColors addElement:Blue];
        Vector2Arr p = Vector2Arr();
        for (int j = 0; j < arr.count; j++) {
            NSPoint np = [[arr objectAtIndex:j] pointValue];
            [self addElement:NSMakeRect(np.x, np.y, 0, 0) color:Blue forKey:key andType:[dict objectForKey:@"type"]];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

-(NSString *)stringForKey:(NSObject *)key
{
    return [self stringForIndex:(int)[keys indexOfObject:key]];
}

-(NSString *)stringForIndex:(int)i
{
    Vector2Arr p = pointSets[i];
    NSString * s = [NSString stringWithFormat:@"c: %i,%i Num Points: %i",(int)p.CenterOfMass().x,(int)p.CenterOfMass().y,p.Length];
    return s;
}

-(void)clearAll
{
    mousedOverLineIndex = mousedOverPointIndex = -1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@[self,@(mousedOverElementIndex)]];
    if (segColors) {
    }
    if (keys) {
    }
    segColors = [[colorArr alloc] init];
    keys = [[NSMutableArray alloc] init];
    pointSets = std::vector<Vector2Arr>();
    currentKey = @"nil";
    [pointStructureIndexMap removeAllObjects];
    [pointStructureMap removeAllObjects];
    [elementTypes removeAllObjects];
    [isMagneticArray removeAllObjects];
    allPoints = Vector2Arr();
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
}

- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
    bool ismousedover = false;
    screenPixelLength = spaceConverter.ScreenToCameraVector(Vector2(1,0)).x;

    previousColor = Color(NAN,NAN,NAN);
    [lock lock];
    glEnable(GL_POINT_SMOOTH);
    glLineWidth(3);
    glPointSize(15);
    
    {
        for(int i=0; i<pointSets.size(); i++)
        {
            
            [self SetCurrentColor:[segColors elementAtIndex:i]];
            Vector2Arr points = pointSets[i];
            glLineWidth(2);
            glBegin(GL_LINE_LOOP);
            //Draw the ellipse
            if (i == mousedOverElementIndex){
                ismousedover = true;
                [self SetCurrentColor:Green];
            }
            for(int j=0; j<points.Length; j++)
            {
                Vector2 v = spaceConverter.ImageToCameraVector(points[j]);
                glVertex3d(v.x, v.y, minZ);
            }
            [self SetCurrentColor:Red];
            glEnd();
            
            glPointSize(10);
            glBegin(GL_POINTS);
            //Draw ellipse drag handles if within the correct area

            [self SetCurrentColor:[segColors elementAtIndex:i]];
            

            for(int j=0; j<points.Length; j++)
            {
                if (mousedOverPointIndex >= 0 && [[pointStructureMap objectAtIndex:mousedOverPointIndex] isEqualToString:[keys objectAtIndex:i]] && [[pointStructureIndexMap objectAtIndex:mousedOverPointIndex] intValue] == j) {
                    [self SetCurrentColor:Yellow];
                }
                Vector2 v = spaceConverter.ImageToCameraVector(points[j]);
                glVertex3d(v.x, v.y, minZ);
                [self SetCurrentColor:[segColors elementAtIndex:i]];
            }
            if (mousedOverPointIndex >= 0) {
                [self SetCurrentColor:Yellow];
                glVertex3d(allPoints[mousedOverPointIndex].x, allPoints[mousedOverPointIndex].y, minZ);
            }
            glEnd();
            
            [self SetCurrentColor:[segColors elementAtIndex:i]];
            
            
            
        }
        
        
    }
    if (scissorTool.scissorActive) {
        std::vector<cv::Point> sPoints = scissorTool.pathPoints;
        glPointSize(10);

        glBegin(GL_POINTS);
//        glLineWidth(1);
        [self SetCurrentColor:Red];
        if(sPoints.size() > 0)
        {
        for(int i = 0; i < sPoints.size()-1; i++)
        {
            Vector2 p1 = spaceConverter.ImageToCameraVector(sPoints[i]);
            Vector2 p2 = spaceConverter.ImageToCameraVector(sPoints[i+1]);
            glVertex3d(p1.x, p1.y, minZ);
//            glVertex3d(p2.x, p2.y, minZ);
        }
        }
        glEnd();
    }
    [lock unlock];
}

-(void)lassoTypeDidChange:(NSNotification *)notification
{
    NSNumber *n = notification.object;
    if (n.intValue == 0)
    {
        isMagnetic = true;
        [scissorTool endScissorSession];
    }
    else if(n.intValue == 1)
    {
        isMagnetic = false;
    }
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
    bool inCont = false;
    bool onPoint = false;
    [super SetMousePosition:mouseP UsingSpaceConverter:spaceConverter];
    for(int i=0; i < pointSets.size(); i++)
    {
        
        Vector2Arr p = pointSets[i];
        std::vector<cv::Point2f> contour = p.asCVContour();
        float distval = cv::pointPolygonTest(contour, imagePoint.AsCvPoint(), true);
        cv::Point farthestLeft,farthestRight,Highest,Lowest;
        farthestLeft.x = INT_MAX; farthestRight.x = INT_MIN; Highest.y = INT_MAX; Lowest.y = INT_MIN;
        //Find the extrema of the contour
        for(int x = 0; x < contour.size(); x++)
        {
            cv::Point p = contour[x];
            if (p.x > farthestRight.x){
                farthestRight.x = p.x;
                farthestRight.y = p.y;
            }
            if (p.x < farthestLeft.x) {
                farthestLeft.x = p.x;
                farthestLeft.y = p.y;
            }
            if (p.y > Lowest.y) {
                Lowest.y = p.y;
                Lowest.x = p.x;
            }
            if (p.y < Highest.y) {
                Highest.y = p.y;
                Highest.x = p.x;
            }
        }
        if (distval > -5) {
            inCont = true;
            
            mousedOverElementIndex = i;
            currentKey = [keys objectAtIndex:i];
            [infoOutput.trackNumberLabel setStringValue:[keys objectAtIndex:mousedOverElementIndex]];
            
            //display tooltip
            
            
            [self drawToolTipAtPosition:spaceConverter.ImageToScreenVector(Vector2(farthestRight)) Corner:0];
        }
    }
    float minDist = 20*20;
    for(int i = 0; i < allPoints.Length; i++)
    {
        float dist = spaceConverter.ImageToScreenVector(allPoints[i]).SqDistanceTo(mouseP);
        if(dist <= minDist)
        {
            {
                
                mousedOverPointIndex = i;
                int innerIndex = [[pointStructureIndexMap objectAtIndex:i] intValue];
//                NSLog(@"inner index: %i",innerIndex);
                [infoOutput.xCoordRectLabel setStringValue:[NSString stringWithFormat:@"%i",(int)allPoints[i].x]];
                [infoOutput.yCoordRectLabel setStringValue:[NSString stringWithFormat:@"%i",(int)allPoints[i].y]];
                [infoOutput.trackNumberLabel setStringValue:[pointStructureMap objectAtIndex:i]];
                currentKey = [pointStructureMap objectAtIndex:i];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverToolValueChanged" object:nil];
                inCont = true;
                onPoint = true;
            }
            break;
        }

        if (inCont) {
//            [tooltip setHidden:NO];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MouseOverToolValueChanged" object:nil];
        mousedOverEllipseIndex = -1;
        [tooltip setHidden:YES forObject:self];

        
    }
    if(!onPoint) mousedOverPointIndex = -1;
    if(!initialized) [self InitializeWithSpaceConverter:spaceConverter];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@[self,@(mousedOverElementIndex)]];
    
}
- (void)DragTo:(Vector3)point Event:(NSEvent *)event
{
    point.x = floor(point.x);
    point.y = floor(point.y);
    if(isMagnetic)
        [scissorTool mouseClickedAtScreenPoint:point.AsVector2()];
    else
    {
//    [scissorTool mouseMove:point.AsVector2()];
    if(!point.isNull() && mousedOverPointIndex >= 0)
    {
        NSString *key = [pointStructureMap objectAtIndex:mousedOverPointIndex];
        int structureIndex = [keys indexOfObject:key];
        int elIndex = [[pointStructureIndexMap objectAtIndex:mousedOverPointIndex] intValue];
        Vector2Arr points = pointSets[structureIndex];
        Vector2 thePoint = points[elIndex];
        if(!draggingDiffIsSet)
        {
            xDifference = thePoint.x-point.x;
            yDifference = thePoint.x-point.x;
            draggingDiffIsSet = true;
        }
        float newYPoint = point.y+yDifference;
        float newXPoint = point.x+xDifference;
        Vector2 newP(newXPoint,newYPoint);
        if(!dragStarted)
        {
            dragStartPoint = newP;
            dragStarted = true;
        }
        points[elIndex] = newP;
        allPoints[mousedOverPointIndex] = newP;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
    }
}
}

-(void)setKey:(NSString *)key atIndexed:(int)index
{
    if (index >= 0 && index < keys.count) {
        NSString *currentobjKey = [keys objectAtIndex:index];
        [keys replaceObjectAtIndex:index withObject:key];
        for(int i = 0; i < pointStructureMap.count; i++)
        {
            if ([[pointStructureMap objectAtIndex:i] isEqualToString:currentobjKey]) {
                [pointStructureMap replaceObjectAtIndex:i withObject:key];
            }
        }
    }
   
    
}

- (void)ResetHandles
{
    initialized = false;
}

- (void)mouseClickedAtPoint:(Vector2)p superPoint:(Vector2)SP withEvent:(NSEvent *)event
{
    int currentKeyNum =int(pointSets.size());
    NSString *newRectKey =[NSString stringWithFormat:@"Point Set %i",currentKeyNum];
    while ([usedRectangleNumberKeys containsObject:newRectKey]) {
        currentKeyNum++;
        newRectKey =[NSString stringWithFormat:@"Point Set %i",currentKeyNum];
    }
    if (([event modifierFlags] & NSCommandKeyMask) && (([event modifierFlags] & NSAlternateKeyMask)  ||  (pointSets.size() == 0 && scissorTool.pathPoints.size() == 0 && scissorTool.startPoint.x == -1 && scissorTool.startPoint.y == -1))) {
        if (!madeNewRect) {
            //We need to make a new point set
            [usedRectangleNumberKeys addObject:newRectKey];
            currentAdditionKey= newRectKey;
            if (isMagnetic) {
                
                    [scissorTool startScissorSessionWithName:newRectKey];
                [usedRectangleNumberKeys addObject:newRectKey];
                [scissorTool mouseClickedAtScreenPoint:p ];
            }
            else{
                [self addElement:NSMakeRect(p.x, p.y, defaultWidth, defaultHeight) color:Blue forKey:newRectKey];
                [usedRectangleNumberKeys addObject:newRectKey];
            }
            
        }
        
    }
    else if([event modifierFlags] & NSCommandKeyMask)
    {
        //We are adding to a point set that already exists
        if(([currentAdditionKey isEqualToString:@""] || currentAdditionKey == nil) or isMagnetic)
        {
        }
        else newRectKey = currentAdditionKey;
        if (isMagnetic) {
            if(scissorTool.scissorActive)
                [scissorTool mouseClickedAtScreenPoint:p];
            else{
                [scissorTool startScissorSessionWithName:newRectKey];
                [scissorTool mouseClickedAtScreenPoint:p];
                [usedRectangleNumberKeys addObject:newRectKey];
            }
        }
        else{
            [self addElement:NSMakeRect(p.x, p.y, 0, 0) color:Blue forKey:newRectKey];
            [usedRectangleNumberKeys addObject:newRectKey];
        }
    }
    
    if ([event modifierFlags] & NSShiftKeyMask) {
        if (mousedOverPointIndex >= 0) {
            [self removeElementAtIndex:mousedOverPointIndex];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];

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
