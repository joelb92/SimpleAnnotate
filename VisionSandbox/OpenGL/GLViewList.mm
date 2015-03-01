//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLViewList.h"
#import "GLOutlineViewController.h"

@implementation GLViewList
- (BOOL)ViewReloadingData
{
	[lock lock];
	BOOL val = ViewReloadingData;
	[lock unlock];
	return val;
}
- (void)setViewReloadingData:(BOOL)val
{
	[lock lockForWriting];
	ViewReloadingData = val;
	[lock unlock];
}

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
	}
	return self;
}

- (id)initWithBackupPath:(NSString*)backupPath
{
	self = [super initWithBackupPath:backupPath];
	if(self)
	{
		Views = [[NSMutableDictionary alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:GL_AddGLViewNofification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:GL_AddGLObjectToGLViewNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:GL_ChangeMaxImageRectOfGLViewNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:GL_ResetGLViewNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:GL_ClearGLViewNotification object:nil];
		
		[NSThread detachNewThreadSelector:@selector(startIdle) toTarget:self withObject:nil];
	}
	return self;
}
- (void)Save
{
	[super Save];
	for(GLView*view in Views.allValues)
	{
		[view SaveObjectList];
	}
}
- (void)startIdle
{
	@autoreleasepool
	{
		float trigger = 1.0f / 30.0f;
		NSTimer*pTimer = [NSTimer timerWithTimeInterval:trigger target:self selector:@selector(idle:) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:pTimer forMode:NSDefaultRunLoopMode];
		[[NSRunLoop currentRunLoop] run];
		[pTimer release];
	}
}
- (void)idle:(NSTimer*)pTimer
{
	@autoreleasepool
	{
		if(![[NSApplication sharedApplication] isHidden])
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self Draw];
			});
		}
	}
}

- (void)Draw
{
	@autoreleasepool
	{
		[lock lock];
		[self DrawChildrenOfItem:root];
		[lock unlock];
	}
}
- (void)DrawChildrenOfItem:(TreeListItem*)Item
{
	@autoreleasepool
	{
		for(TreeListItem*child in Item.children)
		{
			if(child.Enabled)
			{
				id object = child.object;
				[self DrawChildrenOfItem:child];
				
				if([object isKindOfClass:GLView.class])
				{
					GLView*view = object;
					[view Draw];
				}
			}
		}
	}
}
- (void)SaveRendersAtPath:(NSString*)path WithNamePrefix:(NSString*)namePrefix
{
	[lock lock];
	[self SaveRendersUnderParent:root At:path NamePrefix:namePrefix];
	[lock unlock];
}
- (void)SaveRendersUnderParent:(TreeListItem*)parent At:(NSString*)path NamePrefix:(NSString*)namePrefix
{
	@autoreleasepool
	{
		for(TreeListItem*child in parent.children)
		{
			if(child.Enabled)
			{
				id obj = [child.object retain];
				[self SaveRendersUnderParent:child At:[path stringByAppendingPathComponent:child.name] NamePrefix:namePrefix];
				if([obj isKindOfClass:GLView.class])
				{
					[((GLView*)obj) SaveRenderToPath:[NSString stringWithFormat:@"%@/%@ (%@).JPG",path,namePrefix,child.name]];
				}
				[obj release];
			}
		}
	}
}

