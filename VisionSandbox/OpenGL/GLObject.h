//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpaceConverter.h"
#import "GLObjectData.h"
#import "idArr.h"
#import "Color.h"

@interface GLObject : NSObject <NSCoding>
{
	Color color;
	double minZ;
	double maxZ;
	
	//If the Z clamp is changed, 
	bool zClampChanged;
	double newMinZ;
	double newMaxZ;
	
	SpaceConverter spaceConverterUsedByDisplayList;
	
	GLObjectData*data;
	
	bool selfDeallocating;
	idArr*parentViewReleaseArray; //Needed to do the final releasing of this object
	ReadWriteLock *lock;
}
@property (readwrite) Color color;
@property (retain) idArr*parentViewReleaseArray;
- (double)zForLayer:(int)layer OfLayers:(int)layers;

- (void)ObjectChanged;

- (NSString*)MouseOverInfoAtScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter;
- (Vector3)MouseOverPointForScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter;

- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter;

- (bool)BeginGraphingUsingSpaceConverter:(SpaceConverter)spaceConverter;
- (void)EndGraphing;

- (bool)BeginAppendingGraphUsingSpaceConverter:(SpaceConverter)spaceConverter;
- (void)EndAppending;
-(bool)ObjectHasChanged;
@end
