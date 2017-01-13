//
//  AppDelegate.h
//  VisionSandbox
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#include <opencv2/opencv.hpp>
#import <Cocoa/Cocoa.h>
#import "GLOutlineViewController.h"
#import "GL2DView.h"
#import "InfoOutputController.h"
#import "CamShiftTracker.h"
#import "FaceDetectionHandler.h"
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
#include "Tooltip.h"
#include "Landmarker_zhuramanan.h"
#include "Model3D.h"
#import <Quartz/Quartz.h>
#import "ImageAnnotationView.h"
struct phyloTreeNode
{
    NSString *ID;
    NSString *parentIDString;
    phyloTreeNode *parent;
    std::vector<phyloTreeNode *>childrenIDs;
    NSString *imageFileName;
    NSImage *theImage;
    cv::Point pointInSpace;
    int layer;
};

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTextFieldDelegate>
{
	IBOutlet GLOutlineViewController *mainGLOutlineView;
	IBOutlet GL2DView *mainGLView;
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSWindow *splashScreen;
    IBOutlet NSWindow *about;
    IBOutlet NSWindow *help;
    IBOutlet NSWindow *fileFixerWindow;
    IBOutlet NSWindow *extractChipsWindow;
    IBOutlet NSTextField *versionNumber;
	IBOutlet InfoOutputController *infoOutput;
	IBOutlet NSButton *playButton;
    IBOutlet NSButton *saveEmptyFrames;
	IBOutlet NSTextField *frameSkipField;
    IBOutlet NSTextField *frameJumpField;
    IBOutlet NSTextField *savingStatusLabel;
    IBOutlet NSTextField *fixImageFolderField;
    IBOutlet NSTextField *fixCropFolderField;
    IBOutlet NSTextField *fixStatusLabel;
    IBOutlet NSTextField *fileNameField;
    IBOutlet Tooltip *tooltip;
    IBOutlet NSMenuItem *forwardMenuBotton;
    IBOutlet NSMenuItem *backwardMenuBotton;
    
    IBOutlet NSButton *useCurrentProjectDataCheckbox;
    IBOutlet NSTextField *projectToExtractField;
    IBOutlet NSTextField *WhereToSaveChipsField;
    IBOutlet NSTextField *RotationRangeField;
    IBOutlet NSTextField *ProjectNameField;
    IBOutlet NSTextField *normalizedFaceSizeField;
    IBOutlet NSTextField *percentWidthSizeField;
    IBOutlet NSTextField *numImagesPerFaceField;

    IBOutlet NSButton *extractOnlyLandmarksChecdkbox;
    IBOutlet NSImageView *testView;
    IBOutlet ImageAnnotationView *testImageview;
    
    NSArray *acceptableImageTypes;
    GLViewList *viewList;
    cv::VideoCapture capture;
    NSMutableDictionary *frameForFrameNumber;
    NSMutableDictionary *framePathForFrameNum;
    NSMutableDictionary *annotationsForFrames;
    bool videoMode;
    bool bruteFix;
	NSString *currentFilePath;
	int frameNum;
	int frameSkip;
	bool isPlaying;
    NSMutableArray *imagePathArray;
    int foundMatches;
    std::vector<cv::Mat> sceneImages,templImages;
    std::vector<double> matchvals;
    std::vector<cv::Rect>matchLocs;
    NSIndexSet *matchedTemplates;
    NSIndexSet *matchedScenes;
    std::vector<bool> templatesFound,scenesFound;
    NSLock *lock;
    bool trackerStarted;
    NSMutableDictionary *trackers;
    NSMutableDictionary *isSubFaceImage;
    int numFrames;
    int cvNumFrames;
    NSString *saveProjectFilePath;
    NSString *saveProjectFileDir;
    bool separateFaces;
    bool hasSavePath;
    bool didCancelSave;
    bool justLoadedNewProject;
    FaceDetectionHandler *faceDetector;
    
}
@property (assign) IBOutlet NSWindow *window;

@end
