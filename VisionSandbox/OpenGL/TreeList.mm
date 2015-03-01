//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "TreeList.h"

@implementation TreeList
@synthesize Objects;
@synthesize root;

- (void)encodeWithCoder:(NSCoder*)aCoder
{
	[aCoder encodeInt:countOfNonExpandableItems forKey:@"countOfNonExpandableItems"];
	[aCoder encodeObject:root forKey:@"root"];
	[aCoder encodeObject:Objects forKey:@"Objects"];
}
- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super init];
	if(self)
	{
		countOfNonExpandableItems = [aDecoder decodeIntForKey:@"countOfNonExpandableItems"];
		root = [[aDecoder decodeObjectForKey:@"root"] retain];
		Objects = [[aDecoder decodeObjectForKey:@"Objects"] retain];
		lock = [[ReadWriteLock alloc] init];
	}
	return self;
}
- (id)initWithBackupPath:(NSString*)backupPath
{
	if([[NSFileManager defaultManager] fileExistsAtPath:backupPath])
	{
		self = [[NSKeyedUnarchiver unarchiveObjectWithFile:backupPath] retain];
	}
	else
	{
		self = [self init];
	}
	if(self) BackupPath = [backupPath retain];
	return self;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		countOfNonExpandableItems = 0;
		root = [[TreeListItem alloc] initWithObject:nil KeyPath:@"Root" Parent:nil];
		Objects = [[NSMutableDictionary alloc] init];
		lock = [[ReadWriteLock alloc] init];
		BackupPath = nil;
	}
	return self;
}

- (void)Save
{
	if(BackupPath)
	{
		[NSKeyedArchiver archiveRootObject:self toFile:BackupPath];
	}
}

- (id)ObjectForKeyPath:(NSString*)key
{
	[lock lock];
	id object = [[[Objects valueForKey:key] retain] autorelease];
	[lock unlock];
	return object;
}

- (void)AddObject:(id)object ForKeyPath:(NSString*)key
{
	key = [self FormattedKeyPathForKeyPath:key];
	
	[lock lockForWriting];
	BOOL ItemCreated = NO;
	[self ItemCreatingIfNessisaryWithObject:object ForKey:key ItemWasCreated:&ItemCreated];
	if(ItemCreated)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GL Object Added" object:nil];
	}
	[lock unlock];
	
	[lock lock];
	[self Save];
	[lock unlock];
}
- (void)AddObject:(id)object ForKeyPath:(NSString*)key AfterKeyPath:(NSString*)afterKey
{
	afterKey = [self FormattedKeyPathForKeyPath:afterKey];
	
	[lock lockForWriting];
	BOOL ItemCreated = NO;
	TreeListItem*Item = [self ItemCreatingIfNessisaryWithObject:object ForKey:key ItemWasCreated:&ItemCreated];
	
	if(ItemCreated)
	{
		TreeListItem*afterItem = [Objects valueForKey:afterKey];
		if(afterItem)
		{
			NSMutableArray*children = Item.parent.children;
			[children removeObject:Item];
			Item.parent = afterItem.parent;
			
			children = Item.parent.children;
			int afterIndex = [children indexOfObject:afterItem];
			if(afterIndex == NSNotFound || afterIndex<0)
			{
				[children addObject:Item];
			}
			else
			{
				[children insertObject:Item atIndex:afterIndex+1];
			}
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GL Object Added" object:nil];
	}
	[lock unlock];
	
	[lock lock];
	[self Save];
	[lock unlock];
}
- (void)AddObject:(id)object ForKeyPath:(NSString*)key BeforeKeyPath:(NSString*)beforeKey
{
	beforeKey = [self FormattedKeyPathForKeyPath:beforeKey];
	
	[lock lockForWriting];
	BOOL ItemCreated = NO;
	TreeListItem*Item = [self ItemCreatingIfNessisaryWithObject:object ForKey:key ItemWasCreated:&ItemCreated];
	
	if(ItemCreated)
	{
		TreeListItem*beforeItem = [Objects valueForKey:beforeKey];
		if(beforeItem)
		{
			NSMutableArray*children = Item.parent.children;
			[children removeObject:Item];
			Item.parent = beforeItem.parent;
			
			children = Item.parent.children;
			int beforeIndex = [children indexOfObject:beforeItem];
			if(beforeIndex == NSNotFound || beforeIndex<0)
			{
				[children addObject:Item];
			}
			else
			{
				[children insertObject:Item atIndex:beforeIndex];
			}
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GL Object Added" object:nil];
	}
	[lock unlock];
	
	[lock lock];
	[self Save];
	[lock unlock];
}

- (NSString*)FormattedKeyPathForKeyPath:(NSString*)key
{
	if(![key hasPrefix:@"/"]) key = [NSString stringWithFormat:@"/%@",key];
	if(key.length>1 && [key hasSuffix:@"/"])
	{
		key = [key substringToIndex:key.length-1];
	}
	return key;
}
- (TreeListItem*)ItemCreatingIfNessisaryWithObject:(id)object ForKey:(NSString*)key ItemWasCreated:(BOOL*)CreatedANew
{
	key = [self FormattedKeyPathForKeyPath:key];
	TreeListItem*Item = [Objects valueForKey:key];
	if(Item)
	{
		Item.object = object;
		return Item;
	}
	else
	{
		if(key.length == 0 || [key isEqualToString:@"/"])
		{
			return root;
		}
		else
		{
			TreeListItem*Parent = [self ItemCreatingIfNessisaryWithObject:nil ForKey:[key stringByDeletingLastPathComponent] ItemWasCreated:CreatedANew];
			Item = [[TreeListItem alloc] initWithObject:object KeyPath:key Parent:Parent];
			Item.Holder = self;
			[Objects setValue:Item forKey:key];
			[Parent.children addObject:Item];
			if(CreatedANew!=NULL) *CreatedANew = true;
			return [Item autorelease];
		}
	}
}

- (bool)PossibleToMoveItem:(TreeListItem*)Item ToParent:(TreeListItem*)parent AtIndex:(int)index
{
	bool possibleToMove = false;
	[lock lock];
	if(Item && parent && index<=parent.children.count)
	{
		possibleToMove = true;
	}
	[lock unlock];
	return possibleToMove;
}
- (void)MoveItem:(TreeListItem*)Item ToParent:(TreeListItem*)parent AtIndex:(int)index /*It is assumed that you checked "- (bool)PossibleToMoveObject:(TreeListItem*)object ToParent:(TreeListItem*)parent AtIndex:(int)index" first, if you did not, not my problem.*/
{
	[lock lockForWriting];
	[Item.parent.children removeObject:Item];
	[parent.children insertObject:Item atIndex:index];
	Item.parent = parent;
	[lock unlock];
	
	[lock lock];
	[self Save];
	[lock unlock];
}

- (void)InternalRemoveItem:(TreeListItem*)Item Recursively:(BOOL)recursively
{
	if(recursively)
	{
		for(TreeListItem*child in Item.children)
		{
			[self InternalRemoveItem:child Recursively:YES];
		}
	}
	else
	{
		int index = [Item.parent.children indexOfObject:Item];
		int length = Item.children.count;
		for(TreeListItem*child in Item.children)
		{
			child.parent = Item.parent;
		}
		[Item.parent.children insertObjects:Item.children atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, length)]];
	}
	
	[Item.parent.children removeObject:Item];
	[Objects removeObjectForKey:Item.keyPath];
}