- (void)AddObject:(id)object ForKeyPath:(NSString*)key
{
	key = [self FormattedKeyPathForKeyPath:key];
	
	[lock lockForWriting];
	if(object && [object isKindOfClass:GLView.class]) [Views setValue:object forKey:key];
	BOOL ItemCreated = NO;
	[self ItemCreatingIfNessisaryWithObject:object ForKey:key ItemWasCreated:&ItemCreated];
	if(ItemCreated)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GL Object Added" object:nil];
	}
	[lock unlock];
	
	[lock lock];
	if(ItemCreated) [self Save];
	[lock unlock];
}
- (void)AddObject:(id)object ForKeyPath:(NSString*)key AfterKeyPath:(NSString*)afterKey
{
	afterKey = [self FormattedKeyPathForKeyPath:afterKey];
	
	[lock lockForWriting];
	BOOL ItemCreated = NO;
	if(object && [object isKindOfClass:GLView.class]) [Views setValue:object forKey:key];
	
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
			if(afterIndex == NSNotFound)
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
	if(ItemCreated) [self Save];
	[lock unlock];
}
- (void)AddObject:(id)object ForKeyPath:(NSString*)key BeforeKeyPath:(NSString*)beforeKey
{
	beforeKey = [self FormattedKeyPathForKeyPath:beforeKey];
	
	[lock lockForWriting];
	BOOL ItemCreated = NO;
	if(object && [object isKindOfClass:GLView.class]) [Views setValue:object forKey:key];
	
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
			if(beforeIndex == NSNotFound)
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
	if(ItemCreated) [self Save];
	[lock unlock];
}
- (TreeListItem*)ItemCreatingIfNessisaryWithObject:(id)object ForKey:(NSString*)key ItemWasCreated:(BOOL*)CreatedANew
{
	key = [self FormattedKeyPathForKeyPath:key];
	TreeListItem*Item = [Objects valueForKey:key];
	if(Item)
	{
		if(object!=nil) Item.object = object;
		if(object && [object isKindOfClass:GLView.class])
		{
			TreeListItem*Parent = Item.parent;
			[Parent.children removeObject:Item];
			
			GLView*view = object;
			Item = [[view.objectList.root retain] autorelease];
			[Item setObject:object];
			Item.parent = Parent;
			Item.Holder = self;
			[Parent.children addObject:Item];
			[Objects setValue:Item forKey:key];
		}
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
			if(object && [object isKindOfClass:GLView.class])
			{
				GLView*view = object;
				Item = [view.objectList.root retain];
				Item.keyPath = key;
				Item.name = [key lastPathComponent];
				[Item setObject:object];
				Item.parent = Parent;
				Item.Holder = self;
			}
			else
			{
				Item = [[TreeListItem alloc] initWithObject:object KeyPath:key Parent:Parent];
				Item.Holder = self;
			}
			[Objects setValue:Item forKey:key];
			[Parent.children addObject:Item];
			if(CreatedANew!=NULL) *CreatedANew = true;
			return [Item autorelease];
		}
	}
}
- (void)receiveNotification:(NSNotification*)notification
{
	if(![[NSThread currentThread] isMainThread])
	{
		NSInvocationOperation*opp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(receiveNotification:) object:notification];
		[[NSOperationQueue mainQueue] addOperation:opp];
		[opp release];
		return;
	}
	if([notification.name isEqualToString:GL_AddGLViewNofification])
	{
		AddViewCommand*command = notification.object;
		command.keyPath = [self FormattedKeyPathForKeyPath:command.keyPath];
		command.otherKeyPath = [self FormattedKeyPathForKeyPath:command.otherKeyPath];
		switch(command.place)
		{
			case Before:
				[self AddObject:command.view ForKeyPath:command.keyPath BeforeKeyPath:command.otherKeyPath];
				break;
			case After:
				[self AddObject:command.view ForKeyPath:command.keyPath AfterKeyPath:command.otherKeyPath];
				break;
			case WhereEver:
				[self AddObject:command.view ForKeyPath:command.keyPath];
				break;
		}
	}
	else if([notification.name isEqualToString:GL_AddGLObjectToGLViewNotification])
	{
		AddObjectCommand*command = notification.object;
		command.viewKeyPath = [self FormattedKeyPathForKeyPath:command.viewKeyPath];
		
		[lock lockForWriting];
	
		TreeListItem*viewListItem = [Objects valueForKey:command.viewKeyPath];
		if(viewListItem)
		{
			id object = viewListItem.object;
			if(object && [object isKindOfClass:GLView.class])
			{
				GLView*view = object;
				command.keyPath = [self FormattedKeyPathForKeyPath:command.keyPath];
				command.otherKeyPath = [self FormattedKeyPathForKeyPath:command.otherKeyPath];
				switch(command.place)
				{
					case Before:
						[view.objectList AddObject:command.object ForKeyPath:command.keyPath BeforeKeyPath:command.otherKeyPath];
						break;
					case After:
						[view.objectList AddObject:command.object ForKeyPath:command.keyPath AfterKeyPath:command.otherKeyPath];
						break;
					case WhereEver:
						[view.objectList AddObject:command.object ForKeyPath:command.keyPath];
						break;
				}
			}
		}
		[lock unlock];
	}
	else if([notification.name isEqualToString:GL_ChangeMaxImageRectOfGLViewNotification])
	{
		SetMaxImageSpaceCommand*command = notification.object;
		command.viewKeyPath = [self FormattedKeyPathForKeyPath:command.viewKeyPath];
		
		[lock lockForWriting];
		TreeListItem*viewListItem = [Objects objectForKey:command.viewKeyPath];
		if(viewListItem)
		{
			id obj = viewListItem.object;
			if(obj && [obj isKindOfClass:GL2DView.class])
			{
				GL2DView*view = obj;
				[view setMaxImageSpaceRect:command.imageRect];
			}
		}
		[lock unlock];
	}
	else if([notification.name isEqualToString:GL_ResetGLViewNotification])
	{
		NSString*key = [self FormattedKeyPathForKeyPath:notification.object];
		
		[lock lockForWriting];
		TreeListItem*viewListItem = [Objects objectForKey:key];
		if(viewListItem)
		{
			id obj = viewListItem.object;
			if(obj && [obj isKindOfClass:GLView.class])
			{
				GLView*view = obj;
				[view Reset];
			}
		}
		[lock unlock];
	}
	else if([notification.name isEqualToString:GL_ClearGLViewNotification])
	{
		NSString*key = [self FormattedKeyPathForKeyPath:notification.object];
		
		[lock lockForWriting];
		TreeListItem*viewListItem = [Objects objectForKey:key];
		if(viewListItem)
		{
			id obj = viewListItem.object;
			if(obj && [obj isKindOfClass:GLView.class])
			{
				GLView*view = obj;
				[view Clear];
			}
		}
		[lock unlock];
	}
	[(GLOutlineViewController*)theOutlineView setShouldReloadData:YES];
}

