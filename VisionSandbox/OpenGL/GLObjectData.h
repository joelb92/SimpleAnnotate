//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayListArr.h"

@interface GLObjectData : NSObject
{
	DisplayList*mainDisplayList;
	DisplayListArr*displayLists;
	
	bool ObjectChanged;
	bool DisplayListBeingCreated;
	
	bool mainListMustReCompile;
	bool AppendingExistingDisplayList;
	
	//For Images
	GLuint gl;
	bool glSet;
}
- (void)ClearDisplayList;

@property (readwrite) DisplayList*mainDisplayList;
@property (retain) DisplayListArr*displayLists;
@property (readwrite) bool ObjectChanged;
@property (readwrite) bool DisplayListBeingCreated;

@property (readwrite) bool mainListMustReCompile;
@property (readwrite) bool AppendingExistingDisplayList;

@property (readwrite) GLuint gl;
@property (readwrite) GLuint*glAddress;
@property (readwrite) bool glSet;

- (void)deallocImage;
@end
