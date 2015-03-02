//
//  InfoOutputController.h
//  SimpleAnnotate
//
//  Created by Joel Brogan on 1/23/15.
//  Copyright (c) 2015 Magna Mirrors. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoOutputController : NSView
{
	IBOutlet NSTextField *frameNumLabel;
	IBOutlet NSTextField *trackNumberLabel;
	IBOutlet NSTextField *xCoordMouseLabel;
	IBOutlet NSTextField *yCoordMouseLabel;
	IBOutlet NSTextField *xCoordRectLabel;
	IBOutlet NSTextField *yCoordRectLabel;
	IBOutlet NSTextField *widthLabel;
	IBOutlet NSTextField *heightLabel;
    IBOutlet NSTextField *redLabel;
    IBOutlet NSTextField *greenLabel;
    IBOutlet NSTextField *blueLabel;
}

@property IBOutlet NSTextField *frameNumLabel;
@property IBOutlet NSTextField *trackNumberLabel;
@property IBOutlet NSTextField *xCoordMouseLabel;
@property IBOutlet NSTextField *yCoordMouseLabel;
@property IBOutlet NSTextField *xCoordRectLabel;
@property IBOutlet NSTextField *yCoordRectLabel;
@property IBOutlet NSTextField *widthLabel;
@property IBOutlet NSTextField *heightLabel;
@property IBOutlet NSTextField *redLabel;
@property IBOutlet NSTextField *greenLabel;
@property IBOutlet NSTextField *blueLabel;
@end
