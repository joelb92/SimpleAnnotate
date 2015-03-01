//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TreeList;
@interface TreeListItem : NSObject <NSPasteboardWriting, NSPasteboardReading, NSCoding>
{
	id object;
	BOOL HasObject;
	bool Enabled;
	NSString*name;
	NSString*keyPath;
	TreeListItem*parent;
	NSMutableArray*children;
	BOOL Expanded;
	TreeList*Holder;
}
@property (retain) id object;
@property (readonly) BOOL HasObject;
@property (readwrite) bool Enabled;
@property (retain) NSString*name;
@property (retain) NSString*keyPath;
@property (retain) TreeListItem*parent;
@property (retain) NSMutableArray*children;
@property (readwrite) BOOL Expanded;
@property (retain) TreeList*Holder;

- (id)initWithObject:(id)obj KeyPath:(NSString*)key Parent:(TreeListItem*)par;

- (int)indexOfChild:(TreeListItem*)child;

+ (BOOL)Item:(TreeListItem*)potentialAncestorItem IsAAncestorOfItem:(TreeListItem*)Item;
@end
