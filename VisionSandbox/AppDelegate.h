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
#import "CamShiftTracker.h"
#include "SemiBoostingApplication.h"
#import <AVFoundation/AVFoundation.h>
#include <dlib/image_processing.h>
#include <dlib/gui_widgets.h>
#include <dlib/image_io.h>
#include <dlib/dir_nav.h>
#include <dlib/opencv/cv_image.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <inttypes.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTextFieldDelegate>
{
	IBOutlet GLOutlineViewController *mainGLOutlineView;
	IBOutlet GL2DView *mainGLView;
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSWindow *splashScreen;
    IBOutlet NSWindow *about;
    IBOutlet NSWindow *help;
    IBOutlet NSWindow *fileFixerWindow;
    IBOutlet NSTextField *versionNumber;
    NSArray *acceptableImageTypes;
	GLViewList *viewList;
	IBOutlet InfoOutputController *infoOutput;
	IBOutlet NSButton *playButton;
	OpenImageHandler *loadedImg;
	cv::VideoCapture capture;
	NSMutableArray *allFrames;
    NSMutableDictionary *frameForFrameNumber;
    NSMutableDictionary *framePathForFrameNum;
	NSMutableDictionary *rectsForFrames;
	IBOutlet NSButton *saveEmptyFrames;
	IBOutlet NSTextField *frameSkipField;
    IBOutlet NSTextField *frameJumpField;
    IBOutlet NSTextField *savingStatusLabel;
    IBOutlet NSTextField *fixImageFolderField;
    IBOutlet NSTextField *fixCropFolderField;
    IBOutlet NSTextField *fixStatusLabel;
    bool videoMode;
    bool bruteFix;
	NSString *currentFilePath;
	int frameNum;
	int frameSkip;
	bool isPlaying;
    NSMutableArray *imagePathArray;
    NSMutableArray *usedImagePathArray;
    int foundMatches;
    std::vector<cv::Mat> sceneImages,templImages;
    NSIndexSet *matchedTemplates;
    NSIndexSet *matchedScenes;
    std::vector<bool> templatesFound,scenesFound;
    NSLock *lock;
    bool trackerStarted;
    NSMutableDictionary *trackers;
    int numFrames;
    
}
@property (assign) IBOutlet NSWindow *window;

@end
