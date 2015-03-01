//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLObjectList.h"

@implementation GLObjectList

- (id)init
{
	self = [super init];
	if(self)
	{
		releaseArr = [[idArr alloc] init];
	}
	return self;
}
- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self)
	{
		releaseArr = [[idArr alloc] init];
	}
	return self;
}
- (id)initWithBackupPath:(NSString*)backupPath
{
	self = [super initWithBackupPath:backupPath];
	if(self)
	{
		releaseArr = [[idArr alloc] init];
	}
	return self;
}
- (void)releaseDeallocedObjects
{
	[releaseArr reset];
}

- (Vector3)MouseOverPointAtScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	[lock lock];
	Vector3 closest = Vector3(NAN,NAN,NAN);
	if(spaceConverter.type==_2d)
	{
		Vector3Arr points = Vector3Arr();
		[self MouseOverPoints:&points OfChildrenOfTreeListItem:root AtScreenPoint:screenPoint UsingSpaceConverter:spaceConverter];
		closest = points.ClosestPointToPoint(Vector3(spaceConverter.ScreenToImageVector(screenPoint)));
		points.Deallocate();
	}
	else if(spaceConverter.type==_3d)
	{
		Vector3Arr points = Vector3Arr();
		[self MouseOverPoints:&points OfChildrenOfTreeListItem:root AtScreenPoint:screenPoint UsingSpaceConverter:spaceConverter];
		closest = points.ClosestPointToRay(spaceConverter.RayFromScreenPoint(screenPoint));
		points.Deallocate();
	}
	[lock unlock];
	return closest;
}
- (void)MouseOverPoints:(Vector3Arr*)points OfChildrenOfTreeListItem:(TreeListItem*)treeList AtScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	@autoreleasepool
	{
		if(treeList)
		{
			for(int i=0; i<treeList.children.count; i++)
			{
				TreeListItem*child = [treeList.children objectAtIndex:i];
				if(child.Enabled)
				{
					[self MouseOverPoints:points OfChildrenOfTreeListItem:child AtScreenPoint:screenPoint UsingSpaceConverter:spaceConverter];
					
					GLObject*obj = [((GLObject*)child.object) retain];
					Vector3 point = [obj MouseOverPointForScreenPoint:screenPoint UsingSpaceConverter:spaceConverter];
					[obj release];
					if(!point.isNull())
					{
						points->AddItemToEnd(point);
					}
				}
			}
		}
	}
}

- (void)MouseOverInfoAtScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	[lock lock];
	if(spaceConverter.type==_2d) glTranslatef(0, 0, Objects.count);
	[self MouseOverInfoOfChildrenOfTreeListItem:root AtScreenPoint:screenPoint UsingSpaceConverter:spaceConverter];
	[lock unlock];
}
- (void)MouseOverInfoOfChildrenOfTreeListItem:(TreeListItem*)treeList AtScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	@autoreleasepool
	{
		if(treeList)
		{
			for(int i=0; i<treeList.children.count; i++)
			{
				TreeListItem*child = [treeList.children objectAtIndex:i];
				if(spaceConverter.type==_2d) glTranslatef(0, 0, -1);
				if(child.Enabled)
				{
					[self MouseOverInfoOfChildrenOfTreeListItem:child AtScreenPoint:screenPoint UsingSpaceConverter:spaceConverter];
					
					GLObject*obj = [((GLObject*)child.object) retain];
					[obj MouseOverInfoAtScreenPoint:screenPoint UsingSpaceConverter:spaceConverter];
					[obj release];
				}
			}
		}
	}
}

- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	[lock lock];
	if(spaceConverter.type==_2d) glTranslatef(0, 0, 50);
	[self GraphChildrenOfTreeListItem:root UsingSpaceConverter:spaceConverter];
	[lock unlock];
}
- (void)GraphChildrenOfTreeListItem:(TreeListItem*)treeList UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	@autoreleasepool
	{
		if(treeList)
		{
			for(int i=0; i<treeList.children.count; i++)
			{
				TreeListItem*child = [treeList.children objectAtIndex:i];
				if(spaceConverter.type==_2d) glTranslatef(0, 0, -1);
				if(child.Enabled)
				{
					[self GraphChildrenOfTreeListItem:child UsingSpaceConverter:spaceConverter];
					
					GLObject*obj = [((GLObject*)child.object) retain];
					[obj GraphUsingSpaceConverter:spaceConverter];
					[obj release];
				}
			}
		}
	}
}

- (void)AddObject:(id)object ForKeyPath:(NSString*)key
{
	((GLObject*)object).parentViewReleaseArray = releaseArr;
	[super AddObject:object ForKeyPath:key];
}
- (void)AddObject:(id)object ForKeyPath:(NSString*)key AfterKeyPath:(NSString*)afterKey
{
	((GLObject*)object).parentViewReleaseArray = releaseArr;
	[super AddObject:object ForKeyPath:key AfterKeyPath:afterKey];
}
- (void)AddObject:(id)object ForKeyPath:(NSString*)key BeforeKeyPath:(NSString*)beforeKey
{
	((GLObject*)object).parentViewReleaseArray = releaseArr;
	[super AddObject:object ForKeyPath:key BeforeKeyPath:beforeKey];
}

- (void)dealloc
{
	if(releaseArr.Length>0) NSLog(@"There are some gl objects that are not likely to be released, please fix this asap!!!");
	[releaseArr release];
	[super dealloc];
}
@end
