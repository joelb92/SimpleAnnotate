//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector3Arr.h"
#import "GLObject.h"
#import "TreeList.h"
#import "idArr.h"

@interface GLObjectList : TreeList
{
	idArr*releaseArr;
}
- (void)releaseDeallocedObjects;

- (Vector3)MouseOverPointAtScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter;
- (void)MouseOverInfoAtScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter;
- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter;
@end