- (NSInteger)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
	theOutlineView = outlineView;
	
	[lock lock];
	TreeListItem*Item = item;
	if(Item == nil) Item = root;
	NSInteger count = Item.children.count;
	[lock unlock];
	return count;
}
- (id)outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item
{
	theOutlineView = outlineView;
	
	if(index>=0)
	{
		[lock lock];
		TreeListItem*Item = item;
		if(Item == nil) Item = root;
		TreeListItem*child = [[[Item.children objectAtIndex:index] retain] autorelease];
		[lock unlock];
		return child;
	}
	return nil;
}
- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
	theOutlineView = outlineView;
	
	[lock lock];
	TreeListItem*Item = item;
	if(Item == nil) Item = root;
	BOOL expandable = Item.children.count>0;
	[lock unlock];
	return expandable;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	theOutlineView = outlineView;
	
	[lock lock];
	TreeListItem*Item = item;
	if(Item == nil) Item = root;
	BOOL groupItem = !Item.HasObject;
	if(!groupItem && [Item.object isKindOfClass:GLView.class])
	{
		groupItem = YES;
	}
	[lock unlock];
	return groupItem;
}
//- (id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
//{
//	
//}
- (void)outlineView:(NSOutlineView*)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
{
	theOutlineView = outlineView;
	
	[lock lockForWriting];
	TreeListItem*Item = item;
	if(Item == nil) Item = root;
	
	Item.Enabled = [object boolValue];
	if(Item.Enabled) [outlineView expandItem:Item];
	else [outlineView collapseItem:Item];
	[lock unlock];
	
	[lock lock];
	[self Save];
	[lock unlock];
}
- (NSView*)outlineView:(NSOutlineView*)outlineView viewForTableColumn:(NSTableColumn*)tableColumn item:(id)item
{
	theOutlineView = outlineView;
	
	[lock lock];
	TreeListItem*Item = item;
	if(Item == nil) Item = root;
	id object = Item.object;
	
	// Everything is setup in bindings
	SingleViewCellView*view = nil;
	if(!Item.HasObject)
	{
		view = [outlineView makeViewWithIdentifier:@"GroupItemCell" owner:self];
	}
	else if([object isKindOfClass:GLView.class])
	{
		view = [outlineView makeViewWithIdentifier:@"GLViewCell" owner:self];
	}
	else
	{
		view = [outlineView makeViewWithIdentifier:@"GLObjectCell" owner:self];
	}
	[((NSButton*)view.view) setState:Item.Enabled ? NSOnState : NSOffState];
	[lock unlock];
	return view;
}
- (NSTableRowView*)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
	NSTableRowView*rowView = [[NSTableRowView alloc] init];
	[lock lock];
	TreeListItem*Item = item;
	if(Item == nil) Item = root;
	if(Item.HasObject)
	{
		id object = Item.object;
		if(object && [object isKindOfClass:GLView.class])
		{
			[rowView setBackgroundColor:[NSColor colorWithCalibratedRed:0 green:0 blue:1 alpha:1]];
		}
	}
	[lock unlock];
	return [rowView autorelease];
}
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
	if([self ViewReloadingData])
	{
		[lock lock];
		TreeListItem*Item = item;
		BOOL expanded = Item.Expanded;
		[lock unlock];
		return expanded;
	}
	else
	{
		[lock lockForWriting];
		TreeListItem*Item = item;
		Item.Expanded = YES;
		[lock unlock];
		
		[lock lock];
		[self Save];
		[lock unlock];
		return YES;
	}
}
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
	[lock lockForWriting];
	TreeListItem*Item = item;
	Item.Expanded = NO;
	[lock unlock];
	
	[lock lock];
	[self Save];
	[lock unlock];
	return YES;
}
- (CGFloat)outlineView:(NSOutlineView*)outlineView heightOfRowByItem:(id)item
{
	theOutlineView = outlineView;
	
	[lock lock];
	TreeListItem*Item = item;
	if(Item == nil) Item = root;
	id object = Item.object;
	
	CGFloat height = 17;
	if([object isKindOfClass:GLView.class]) //GLView
	{
		height = 40;
	}
	else if(!Item.HasObject) //Group Item
	{
		height = 25;
	}
	[lock unlock];
	
	return height;
}


