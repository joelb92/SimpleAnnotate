//
//  GLPointArrayTool.m
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 6/20/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "GLPointArrayTool.h"

@implementation GLPointArrayTool
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableHoverRect:) name:@"TableViewHoverChanged" object:nil];
    }
    return self;
}

-(void)addElement:(NSRect)er color:(Color)c forKey:(NSString *)key
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
        [segColors addElement:c];
    }
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
        
        [pointStructureMap removeObjectAtIndex:i];
        [pointStructureIndexMap removeObjectAtIndex:i];
        
        p.RemoveItemAtIndex(pIndex);
        
        if(p.Length == 0){
            [keys removeObject:key];
            pointSets.erase(pointSets.begin()+structureIndex);
            [segColors removeElementAtIndex:structureIndex];
        }
        
        
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
        [pointsDict setValue:arr forKey:[keys objectAtIndex:i]];
    }
    return pointsDict;
}

-(void)setElements:(NSDictionary *)rects
{
    [self clearAll];
    for(int i = 0; i < rects.count; i++)
    {
        NSObject *key = [rects.allKeys objectAtIndex:i];
        [keys addObject:key];
        NSArray *arr = [rects objectForKey:key];
        [segColors addElement:Blue];
        Vector2Arr p = Vector2Arr();
        for (int j = 0; j < arr.count; j++) {
            NSPoint np = [[arr objectAtIndex:j] pointValue];
            [self addElement:NSMakeRect(np.x, np.y, 0, 0) color:Blue forKey:key];
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

-(NSMutableArray *)getKeys
{
    return keys;
}

-(NSUInteger)count{
    return pointSets.size();
}

-(void)clearAll
{
    mousedOverLineIndex = mousedOverPointIndex = -1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@(mousedOverElementIndex)];
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
    allPoints = Vector2Arr();
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
    Vector2 imagePoint = spaceConverter.ScreenToImageVector(mouseP);
    bool inCont = false;
    bool onPoint = false;
    [super SetMousePosition:mouseP UsingSpaceConverter:spaceConverter];
    for(int i=0; i < pointSets.size(); i++)
    {
        
        Vector2Arr p = pointSets[i];

        float distval = cv::pointPolygonTest(p.asCVContour(), imagePoint.AsCvPoint(), true);
        
        if (distval > -5) {
            inCont = true;

            mousedOverElementIndex = i;
            currentKey = [keys objectAtIndex:i];
            [infoOutput.trackNumberLabel setStringValue:[keys objectAtIndex:mousedOverElementIndex]];

        }
    }
    float minDist = 20*20;
    for(int i = 0; i < allPoints.Length; i++)
    {
        if(allPoints[i].SqDistanceTo(imagePoint) <= minDist)
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
        
    }
    if(!onPoint) mousedOverPointIndex = -1;
    if(!initialized) [self InitializeWithSpaceConverter:spaceConverter];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectionChanged" object:@(mousedOverEllipseIndex)];
    
}
- (void)DragTo:(Vector3)point Event:(NSEvent *)event
{
    point.x = floor(point.x);
    point.y = floor(point.y);
    
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TableReload" object:nil];
    
}
}



- (void)ResetHandles
{
    initialized = false;
}

- (void)mouseClickedAtPoint:(Vector2)p withEvent:(NSEvent *)event
{
    
    if (([event modifierFlags] & NSCommandKeyMask) && (([event modifierFlags] & NSAlternateKeyMask)  ||  pointSets.size() == 0)) {
        if (!madeNewRect) {
            int currentKeyNum =int(pointSets.size());
            while ([usedRectangleNumberKeys containsObject:@(currentKeyNum)]) {
                currentKeyNum++;
            }
            [usedRectangleNumberKeys addObject:@(currentKeyNum)];
            NSString *newRectKey =[NSString stringWithFormat:@"Point Set %i",currentKeyNum];
            currentAdditionKey= newRectKey;
            [self addElement:NSMakeRect(p.x, p.y, defaultWidth, defaultHeight) color:Blue forKey:newRectKey];
        }
        
    }
    else if([event modifierFlags] & NSCommandKeyMask)
    {
        NSString *newRectKey;
        if([currentAdditionKey isEqualToString:@""] || currentAdditionKey == nil)
        {
             newRectKey =[NSString stringWithFormat:@"Point Set 0"];
        }
        else newRectKey = currentAdditionKey;
        [self addElement:NSMakeRect(p.x, p.y, 0, 0) color:Blue forKey:newRectKey];
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
