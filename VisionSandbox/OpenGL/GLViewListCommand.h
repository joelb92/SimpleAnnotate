//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vector2Rect.h"
#import "OpenImageHandler.h"
typedef enum
{
	Before,
	After,
	WhereEver
} Place;


@interface GLViewListCommand : NSObject
+ (void)AddView:(id)view ForKeyPath:(NSString*)key;
+ (void)AddView:(id)view ForKeyPath:(NSString*)key AfterKeyPath:(NSString*)afterKey;
+ (void)AddView:(id)view ForKeyPath:(NSString*)key BeforeKeyPath:(NSString*)beforeKey;

+ (void)AddObject:(id)object ToViewKeyPath:(NSString*)viewKeyPath ForKeyPath:(NSString*)key;
+ (void)AddObject:(id)object ToViewKeyPath:(NSString*)viewKeyPath ForKeyPath:(NSString*)key AfterKeyPath:(NSString*)afterKey;
+ (void)AddObject:(id)object ToViewKeyPath:(NSString*)viewKeyPath ForKeyPath:(NSString*)key BeforeKeyPath:(NSString*)beforeKey;

+ (void)SetViewKeyPath:(NSString*)viewKeyPath MaxImageSpaceRect:(vector2Rect)imageRect;

+ (void)ResetView:(NSString*)viewKeyPath;

+ (void)ClearView:(NSString*)viewKeyPath;
@end

NSString *const GL_AddGLViewNofification = @"Add GLView";
@interface AddViewCommand : NSObject
{
	id view;
	NSString*keyPath;
	NSString*otherKeyPath;
	Place place;
}
@property (retain) id view;
@property (retain) NSString*keyPath;
@property (retain) NSString*otherKeyPath;
@property (readwrite) Place place;

- (id)initWithView:(id)v KeyPath:(NSString*)kp OtherKeyPath:(NSString*)okp Place:(Place)p;
@end 

NSString *const GL_AddGLObjectToGLViewNotification = @"Add GLObject To GLView";
@interface AddObjectCommand : NSObject
{
	id object;
	NSString*keyPath;
	NSString*otherKeyPath;
	NSString*viewKeyPath;
	Place place;
}
@property (retain) id object;
@property (retain) NSString*keyPath;
@property (retain) NSString*otherKeyPath;
@property (retain) NSString*viewKeyPath;
@property (readwrite) Place place;
- (id)initWithObject:(id)o KeyPath:(NSString*)kp OtherKeyPath:(NSString*)okp ViewKeyPath:(NSString*)vkp Place:(Place)p;
@end

NSString *const GL_ChangeMaxImageRectOfGLViewNotification = @"Change Max Image Rect Of GLView";
@interface SetMaxImageSpaceCommand : NSObject
{
	NSString*viewKeyPath;
	vector2Rect imageRect;
}
@property (retain) NSString*viewKeyPath;
@property (readwrite) vector2Rect imageRect;
- (id)initWithViewKeyPath:(id)vkp ImageRect:(vector2Rect)ir;
@end

NSString *const GL_ResetGLViewNotification = @"Reset GLView";
NSString *const GL_ClearGLViewNotification = @"Clear GLView";