//Get Values for Column at item
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	theOutlineView = outlineView;
	
	return item;
}

- (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item
{
	theOutlineView = outlineView;
	
	return (id <NSPasteboardWriting>)item;
}

- (void)outlineView:(NSOutlineView*)outlineView draggingSession:(NSDraggingSession*)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray*)draggedItems
{
	theOutlineView = outlineView;
	
	[_itemsBeingDragged release];
	_itemsBeingDragged = nil;
	
	// If only one item is being dragged, mark it so we can reorder it with a special pboard indicator
	if(draggedItems.count == 1)
	{
		_itemsBeingDragged = [draggedItems retain];
	}
}

//Used to check what to do with a drag opperation
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)propsedParentItem proposedChildIndex:(NSInteger)index
{
	theOutlineView = outlineView;
	
	for(TreeListItem*itemBeingDragged in _itemsBeingDragged)
	{
		//Don't Drag Non GLView Objects Outside a View:
		if(itemBeingDragged.HasObject && (!itemBeingDragged.object || (itemBeingDragged.object && ![itemBeingDragged.object isKindOfClass:GLView.class])) )
		{
			BOOL InAGLView = NO;
			TreeListItem*AAncestor = propsedParentItem;
			while(AAncestor)
			{
				if(AAncestor.object && [AAncestor.object isKindOfClass:GLView.class])
				{
					InAGLView = true;
				}
				AAncestor = AAncestor.parent;
			}
			if(!InAGLView) return NSDragOperationNone;
		}
		
		if([TreeListItem Item:itemBeingDragged IsAAncestorOfItem:propsedParentItem]) // Don't Drag Onto Self
		{
			return NSDragOperationNone;
		}
	}
	return NSDragOperationMove;
}
//Used when moving Items being dragged are dropped
- (void)_performDragReorderWithDragInfo:(id <NSDraggingInfo>)info parentItem:(TreeListItem*)newParent childIndex:(NSInteger)childIndex
{
	//[lock lockForWriting];
	//Get Destinations Parent View:
	for(TreeListItem*itemBeingDragged in _itemsBeingDragged)
	{
		if(itemBeingDragged != newParent)
		{
			TreeListItem*oldParent = itemBeingDragged.parent;
			int moveToIndex = childIndex;
			int currentIndex = [itemBeingDragged.parent.children indexOfObject:itemBeingDragged];
			if(newParent==itemBeingDragged.parent)
			{
				if(currentIndex<moveToIndex)
				{
					moveToIndex--;
				}
			}
			
			if(oldParent.Holder != newParent.Holder)
			{
				[newParent.Holder.Objects setValue:itemBeingDragged forKey:itemBeingDragged.keyPath];
				[oldParent.Holder.Objects removeObjectForKey:itemBeingDragged.keyPath];
				itemBeingDragged.holder = newParent.Holder;
			}
			[oldParent.children removeObject:itemBeingDragged];
			[newParent.children insertObject:itemBeingDragged atIndex:moveToIndex];
			itemBeingDragged.parent = newParent;
			[theOutlineView moveItemAtIndex:currentIndex inParent:[theOutlineView parentForItem:itemBeingDragged] toIndex:moveToIndex inParent:newParent];
			[theOutlineView reloadItem:newParent];
			[theOutlineView reloadItem:oldParent];
			[theOutlineView expandItem:newParent];
			newParent.Expanded = YES;
		}
	}
	//[lock unlock];
}
//Checks to see if items can be dropped in proposed location
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(TreeListItem*)item childIndex:(NSInteger)childIndex
{
	[lock lockForWriting];
	TreeListItem*Item = item;
	if(Item == nil) Item = root;
	
	// If it was a drop "on", then we add it at the start
	if (childIndex == NSOutlineViewDropOnItemIndex)
	{
		childIndex = 0;
	}
	
	[outlineView beginUpdates];
	// Are we copying the data or moving something?
	if(_itemsBeingDragged == nil || _itemsBeingDragged.count == 0 || [info draggingSourceOperationMask] == NSDragOperationCopy)
	{
		// Yes, this is an insert from the pasteboard (even if it is a copy of _itemsBeingDragged)
		//[self _performInsertWithDragInfo:info parentItem:Item childIndex:childIndex];
	}
	else
	{
		[self _performDragReorderWithDragInfo:info parentItem:Item childIndex:childIndex];
	}
	[outlineView endUpdates];
	
	[_itemsBeingDragged release];
	_itemsBeingDragged = nil;
	[lock unlock];
	
	[lock lock];
	[self Save];
	[lock unlock];
	
	return YES;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GL_AddGLViewNofification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GL_AddGLObjectToGLViewNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GL_ChangeMaxImageRectOfGLViewNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GL_ResetGLViewNotification object:nil];
	[super dealloc];
}
@end
