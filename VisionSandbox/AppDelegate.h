//
//  AppDelegate.h
//  VisionSandbox
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#include "opencv2/opencv.hpp"
#import <Cocoa/Cocoa.h>
#import "GLOutlineViewController.h"
#import "GL2DView.h"
#import "InfoOutputController.h"
@interface AppDelegate : NSObject <NSApplicationDelegate,NSTextFieldDelegate>
{
	IBOutlet GLOutlineViewController *mainGLOutlineView;
	IBOutlet GL2DView *mainGLView;
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSWindow *splashScreen;
    IBOutlet NSWindow *about;
    IBOutlet NSWindow *help;
    IBOutlet NSTextField *versionNumber;
	GLViewList *viewList;
	IBOutlet InfoOutputController *infoOutput;
	IBOutlet NSButton *playButton;
	OpenImageHandler *loadedImg;
	cv::VideoCapture capture;
	NSMutableArray *allFrames;
    NSMutableDictionary *frameForFrameNumber;
	NSMutableDictionary *rectsForFrames;
	IBOutlet NSButton *saveEmptyFrames;
	IBOutlet NSTextField *frameSkipField;
    IBOutlet NSTextField *frameJumpField;

	NSString *currentFilePath;
	int frameNum;
	int frameSkip;
	bool isPlaying;
}
@property (assign) IBOutlet NSWindow *window;

@end
