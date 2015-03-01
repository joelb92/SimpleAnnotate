//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//
#import "GLObjectData.h"

@implementation GLObjectData
@synthesize mainDisplayList;
@synthesize displayLists;
@synthesize ObjectChanged;
@synthesize DisplayListBeingCreated;

@synthesize mainListMustReCompile;
@synthesize AppendingExistingDisplayList;

@synthesize gl;
@synthesize glSet;

- (GLuint*)glAddress
{
	return &gl;
}
- (void)setGlAddress:(GLuint*)add
{
	gl = *add;
}
- (id)init
{
	self = [super init];
	if(self)
	{
		ObjectChanged = false;
		mainDisplayList = new DisplayList;
		displayLists = [[DisplayListArr alloc] initWithCapacity:1];
	}
	return self;
}
- (void)ClearDisplayList
{
	@autoreleasepool
	{
		//Prefer calling "- (void)ObjectChanged" over this method directly as it will call this method only from the
		//main thread when it is drawing and not block both the current and the main thread.
		//
		//And if you are using the appending methods, this method could inedvertently cause the display list to be
		//cleared prematurly.
		
		if(mainDisplayList->created || (displayLists && displayLists.Length>0))
		{
			mainListMustReCompile = false;
			AppendingExistingDisplayList = false;
			DisplayListBeingCreated = false;
			
			ObjectChanged = false;
			mainDisplayList->release();
			[displayLists Reset];
		}
	}
}

- (void)deallocImage
{
	if(glSet)
	{
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, gl);
		glDeleteTextures(1,&gl);
		glDisable(GL_TEXTURE_2D);
		glSet = false;
	}
}
- (void)dealloc
{
	[self deallocImage];
	[self ClearDisplayList];
	[displayLists release];
	[super dealloc];
}
@end
