//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLViewListCommand.h"
#define CommandsEnabled true

@implementation GLViewListCommand : NSObject
static int maxWidth = 0;
static int maxHeight = 0;
+ (void)AddView:(id)view ForKeyPath:(NSString*)key
{
	if(CommandsEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:GL_AddGLViewNofification object:[[[AddViewCommand alloc] initWithView:view
																																				 KeyPath:key
																																			OtherKeyPath:nil
																																				   Place:WhereEver] autorelease]];
}
+ (void)AddView:(id)view ForKeyPath:(NSString*)key AfterKeyPath:(NSString*)afterKey
{
	if(CommandsEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:GL_AddGLViewNofification object:[[[AddViewCommand alloc] initWithView:view
																																				 KeyPath:key
																																			OtherKeyPath:afterKey
																																				   Place:After] autorelease]];
}
+ (void)AddView:(id)view ForKeyPath:(NSString*)key BeforeKeyPath:(NSString*)beforeKey
{
	if(CommandsEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:GL_AddGLViewNofification object:[[[AddViewCommand alloc] initWithView:view
																																				 KeyPath:key
																																			OtherKeyPath:beforeKey
																																				   Place:Before] autorelease]];
}

+ (void)AddObject:(id)object ToViewKeyPath:(NSString*)viewKeyPath ForKeyPath:(NSString*)key
{
	if ([object isKindOfClass:OpenImageHandler.class])
	{
		int height = [(OpenImageHandler *)object size].height;
		int width = [(OpenImageHandler *)object size].width;
		if (width > maxWidth) {
			maxWidth = width;
		}
		if (height > maxHeight) {
			maxHeight = height;
		}
	}
	
	if(CommandsEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:GL_AddGLObjectToGLViewNotification object:[[[AddObjectCommand alloc] initWithObject:object
																																							   KeyPath:key
																																						  OtherKeyPath:nil
																																						   ViewKeyPath:viewKeyPath
																																								 Place:WhereEver] autorelease]];
	[GLViewListCommand SetViewKeyPath:viewKeyPath MaxImageSpaceRect:vector2Rect(Vector2(0,0), Vector2(maxWidth,maxHeight))];

}
+ (void)AddObject:(id)object ToViewKeyPath:(NSString*)viewKeyPath ForKeyPath:(NSString*)key AfterKeyPath:(NSString*)afterKey
{
	if(CommandsEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:GL_AddGLObjectToGLViewNotification object:[[[AddObjectCommand alloc] initWithObject:object
																																							   KeyPath:key
																																						  OtherKeyPath:afterKey
																																						   ViewKeyPath:viewKeyPath
																																								 Place:After] autorelease]];
}
+ (void)AddObject:(id)object ToViewKeyPath:(NSString*)viewKeyPath ForKeyPath:(NSString*)key BeforeKeyPath:(NSString*)beforeKey
{
	if(CommandsEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:GL_AddGLObjectToGLViewNotification object:[[[AddObjectCommand alloc] initWithObject:object
																																							   KeyPath:key
																																						  OtherKeyPath:beforeKey
																																						   ViewKeyPath:viewKeyPath
																																								 Place:Before] autorelease]];
}

+ (void)SetViewKeyPath:(NSString*)viewKeyPath MaxImageSpaceRect:(vector2Rect)imageRect
{
	if(CommandsEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:GL_ChangeMaxImageRectOfGLViewNotification object:[[[SetMaxImageSpaceCommand alloc] initWithViewKeyPath:viewKeyPath
																																												ImageRect:imageRect] autorelease]];
}

+ (void)ResetView:(NSString*)viewKeyPath
{
	if(CommandsEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:GL_ResetGLViewNotification object:viewKeyPath];
}

+ (void)ClearView:(NSString*)viewKeyPath
{
	if(CommandsEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:GL_ClearGLViewNotification object:viewKeyPath];
}
@end


@implementation AddViewCommand : NSObject
@synthesize view;
@synthesize keyPath;
@synthesize otherKeyPath;
@synthesize place;
- (id)initWithView:(id)v KeyPath:(NSString*)kp OtherKeyPath:(NSString*)okp Place:(Place)p
{
	self = [super init];
	if(self)
	{
		view = [v retain];
		keyPath = [kp retain];
		otherKeyPath = [okp retain];
		place = p;
	}
	return self;
}

- (void)dealloc
{
	[view release];
	[keyPath release];
	[otherKeyPath release];
	[super dealloc];
}
@end


@implementation AddObjectCommand : NSObject
@synthesize object;
@synthesize keyPath;
@synthesize otherKeyPath;
@synthesize viewKeyPath;
@synthesize place;
- (id)initWithObject:(id)o KeyPath:(NSString*)kp OtherKeyPath:(NSString*)okp ViewKeyPath:(NSString*)vkp Place:(Place)p
{
	self = [super init];
	if(self)
	{
		object = [o retain];
		keyPath = [kp retain];
		otherKeyPath = [okp retain];
		viewKeyPath = [vkp retain];
		place = p;
	}
	return self;
}

- (void)dealloc
{
	[object release];
	[keyPath release];
	[otherKeyPath release];
	[viewKeyPath release];
	[super dealloc];
}
@end

@implementation SetMaxImageSpaceCommand : NSObject
@synthesize viewKeyPath;
@synthesize imageRect;
- (id)initWithViewKeyPath:(id)vkp ImageRect:(vector2Rect)ir
{
	self = [super init];
	if(self)
	{
		viewKeyPath = [vkp retain];
		imageRect = ir;
	}
	return self;
}

- (void)dealloc
{
	[viewKeyPath release];
	[super dealloc];
}
@end