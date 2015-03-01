//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "GLObject.h"

@implementation GLObject
@synthesize color;
@synthesize parentViewReleaseArray;

- (double)zForLayer:(int)layer OfLayers:(int)layers
{
	//Pass what layer you want to know the z axis of, how many layers in total that
	//you have, and an appropriate z hight will be returned. It is recommended that
	//you store this value at the beginning of each layer draw.
	//
	//Note: 'layer' should start at 0.
	//
	//If you wish to draw on only one layer, this function is unnessisary, simply
	//draw on 'minZ' (NOT 'maxZ').
	return ((double)layer) * (maxZ-minZ)/((double)(layers+1));
}
- (id)init
{
	self = [super init];
	if(self)
	{
		minZ = 0;
		maxZ = 1;
		data = [[GLObjectData alloc] init];
		lock = [[ReadWriteLock alloc] init];
		spaceConverterUsedByDisplayList = SpaceConverter();
	}
	return self;
}
- (void)ObjectChanged
{
	//Call this method any time you want to change what is being graphed (if you are using
	//"- (bool)BeginGraphingUsingSpaceConverter:(SpaceConverter*)spaceConverter" & "- (void)EndGraphing"
	// in your draw method) to tell the object to refresh the display list.
	//
	//Try not to call it too frequenly as the display list methods can only help if they are used in moderation.
	
	data.ObjectChanged = true;
//	timespec wait;
//	wait.tv_sec = 0;
//	wait.tv_nsec = 5000000;
//	nanosleep(&wait,NULL);
}

- (NSString*)MouseOverInfoAtScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	return nil;
}
- (Vector3)MouseOverPointForScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	return Vector3(NAN,NAN,NAN);
}
- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	//Overide this method for graphing purposes. If you do not modify your subclassed object often then
	//call "- (bool)BeginGraphingUsingSpaceConverter:(SpaceConverter*)spaceConverter" in the begining of your
	//overriden method, this will enable the use of display lists which will tramendously speed the graphing.
	//If true is returned, do your graphing code, if not, do nothing. At the end of the overriden method,
	//don't forget to call "- (void)EndGraphing" to compile, and call any display lists that were being created.
	//
	//Use the 'spaceConverter' to get the x,y cordinates of any vertex you draw (you need to be in 'Camera Space'
	//for drawing so choose the proper convershion method).
	//
	//You can have multiple layers within an object (if you have depth testing enabled in the current OpenGLContext || OpenGLView),
	//just be sure to stay between 'minZ' and maxZ such that minZ <= Z < maxZ, in order to allow the GLObjectList this object may be in
	//to control render order. FYI if you draw on maxZ, weird things could happen if this object is in a GLObjectList!
	//
	//Note: Never call this method on your own unless you know what your doing, it was only designed to be called
	//from an OpenGLView. None of the graphing methods are thread safe either, they should only be called from the main thread.
	//
	//Also, check 'Enabled' before actually doing any thing (incase the user disabled graphing of this object, or you did in code).
}

