//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "GLOutlineViewController.h"
#import "GL2DView.h"

@interface ImageListView : NSView
{
	GLOutlineViewController *mainGLOutlineView;
	GL2DView *mainGLView;
	NSString *name;
}
@end
