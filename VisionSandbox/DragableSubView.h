//
//  DragableSubView.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DragableSubView : NSView
{
	IBOutlet NSView*otherParentView;
	NSPoint startMousePos;
	NSPoint startViewPos;
	bool mouseStartedOnView;
	bool Dragging;
}
- (void)makeViewFitParentView;
@end
