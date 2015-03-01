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
	GLViewList *viewList;
	IBOutlet InfoOutputController *infoOutput;
	IBOutlet NSButton *playButton;
	OpenImageHandler *loadedImg;
	cv::VideoCapture capture;
	NSMutableArray *allFrames;
	NSMutableDictionary *rectsForFrames;
	IBOutlet NSButton *saveEmptyFrames;
	IBOutlet NSTextField *frameSkipField;
	NSString *currentFilePath;
	int frameNum;
	int frameSkip;
	bool isPlaying;
}
@property (assign) IBOutlet NSWindow *window;

@end
