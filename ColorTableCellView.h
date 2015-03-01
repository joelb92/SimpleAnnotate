//
//  ColorTableCellView.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/13/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ColorTableCellView : NSTableCellView
{
	NSColor *backgroundColor;
}
@property (retain) NSColor*backgroundColor;
@end
