//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLOutlineViewController.h"

@implementation GLOutlineViewController
@synthesize ShouldReloadData;

- (GLViewList*)viewList
{
	return viewList;
}
- (void)setViewList:(GLViewList*)vL
{
	[vL retain];
	if(viewList)
	{
		[viewList release];
		viewList = nil;
	}
	viewList = vL;
	[self setDataSource:viewList];
	[self setDelegate:viewList];
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeString, nil]];
	[self setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
	[self reloadData];
}
- (id)init
{
	self = [super init];
	if (self)
	{
		viewList = nil;
	}
	return self;
}

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		viewList = nil;
	}
	return self;
}
- (void)awakeFromNib
{
	ShouldReloadData = false;
	[NSThread detachNewThreadSelector:@selector(startIdle) toTarget:self withObject:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(idle:) name:@"GL Object Added" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetInputImage) name:@"Input Image Requested" object:nil];
}
- (void)GetInputImage
{
	NSInteger selected = self.selectedRow;
	if(selected>=0)
	{
		TreeListItem*item = [self itemAtRow:self.selectedRow];
		
		if(item.object && [item.object isKindOfClass:OpenImageHandler.class])
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"Input Image Return" object:[[item.object retain] autorelease]];
			return;
		}
	}
	
	NSAlert*alert = [[NSAlert alloc] init];
	[alert setMessageText:@"No Image Selected!"];
	[alert setInformativeText:@"Please select an image and try again."];
	[alert addButtonWithTitle:@"Ok"];
	[alert runModal];
	[alert release];
}
- (void)startIdle
{
	@autoreleasepool
	{
		float trigger = 1.0f / 3.0f;
//		NSTimer*pTimer = [NSTimer timerWithTimeInterval:trigger target:self selector:@selector(idle:) userInfo:nil repeats:YES];
//		[[NSRunLoop currentRunLoop] addTimer:pTimer forMode:NSDefaultRunLoopMode];
//		[[NSRunLoop currentRunLoop] run];
//		[pTimer release];
	}
}
- (void)idle:(NSTimer*)pTimer
{
	@autoreleasepool
	{
		if(![[NSApplication sharedApplication] isHidden] && [self ShouldReloadData])
		{
			[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
		}
	}
}

- (void)objectDidEndEditing:(id)editor
{
	NSTableColumn * col = (NSTableColumn*)[self columnForView:editor];
	[viewList outlineView:self setObjectValue:[editor objectValue] forTableColumn:col byItem:[self itemAtRow:[self rowForView:editor]]];
}

//- (void)mouseDown:(NSEvent*)theEvent
//{
//	mouseWasDragged = NO;
//	[super mouseDown:theEvent];
//	
//	//Mouse Up is overriden by an event loop in NSOutlineView and would not be called here, once mouseDown completes, this will be run at the same time mouseUp would. mouseDragged is uneffected by this.
//	if(!mouseWasDragged)
//	{
//		[super mouseDown:theEvent];
//		
//		// Get the row on which the user clicked
//		NSPoint localPoint = [self convertPoint:theEvent.locationInWindow
//									   fromView:nil];
//		NSInteger row = [self rowAtPoint:localPoint];
//		
//		TreeListItem*Item = [self itemAtRow:row];
//		[viewList EnableItem:Item];
//		[self reloadData];
//		
//		[super mouseUp:theEvent];
//		//		// If the user didn't click on a row, we're done
//		//		if(row < 0)
//		//		{
//		//			return;
//		//		}
//		//
//		//		// Get the view clicked on
//		//		NSView*view = [self viewAtColumn:[self columnWithIdentifier:@"Value"] row:row makeIfNecessary:NO];
//		//		if(![self MakeChildrenOfView:view FirstResponderIfHitByPoint:theEvent.locationInWindow])
//		//		{
//		//			[[view window] makeFirstResponder:view];
//		//		}
//	}
//}
//- (void)mouseDragged:(NSEvent*)theEvent
//{
//	mouseWasDragged = YES;
//	[super mouseDragged:theEvent];
//}
//- (bool)MakeChildrenOfView:(NSView*)view FirstResponderIfHitByPoint:(NSPoint)point
//{
//	NSArray*children = [view subviews];
//	for(NSView*child in children)
//	{
//		NSRect aFrame = [child convertRect:[child bounds] toView:nil];
//		if(NSPointInRect(point, aFrame))
//		{
//			if([self MakeChildrenOfView:child FirstResponderIfHitByPoint:point])
//			{
//				return true;
//			}
//			if(![[child window] makeFirstResponder:child])
//			{
//				return false;
//			}
//			return true;
//		}
//	}
//	return false;
//}
- (void)reloadData
{
	@autoreleasepool
	{
		[viewList setViewReloadingData:YES];
		[super reloadData];
		[self expandItem:nil expandChildren:YES];
		[viewList setViewReloadingData:NO];
		ShouldReloadData = false;
	}
}
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"GL Command Posted!"];
	[viewList release];
	[super dealloc];
}
@end