- (void)RemoveItem:(TreeListItem*)Item Recursively:(BOOL)recursively
{
	[lock lockForWriting];
	[self InternalRemoveItem:Item Recursively:recursively];
	[lock unlock];
	
	[lock lock];
	[self Save];
	[lock unlock];
}
- (void)RemoveListItemForKeyPath:(NSString*)key Recursively:(BOOL)recursively
{
	key = [self FormattedKeyPathForKeyPath:key];
	
	[lock lockForWriting];
	TreeListItem*Item = [Objects valueForKey:key];
	if(Item)
	{
		[self InternalRemoveItem:Item Recursively:recursively];
	}
	[lock unlock];
	
	[lock lock];
	[self Save];
	[lock unlock];
}

- (void)RemoveAll
{
	[lock lockForWriting];
	for(TreeListItem*child in root.children)
	{
		[self InternalRemoveItem:child Recursively:YES];
	}
	[lock unlock];
	
	[lock lock];
	[self Save];
	[lock unlock];
}

- (void)InternalClearItem:(TreeListItem*)Item Recursively:(BOOL)recursively
{
	if(recursively)
	{
		for(TreeListItem*child in Item.children)
		{
			[self InternalClearItem:child Recursively:YES];
		}
	}
	
	if(Item!=root) Item.object = nil;
}
- (void)ClearItem:(TreeListItem*)Item Recursively:(BOOL)recursively
{
	[lock lockForWriting];
	[self InternalClearItem:Item Recursively:recursively];
	[lock unlock];
}
- (void)ClearItemForKeyPath:(NSString*)key Recursively:(BOOL)recursively
{
	key = [self FormattedKeyPathForKeyPath:key];
	
	[lock lockForWriting];
	TreeListItem*Item = [Objects valueForKey:key];
	if(Item)
	{
		[self InternalClearItem:Item Recursively:recursively];
	}
	[lock unlock];
}

- (void)ClearAll
{
	[lock lockForWriting];
	[self InternalClearItem:root Recursively:YES];
	[lock unlock];
}

- (NSString*)descriptionOfItem:(TreeListItem*)Item AppendingToDescription:(NSString*)description AtLevel:(int)level
{
	NSString*indentation = [@"" stringByPaddingToLength:level * @"\t".length withString:@"\t" startingAtIndex:0];
	if(Item.children.count>0)
	{
		description = [NSString stringWithFormat:@"%@\n%@<Name:\"%@\">  <Key:\"%@\">",description,indentation,Item.name,Item.keyPath];
		
		description = [NSString stringWithFormat:@"%@\n%@{",description,indentation];
		for(int i=0; i<Item.children.count; i++)
		{
			description = [self descriptionOfItem:[Item.children objectAtIndex:i] AppendingToDescription:description AtLevel:level+1];
		}
		description = [NSString stringWithFormat:@"%@\n%@}",description,indentation];
	}
	else
	{
		description = [NSString stringWithFormat:@"%@\n%@<Name:\"%@\">  <Key:\"%@\">",description,indentation,Item.name,Item.keyPath];
	}
	return description;
}
- (NSString*)description
{
	[lock lock];
	NSString*description = [self descriptionOfItem:root AppendingToDescription:@"" AtLevel:0];
	[lock unlock];
	return description;
}

- (void)dealloc
{
	[root release];
	[Objects release];
	[lock release];
	[super dealloc];
}
@end
