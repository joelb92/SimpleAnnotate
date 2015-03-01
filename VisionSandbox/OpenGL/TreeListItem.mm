//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "TreeListItem.h"

NSString *const TreeListItemUTI = @"com.MagnaMirrors.DIFMapDecoder.TreeListItem";

@implementation TreeListItem
@synthesize object;
@synthesize HasObject;
@synthesize Enabled;
@synthesize name;
@synthesize keyPath;
@synthesize parent;
@synthesize children;
@synthesize Expanded;
@synthesize Holder;
- (void)encodeWithCoder:(NSCoder*)aCoder
{
	[aCoder encodeBool:HasObject forKey:@"HasObject"];
	[aCoder encodeBool:Enabled forKey:@"Enabled"];
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeObject:keyPath forKey:@"keyPath"];
	[aCoder encodeObject:parent forKey:@"parent"];
	[aCoder encodeObject:children forKey:@"children"];
	[aCoder encodeBool:Expanded forKey:@"Expanded"];
	[aCoder encodeObject:Holder forKey:@"Holder"];
}
- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super init];
	if(self)
	{
		HasObject = [aDecoder decodeBoolForKey:@"HasObject"];
		Enabled = [aDecoder decodeBoolForKey:@"Enabled"];
		object = nil;
		name = [[aDecoder decodeObjectForKey:@"name"] retain];
		keyPath = [[aDecoder decodeObjectForKey:@"keyPath"] retain];
		parent = [[aDecoder decodeObjectForKey:@"parent"] retain];
		children = [[aDecoder decodeObjectForKey:@"children"] retain];
		Expanded = [aDecoder decodeBoolForKey:@"Expanded"];
		Holder = [[aDecoder decodeObjectForKey:@"Holder"] retain];
	}
	return self;
}

- (void)setObject:(id)obj
{
	[obj retain];
	if(obj) HasObject = YES;
	if(object)
	{
		[object release];
		object = nil;
	}
	object = obj;
}
- (id)object
{
	return [[object retain] autorelease];
}
- (id)init
{
	return nil;
}
- (id)initWithObject:(id)obj KeyPath:(NSString*)key Parent:(TreeListItem*)par
{
	self = [super init];
	if(self)
	{
		Enabled = true;
		object = [obj retain];
		HasObject = object!=nil;
		name = [[[key componentsSeparatedByString:@"/"] lastObject] retain];
		keyPath = [key retain];
		parent = [par retain];
		children = [[NSMutableArray alloc] init];
		Expanded = YES;
	}
	return self;
}
- (int)indexOfChild:(TreeListItem*)child
{
	int i=0;
	for(TreeListItem*sibling in children)
	{
		if([sibling.keyPath isEqualToString:child.keyPath]) return i;
		i++;
	}
	return -1;
}
- (NSArray*)writableTypesForPasteboard:(NSPasteboard*)pasteboard
{
	return [self.keyPath writableTypesForPasteboard:pasteboard];
}
- (id)pasteboardPropertyListForType:(NSString *)type
{
    return nil;
}
- (NSPasteboardWritingOptions)writingOptionsForType:(NSString*)type pasteboard:(NSPasteboard*)pasteboard
{
	return 0;
}
+ (NSArray*)readableTypesForPasteboard:(NSPasteboard*)pasteboard
{
    return [NSArray arrayWithObjects:(id)kUTTypeFolder, (id)kUTTypeFileURL, nil];
}
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString*)type pasteboard:(NSPasteboard*)pasteboard
{
    return NSPasteboardReadingAsString;
}
- (void)valueForUndefinedKey:(NSString*)key
{
	NSLog(@"Failed to access TreeListItem %@ for key %@",self.description,key);
}

+ (BOOL)Item:(TreeListItem*)potentialAncestorItem IsAAncestorOfItem:(TreeListItem*)Item
{
	TreeListItem*AAncestor = Item;
	while(AAncestor)
	{
		if(potentialAncestorItem == AAncestor || [TreeListItem Item:potentialAncestorItem IsAAncestorOfItem:Item.parent]) return YES;
		AAncestor = AAncestor.parent;
	}
	return NO;
}

- (NSString*)description
{
	NSString*string = [NSString stringWithFormat:@"%@ (%@)",name,keyPath];
	if(children.count>0)
	{
		string = [string stringByAppendingString:@"\n{"];
		for(int i=0; i<children.count; i++)
		{
			TreeListItem*child = [children objectAtIndex:i];
			string = [string stringByAppendingString:@"\n\t"];
			string = [string stringByAppendingString:[[child description] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];
		}
		string = [string stringByAppendingString:@"\n}"];
	}
	return string;
}

- (void)dealloc
{
	[object release];
	[name release];
	[keyPath release];
	[parent release];
	[children release];
	[Holder release];
	[super dealloc];
}
@end