- (void)TryToPreventStupid
{
	NSAssert(!data.AppendingExistingDisplayList || !data.DisplayListBeingCreated, @"End graphing not called after begin graphing using space converter!");
}
- (bool)BeginGraphingUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	//Call this at the begining of your graphing function to begin the creation of a display list.
	//This will greatly speed up graph time for all subsequent draw calls, presuming you do not
	//frequently call "- (void)ObjectChanged". If you need to add onto your object, look into
	//
	//If true is returned, do your graphing code as you would normally, if false, do nothing.
	//
	//At the end of the graphing method (if you had called this method) always call "- (void)EndGraphing".
	
	[self TryToPreventStupid];
	
	if(data.ObjectChanged)
	{
		[data ClearDisplayList];
	}
	else if(data.mainListMustReCompile)
	{
		[self CompileMainListFromLists];
	}
	
	if(data.mainDisplayList->CanDraw())
	{
		data.mainDisplayList->DrawList();
		return false;
	}
	else
	{
		[data ClearDisplayList];
		
		DisplayList*list = new DisplayList;
		list->BeginCreatingList();
		[data.displayLists addElement:list];
		data.DisplayListBeingCreated = true;
		
		return true;
	}
}
- (void)CompileMainListFromLists
{
	data.mainDisplayList->release();
	data.mainDisplayList->BeginCreatingList();
	for(int i=0; i<data.displayLists.Length; i++)
	{
		[data.displayLists elementAtIndex:i]->DrawList();
	}
	data.mainDisplayList->EndCreatingList();
	data.mainListMustReCompile = false;
}
- (void)EndGraphing
{
	//Make sure to call this at the end of your draw method if you've called
	//"- (bool)BeginGraphingUsingSpaceConverter:(SpaceConverter*)spaceConverter".
	if(data.DisplayListBeingCreated)
	{
		data.DisplayListBeingCreated = false;
		int lastIndex = data.displayLists.Length-1;
		[data.displayLists elementAtIndex:lastIndex]->EndCreatingList();
		
		[self CompileMainListFromLists];
		data.mainDisplayList->DrawList();
	}
}

- (bool)BeginAppendingGraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	//Similar to "- (bool)BeginGraphingUsingSpaceConverter:(SpaceConverter*)spaceConverter"
	//but different in that it will alow you to add onto your display list, you must keep
	//track of what you have and have not already graphed, but it saves time in re-graphing
	//things. Simply call it at the begining of your graph method, do your graph code, and
	//call "- (void)EndAppending" when you are done.
	//
	//If a display list has not been previously created, one will be created automatically
	//so no other checks are nesisary, but if you do not need to append to your graph, use
	//"- (bool)BeginGraphingUsingSpaceConverter:(SpaceConverter*)spaceConverter" instead
	//because it will likely be a much faster.
	//
	//Note: you must still call "- (void)ObjectChanged" when you finish changing something
	//that you want to be graphed.
	//
	//Also, if you choose to use this method, it may also be wise to overide "- (void)ClearDisplayList"
	//So that if it gets called unexpectedly, or otherwise, you know to draw from scratch
	//and not just the portion you haven't drawn yet, just be sure to call "[super ClearDisplayList];"
	//in any of your overides to make sure it actually clears the list.
	//
	//And, if you choose to append, any previously drawn objects will be drawn first so, unless you
	//have depth testing enabled and are using 'minZ' and 'maxZ' as expected for your own layering, expect
	//that any thing you append with, will be drawn on-top of any thing drawn previously.
	//
	//False is returned when all of the graphing must be done again, if true, it is safe to append.
	
	[self TryToPreventStupid];
	
	DisplayList*list = new DisplayList;
	list->BeginCreatingList();
	[data.displayLists addElement:list];
	data.AppendingExistingDisplayList = true;
	
	return data.AppendingExistingDisplayList;
}

- (void)EndAppending
{
	//Make sure to call this at the end of your draw method if you've called
	//"- (bool)BeginAppendingGraphUsingSpaceConverter:(SpaceConverter*)spaceConverter".
	
	if(data.AppendingExistingDisplayList)
	{
		data.mainListMustReCompile = true;
		data.AppendingExistingDisplayList = false;
		[data.displayLists elementAtIndex:data.displayLists.Length-1]->EndCreatingList();
		
		for(int i=0; i<data.displayLists.Length; i++)
		{
			[data.displayLists elementAtIndex:i]->DrawList();
		}
	}
}

-(bool)ObjectHasChanged
{
	return data.ObjectChanged;
}

- (void)dealloc
{
	if(parentViewReleaseArray)
	{
		[parentViewReleaseArray addElement:data];
	}
	[data release];
	[parentViewReleaseArray release];
	[lock release];
	[super dealloc];
}
@end
