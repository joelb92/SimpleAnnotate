//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GLViewList.h"
#import "OpenImageHandler.h"
@interface GLOutlineViewController : NSOutlineView
{
	GLViewList*viewList;
	BOOL ShouldReloadData;
//	BOOL mouseWasDragged;
}
@property (readwrite, atomic) BOOL ShouldReloadData;

- (GLViewList*)viewList;
- (void)setViewList:(GLViewList*)vL;
@end
