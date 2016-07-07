//
//  AppDelegate.m
//  VisionSandbox
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//
#import "AppDelegate.h"

@implementation AppDelegate
using namespace cv;
using namespace std;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    lock = [[NSLock alloc] init ];
    
    [self splashSequence];
    lock = [[NSLock alloc] init];
    matchedScenes = [[NSMutableIndexSet alloc] init];
    trackers = [[NSMutableDictionary alloc] init];
    savingStatusLabel.stringValue = @"";
    matchedTemplates = [[NSMutableIndexSet alloc] init];
    annotationsForFrames = [[NSMutableDictionary alloc] init];
    frameForFrameNumber = [[NSMutableDictionary alloc] init];
    framePathForFrameNum = [[NSMutableDictionary alloc] init];
    viewList = [[GLViewList alloc] initWithBackupPath:@""];
    mainGLView.objectList = [[[GLObjectList alloc] initWithBackupPath:@""] autorelease];
    [viewList AddObject:mainGLView ForKeyPath:@"MainView"];
    mainGLOutlineView.viewList = viewList;
    [mainGLView.mouseOverController ToggleInView:mainGLView];
    frameNum = 0;
    frameSkip = 1;
    [frameSkipField setStringValue:@"1"];
    faceDetector = [[FaceDetectionHandler alloc] initWithShapePredictorFile:@"/Users/bog/SimpleAnnotate/shape_predictor_68_face_landmarks.dat"];
    [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,1000,1000)];
    acceptableImageTypes = @[[NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.bmp'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.ppm'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.gif'"]];
    NSLog(@"loaded");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleNextPrevActionConnection:) name:@"tooltipIsActive" object:nil];
}
-(void)toggleNextPrevActionConnection:(NSNotification *)obj
{
    //Allows user to use arrow keys within the tooltip while tooltip is on hover, instead of moving back and forth between images
    bool isOn = [(NSNumber *)obj.object boolValue];
    if (isOn) {
        [forwardMenuBotton setAction:nil];
        [backwardMenuBotton setAction:nil];
    }
    else{
        [forwardMenuBotton setAction:@selector(NextFrame:)];
        [backwardMenuBotton setAction:@selector(PrevFrame:)];
    }
}
-(IBAction)findFacesInCurrentFrame:(id)sender
{
    OpenImageHandler *currentImage =[frameForFrameNumber objectForKey:@(frameNum)];
    [faceDetector detectFacesInImage:currentImage atScale:0];
    [mainGLView.mouseOverController.rectangleTool setElements:faceDetector.faceRectDict];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setMessageText:[NSString stringWithFormat:@"%lu Faces have been detected.  Would you like to split them?",(unsigned long)faceDetector.faceRectDict.count]];
    [alert setInformativeText:@"This will allow you to work on each individual face separately"];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        //split the faces
        for(int i = 0; i < faceDetector.dets.size(); i++)
        {
            NSRect nsr = faceDetector.dets[i];
            cv::Rect r(nsr.origin.x,nsr.origin.y,nsr.size.width,nsr.size.height);
            cv::Mat face = currentImage.Cv(r).clone();
            OpenImageHandler *faceImage = [[OpenImageHandler alloc] initWithCVMat:face Color:Black BinaryImage:false];
            
        }
    }
    
    //    cv::imshow("test", [[frameForFrameNumber objectForKey:@(frameNum)] Cv]);
}

-(void)splashSequence
{
    [mainWindow orderOut:nil];
    [splashScreen setLevel: NSMainMenuWindowLevel];
    sleep(1.5);
    [splashScreen orderOut:nil];
    [mainWindow makeKeyAndOrderFront:nil];
}


-(IBAction)openAbout:(id)sender
{
    versionNumber.stringValue = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];;
    [about makeKeyAndOrderFront:nil];
}

-(IBAction)openHelp:(id)sender
{
    [help makeKeyAndOrderFront:nil];
}

-(IBAction)playPause:(id)sender
{
    if (isPlaying) {
        [playButton setStringValue:@"Play"];
        isPlaying = false;
    }
    else
    {
        [playButton setStringValue:@"Pause"];
        isPlaying = true;
        [NSThread detachNewThreadSelector:@selector(playLoop) toTarget:self withObject:nil];
    }
}

- (void)playLoop
{
    while (isPlaying) {
        [self NextFrame:nil];
    }
}

- (IBAction)PrevFrame:(id)sender {
    if (![self isTextFieldInFocus:tooltip.nameField]) {
    int newFrameNum = frameNum-frameSkip;
    
    if (!videoMode) newFrameNum = frameNum-1;
    [self GoToFrame:newFrameNum];
    }
}
- (IBAction)NextFrame:(id)sender
{
    if (![self isTextFieldInFocus:tooltip.nameField]) {
    int newFrameNum = frameNum+frameSkip;
    if (!videoMode) newFrameNum = frameNum+1;
    [self GoToFrame:newFrameNum];
    }
}

- (BOOL)isTextFieldInFocus:(NSTextField *)textField
{
    BOOL inFocus = NO;
    
    inFocus = ([[[textField window] firstResponder] isKindOfClass:[NSTextView class]]
               && [[textField window] fieldEditor:NO forObject:nil]!=nil
               && [textField isEqualTo:(id)[(NSTextView *)[[textField window] firstResponder]delegate]]);
    
    return inFocus;
}

-(bool)GoToFrame:(int)newFrameNum
{
    bool stillGood = false;
    if (newFrameNum >= 0) {
        
        if (![frameForFrameNumber.allKeys containsObject:@(newFrameNum)]){//we need to get the new frame
            if (videoMode) {
                double currentPos = capture.get(CV_CAP_PROP_POS_FRAMES);
                std::cout << "CV_CAP_PROP_POS_FRAMES = " << currentPos << std::endl;
                
                // position_slider 0 - 100
                double noFrame = newFrameNum;
                
                // solution 1
                //            bool success = capture.set(CV_CAP_PROP_POS_FRAMES, noFrame);
                // solution 2
                double frameRate = capture.get(CV_CAP_PROP_FPS);
                double frameTime = 1000.0 * noFrame / frameRate;
                bool success = capture.set(CV_CAP_PROP_POS_MSEC, frameTime);
                cv::Mat frame_aux;
                if (!success) {
                    std::cout << "Cannot set frame position from video file at " << noFrame << std::endl;
                    stillGood = false;
                }
                
                currentPos = capture.get(CV_CAP_PROP_POS_FRAMES);
                if (currentPos != noFrame) {
                }
                
                success = capture.read(frame_aux);
                if (!success) {
                    std::cout << "Cannot get frame from video file " << std::endl;
                    
                }
                
                cv::Mat frame = frame_aux;
                //                capture.set(CV_CAP_PROP_POS_FRAMES, newFrameNum);
                //                capture >> frame;
                cv::cvtColor(frame, frame, CV_BGR2BGRA);
                if (!frame.empty()) {
                    OpenImageHandler *img =[[OpenImageHandler alloc] initWithCVMat:frame Color:White BinaryImage:false];
                    [frameForFrameNumber setObject:img forKey:@(newFrameNum)];
                    NSMutableDictionary *annotations = [[NSMutableDictionary alloc] init];
                    for(NSString *k in mainGLView.mouseOverController.allTools.allKeys) [annotations setObject:[[mainGLView.mouseOverController.allTools objectForKey:k] getElements] forKey:k];
                    [annotationsForFrames setObject:annotations forKey:@(frameNum)];
                    
                    if ([[annotationsForFrames allKeys] containsObject:@(newFrameNum)]) {
                        NSDictionary *annDict = [annotationsForFrames objectForKey:@(newFrameNum)];
                        for (NSString *k in annDict.allKeys) {
                            [[mainGLView.mouseOverController.allTools objectForKey:k] setElements:[[annotationsForFrames objectForKey:@(newFrameNum)] objectForKey:k]];
                        }
                    }
                    else
                    {
                        for(GLViewTool *t in mainGLView.mouseOverController.allTools.allValues) [t clearAll];
                    }
                    [GLViewListCommand AddObject:[frameForFrameNumber objectForKey:@(newFrameNum)] ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
                    [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
                    
                    //                    [mainGLView.mouseOverController.rectangleTool setCurrentFrame:[(OpenImageHandler *)[frameForFrameNumber objectForKey:@(newFrameNum)] Cv]];
                    [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",newFrameNum,numFrames]];
                    
                    stillGood = true;
                }
            }
            else //We aren't in video mode
            {
                [fileNameField setStringValue:[[imagePathArray objectAtIndex:newFrameNum ] lastPathComponent]];

                cv::Mat frame;
                int i = newFrameNum;
                while(frame.empty() && i < imagePathArray.count)
                {
                    NSString *filePath =[imagePathArray objectAtIndex:i];
                    frame = cv::imread([filePath UTF8String]);
                    if(frame.empty()) NSLog(@"WARNING: Could not load image: %@",filePath.lastPathComponent);
                    i++;
                }
                if (!frame.empty()) {
                    OpenImageHandler *img =[[OpenImageHandler alloc] initWithCVMat:frame Color:White BinaryImage:false];
                    [framePathForFrameNum setObject:[imagePathArray objectAtIndex:i-1] forKey:@(newFrameNum)];
                    [frameForFrameNumber setObject:img forKey:@(newFrameNum)];
                    
                    NSMutableDictionary *annotations = [[NSMutableDictionary alloc] init];
                    for(NSString *k in mainGLView.mouseOverController.allTools.allKeys) [annotations setObject:[[mainGLView.mouseOverController.allTools objectForKey:k] getElements] forKey:k];
                    [annotationsForFrames setObject:annotations forKey:@(frameNum)];
                    
                    if ([[annotationsForFrames allKeys] containsObject:@(newFrameNum)]) {
                        NSDictionary *annDict = [annotationsForFrames objectForKey:@(newFrameNum)];
                        for (NSString *k in annDict.allKeys) {
                            [[mainGLView.mouseOverController.allTools objectForKey:k] setElements:[[annotationsForFrames objectForKey:@(newFrameNum)] objectForKey:k]];
                        }
                    }
                    else
                    {
                        for(GLViewTool *t in mainGLView.mouseOverController.allTools.allValues) [t clearAll];
                    }
                    [isSubFaceImage setObject:@(NO) forKey:@(newFrameNum)];
                    [GLViewListCommand AddObject:img ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
                    [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
                    
                    //                    [mainGLView.mouseOverController.rectangleTool setCurrentFrame:[(OpenImageHandler *)[frameForFrameNumber objectForKey:@(newFrameNum)] Cv]];
                    [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%li",newFrameNum+1,imagePathArray.count]];
                    
                    stillGood = true;
                }
                
            }
            
        }
        else //this frame already exists in our cached frame list
        {
            NSMutableDictionary *annotations = [[NSMutableDictionary alloc] init];
            for(NSString *k in mainGLView.mouseOverController.allTools.allKeys) [annotations setObject:[[mainGLView.mouseOverController.allTools objectForKey:k] getElements] forKey:k];
            [annotationsForFrames setObject:annotations forKey:@(frameNum)]; //save current rects for current frame
            
            if ([[annotationsForFrames allKeys] containsObject:@(newFrameNum)]) {
                NSDictionary *annDict = [annotationsForFrames objectForKey:@(newFrameNum)];
                for (NSString *k in annDict.allKeys) {
                    [[mainGLView.mouseOverController.allTools objectForKey:k] setElements:[[annotationsForFrames objectForKey:@(newFrameNum)] objectForKey:k]];
                } //load new rects for next frame
            }
            OpenImageHandler *img = [frameForFrameNumber objectForKey:@(newFrameNum)];
            [GLViewListCommand AddObject:img ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
            [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
            
            //            [mainGLView.mouseOverController.rectangleTool setCurrentFrame:[(OpenImageHandler *)[frameForFrameNumber objectForKey:@(newFrameNum)] Cv]];
            int finalVal =numFrames;
            int displayFrameNum = newFrameNum;
            if (!videoMode){
                finalVal = imagePathArray.count;
                [fileNameField setStringValue:[[imagePathArray objectAtIndex:newFrameNum ] lastPathComponent]];

                displayFrameNum = newFrameNum+1;
            }
            [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",displayFrameNum,finalVal]];
            stillGood = true;
        }
    }
    if (stillGood)
    {
        frameNum = newFrameNum;
        //        [self copyRectsFromLastNonEmptyFrame];
    }
    return stillGood;
}
-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    frameSkip = frameSkipField.stringValue.intValue;
    dispatch_async(dispatch_get_main_queue(), ^{[frameSkipField.window makeFirstResponder:nil];});
}

- (bool)loadNewFrame:(int)skipAmount
{
    if (videoMode) {
        if (capture.isOpened()) {
            cv::Mat frame;
            for(int i  = 0; i < skipAmount; i++)capture.grab();
            capture >> frame;
            if (!frame.empty() && frame.cols > 0 && frame.rows > 0) {
                cv::cvtColor(frame, frame, CV_BGR2BGRA);
                if (!frame.empty()) {
                    OpenImageHandler *img =[[OpenImageHandler alloc] initWithCVMat:frame Color:White BinaryImage:false];
                    [frameForFrameNumber setObject:img forKey:@(frameNum)];
                    //                [mainGLView.mouseOverController.rectangleTool setCurrentFrame:frame];
                    
                    return true;
                    
                }
            }
        }
        return false;
    }
    else
    {
        cv::Mat frame;
        int i = 0;
        while(frame.empty() && i < imagePathArray.count)
        {
            NSString *filePath =[imagePathArray objectAtIndex:i];
            frame = cv::imread([filePath UTF8String]);
            if(frame.empty()) NSLog(@"WARNING: Could not load image: %@",filePath.lastPathComponent);
            i++;
        }
        if (!frame.empty()) {
            OpenImageHandler *img =[[OpenImageHandler alloc] initWithCVMat:frame Color:White BinaryImage:false];
            [framePathForFrameNum setObject:[imagePathArray objectAtIndex:i-1] forKey:@(0)];
            [frameForFrameNumber setObject:img forKey:@(0)];
            [isSubFaceImage setObject:@(NO) forKey:@(0)];
            [fileNameField setStringValue:[[imagePathArray objectAtIndex:i-1] lastPathComponent]];
            //            [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
            //            [mainGLView.mouseOverController.rectangleTool setCurrentFrame:frame];
            return true;
        }
        return false;
    }
}

- (IBAction)toggleRectSave:(id)sender
{
    if (saveEmptyFrames.state) {
        saveEmptyFrames.state = false;
    }
    else{
        saveEmptyFrames.state = true;
    }
}

- (IBAction)copyPreviousRects:(id)sender
{
    [self copyRectsFromLastNonEmptyFrame];
}




-(void)copyRectsFromLastNonEmptyFrame
{
    for(int i = frameNum-1; i >= 0; i--)
    {
        NSMutableDictionary* rects = [annotationsForFrames objectForKey:@(i)];
        
        if (rects && rects.count > 0 && i != frameNum) {
            NSMutableDictionary* newRects = [[NSMutableDictionary alloc  ] init];
            for(int j = 0; j < rects.count; j++)
            {
                NSObject *key = [rects.allKeys objectAtIndex:j];
                if ([mainGLView.mouseOverController.rectangleTool.rectTrackingForRectsWithKeys containsObject:key]) {
                    cv::Mat lastImg = [(OpenImageHandler *)[frameForFrameNumber objectForKey:@(i)] Cv];
                    cv::Mat curImage = [(OpenImageHandler *)[frameForFrameNumber objectForKey:@(frameNum)] Cv];
                    NSRect r = [[rects objectForKey:key] rectValue];
                    cv::Rect r2(r.origin.x,r.origin.y,r.size.width,r.size.height);
                    ;
                    cv::Mat gray;
                    cv::cvtColor(lastImg, gray, CV_BGR2GRAY);
                    dlib::cv_image<uchar> img(gray);
                    dlib::correlation_tracker *trackerTmp;
                    if (![trackers.allKeys containsObject:key]) {
                        trackerTmp= new dlib::correlation_tracker;
                        //                        dlib::array2d<dlib::bgr_pixel> img;
                        //                        img.set_size(lastImg.rows, lastImg.cols);
                        //                        for(int x = 0; x < lastImg.cols; x++)
                        //                        {
                        //                            for (int y = 0; y < lastImg.rows; y++) {
                        //                                cv::Vec3b s = lastImg.at<cv::Vec3b>(y,x);
                        //                                img[y][x] = dlib::bgr_pixel(s[0],s[1],s[2]);
                        //                            }
                        //                        }
                        trackerTmp->start_track(img, dlib::centered_rect(dlib::point(r2.x+r2.width/2,r2.y+r2.height/2), r2.width, r2.height));
                        NSValue *val = [NSValue valueWithPointer:trackerTmp];
                        [trackers setObject:val forKey:key.copy];
                    }
                    else
                    {
                        trackerTmp = (dlib::correlation_tracker *)[[trackers objectForKey:key] pointerValue];
                    }
                    trackerTmp->update(img);
                    dlib::drectangle newRect =  trackerTmp->get_position();
                    
                    //                SemiBoostingApplication tracker;
                    //                tracker.initTracker(100, .99, 2, r2, lastImg);
                    //                cv::Rect newLocation = tracker.RunTrackIteration(curImage);
                    //            CamShiftTracker *newTracker = [[CamShiftTracker alloc] init];
                    //            [newTracker inputImage:lastImg selectedArea:r2];
                    //            cv::Rect newLocation = [newTracker trackOnImage:curImage];
                    NSRect newLocationRect = NSMakeRect(newRect.left(), newRect.top(), newRect.width(), newRect.height());
                    [newRects setObject:[NSValue valueWithRect:newLocationRect] forKey:key.copy];
                }
                else
                {
                    [newRects setObject:[rects objectForKey:key] forKey:key.copy];
                }
                
            }
            [mainGLView.mouseOverController.rectangleTool setElements:newRects]; //load new rects for next frame
            return;
        }
    }
}
- (IBAction)ClearCurrentRects:(id)sender
{
    for (GLViewTool *t in mainGLView.mouseOverController.allTools.allValues) {
        [t clearAll];
    }
}

-(bool)shouldStoreRects
{
    //	bool allEmpty = true;
    //	for(int i = 0; i < rectsForFrames.count; i++)
    //	{
    //		allEmpty = [(NSDictionary *)[rectsForFrames objectForKey:[rectsForFrames.allKeys objectAtIndex:i]] count] > 0;
    //		if (!allEmpty) return false;
    //	}
    //	return  allEmpty;
    if (mainGLView.mouseOverController.rectangleTool.getElements.count > 0)
    {
        return true;
    }
    return [saveEmptyFrames state];
}
- (IBAction)JumpToFrame:(id)sender {
    //    capture.set(CV_CAP_PROP_POS_FRAMES, frameJumpField.intValue);
    [self GoToFrame:frameJumpField.intValue];
    
}

- (IBAction)OpenM:(id)sender
{
    savingStatusLabel.stringValue = @"Opening Files...";
    acceptableImageTypes = @[[NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.bmp'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.ppm'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.gif'"]];
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:YES];
    [openDlg setPrompt:@"Open"];
    if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray* files = [openDlg filenames];
        
        NSMutableArray *onlyImages2 = [[NSMutableArray alloc] init];
        for(NSPredicate *fltr in acceptableImageTypes)
        {
            NSArray *only =[files filteredArrayUsingPredicate:fltr];
            [onlyImages2 addObjectsFromArray:only];
        }
        if (files.count == 1) {
            NSString *fileName = [files objectAtIndex:0];
            BOOL isDir = NO;
            
            if( [fm fileExistsAtPath:fileName isDirectory:&isDir])
            {
                if (isDir || onlyImages2.count > 0) {
                    videoMode =false;
                    currentFilePath = [fileName retain];
                    NSArray *dirContents = [fm contentsOfDirectoryAtPath:fileName error:nil];
                    NSMutableArray *onlyImages = [[NSMutableArray alloc] init];
                    NSMutableArray *onlyImagesFullPath = [[NSMutableArray alloc] init];
                    if(isDir){
                        for(NSPredicate *fltr in acceptableImageTypes)
                        {
                            NSArray *only =[dirContents filteredArrayUsingPredicate:fltr];
                            [onlyImages addObjectsFromArray:only];
                        }
                        for(int i = 0; i < onlyImages.count; i++)
                        {
                            NSString *name = [onlyImages objectAtIndex:i];
                            NSString *fullPath = [fileName stringByAppendingPathComponent:name];
                            [onlyImagesFullPath addObject:fullPath];
                        }
                    }
                    else
                    {
                        onlyImages = onlyImages2;
                        onlyImagesFullPath = onlyImages;
                    }
                    imagePathArray = onlyImagesFullPath;
                    [self loadNewFrame:0];
                    OpenImageHandler *img = [frameForFrameNumber objectForKey:@(0)];
                    [GLViewListCommand AddObject:img ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
                    [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%li",1,imagePathArray.count]];
                }
                else{
                    videoMode = true;
                    currentFilePath = [fileName retain];
                    AVAsset *asset = [AVAsset assetWithURL:[[NSURL alloc] initFileURLWithPath:fileName]];
                    NSArray *tracks = asset.tracks;
                    
                    
                    if (tracks.count > 0) {
                        AVAssetTrack *mainTrack = [tracks objectAtIndex:0];
                        float fps = mainTrack.nominalFrameRate;
                        CMTimeRange trackRange = mainTrack.timeRange;
                        float totalTimeInSeconds = CMTimeGetSeconds(trackRange.duration);
                        float frames = fps*totalTimeInSeconds;
                        numFrames = round(frames);
                    }
                    else
                        numFrames =(int)capture.get(CV_CAP_PROP_FRAME_COUNT);
                    capture.open(fileName.UTF8String);
                    bool didload = false;
                    if (capture.isOpened()) {
                        didload = [self loadNewFrame:0];
                        if(didload)
                        {
                            OpenImageHandler *img = [frameForFrameNumber objectForKey:@(0)];
                            [GLViewListCommand AddObject:img ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
                            [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",frameNum,numFrames]];
                        }
                    }
                    if (!capture.isOpened() || !didload)
                    {
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert addButtonWithTitle:@"OK"];
                        [alert setMessageText:@"We could not open this file"];
                        [alert setInformativeText:@"The codec may not be installed internally"];
                        [alert setAlertStyle:NSWarningAlertStyle];
                        if ([alert runModal] == NSAlertFirstButtonReturn) {
                        }
                        savingStatusLabel.stringValue = @"Error: Could not load file";
                    }
                }
                
                
            }
            
        }
        else if(files.count > 1 || onlyImages2.count > 0)
        {
            //            videoMode = false;
            //            NSMutableArray *onlyImages = [[NSMutableArray alloc] init];
            //            NSMutableArray *onlyImagesFullPath = [[NSMutableArray alloc] init];
            //            for(NSPredicate *fltr in acceptableImageTypes)
            //            {
            //                [onlyImages addObjectsFromArray:[files filteredArrayUsingPredicate:fltr]];
            //            }
            //            imagePathArray = onlyImages;
            //            [self loadNewFrame:0];
            //            OpenImageHandler *img = [d objectAtIndex:frameNum];
            //            //            [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
            //            [GLViewListCommand AddObject:img ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
            //            [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%li",1,imagePathArray.count]];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"To load multiple files, please select a single folder and click \"open\""];
            [alert setInformativeText:@"Loading of multiple files from different sources is not yet supported"];
            [alert setAlertStyle:NSWarningAlertStyle];
            if ([alert runModal] == NSAlertFirstButtonReturn) {
                // OK clicked, delete the record
            }
            
        }
    }
    savingStatusLabel.stringValue = @"Files Loaded";
}
- (IBAction)OpenFileFixer:(id)sender
{
    [fileFixerWindow makeKeyAndOrderFront:nil];
}

- (BOOL)isDate1:(NSDate*)date1 sameMinuteAsDate2:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    NSInteger minBool1 = [comp1 minute];
    NSInteger minBool2 = [comp2 minute];
    return [comp1 year]  == [comp2 year] && [comp1 month] == [comp2 month] && [comp1 day]   == [comp2 day] && comp2.hour == comp1.hour && comp2.minute == comp1.minute;
}
- (IBAction)bruteFix:(id)sender {
    bruteFix = true;
    [self fixFiles:sender];
}

- (IBAction)fixFiles:(id)sender
{
    int renamedAmount = 0;
    acceptableImageTypes = @[[NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.bmp'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.ppm'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.gif'"]];
    fixStatusLabel.stringValue = [NSString stringWithFormat:@"Loading images..."];
    NSString *imageFolder = fixImageFolderField.stringValue;
    NSString *croppedFolder = fixCropFolderField.stringValue;
    NSMutableArray *onlyImages = [[NSMutableArray alloc] init];
    NSMutableArray *onlyCrops = [[NSMutableArray alloc] init];
    NSMutableArray *onlyImagesFullPath = [[NSMutableArray alloc] init];
    NSMutableArray *onlyCropsFullPathCopy;
    NSMutableArray *onlyCropsFullPath = [[NSMutableArray alloc] init];
    NSPredicate * f = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"];
    NSMutableIndexSet *removeSet = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *noCheckSet = [[NSMutableIndexSet alloc] init];
    BOOL imgIsFolder,croppedIsFolder;
    NSFileManager *fm =[NSFileManager defaultManager];
    if (imageFolder && croppedFolder && ![imageFolder isEqualToString:@""] && ![croppedFolder isEqualToString:@""]) {
        if ([fm fileExistsAtPath:imageFolder isDirectory:&imgIsFolder] && imgIsFolder && [fm fileExistsAtPath:croppedFolder isDirectory:&croppedIsFolder] && croppedIsFolder) {
            NSString *logFilePath = [croppedFolder stringByAppendingPathComponent:@"log.csv"];
            if ([fm fileExistsAtPath:logFilePath isDirectory:&croppedIsFolder] && !croppedIsFolder) {
                NSArray *allFiles = [fm contentsOfDirectoryAtPath:imageFolder error:nil];
                for(NSPredicate *fltr in acceptableImageTypes)
                {
                    [onlyImages addObjectsFromArray:[allFiles filteredArrayUsingPredicate:fltr]];
                }
                for(int i = 0; i < onlyImages.count; i++)
                {
                    NSString *name = [onlyImages objectAtIndex:i];
                    NSString *fullPath = [imageFolder stringByAppendingPathComponent:name];
                    [onlyImagesFullPath addObject:fullPath];
                }
                onlyCrops = [[[fm contentsOfDirectoryAtPath:croppedFolder error:nil] filteredArrayUsingPredicate:f] mutableCopy];
                
                for(int i = 0; i < onlyCrops.count; i++)
                {
                    NSString *name = [onlyCrops objectAtIndex:i];
                    NSString *fullPath = [croppedFolder stringByAppendingPathComponent:name];
                    [onlyCropsFullPath addObject:fullPath];
                }
                sceneImages.clear();
                templImages.clear();
                for(int i  = 0; i < onlyImagesFullPath.count; i++)
                {
                    sceneImages.push_back(cv::imread([[onlyImagesFullPath objectAtIndex:i] UTF8String]));
                    scenesFound.push_back(false);
                }
                for(int i  = 0; i < onlyCropsFullPath.count; i++)
                {
                    templImages.push_back(cv::imread([[onlyCropsFullPath objectAtIndex:i] UTF8String]));
                    templatesFound.push_back(false);
                }
                if (!bruteFix) {
                    NSDictionary* logfileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:logFilePath error:nil];
                    NSDate *logFileDate = [logfileAttribs objectForKey:NSFileModificationDate]; //or NSFileModificationDate
                    
                    for (int i = 0; i < onlyCropsFullPath.count; i++) {
                        NSDate *fileModDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:[onlyCropsFullPath objectAtIndex:i] error:nil] objectForKey:NSFileModificationDate];
                        if(![self isDate1:fileModDate sameMinuteAsDate2:logFileDate])
                        {
                            [removeSet addIndex:i];
                        }
                        onlyCropsFullPathCopy = onlyCropsFullPath.copy;
                    }
                    
                    
                    [onlyCropsFullPath removeObjectsAtIndexes:removeSet];
                    [onlyCrops removeObjectsAtIndexes:removeSet];
                    
                    BOOL isFold;
                    NSString * newFolderPathOtherDate;
                    if (removeSet.count > 0) {
                        newFolderPathOtherDate = [[[onlyCropsFullPath objectAtIndex:0] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"otherDate"];
                    }
                    if (removeSet.count > 0 && (![fm fileExistsAtPath:newFolderPathOtherDate isDirectory:&isFold] || !isFold)) {
                        
                        [fm createDirectoryAtPath:newFolderPathOtherDate withIntermediateDirectories:NO attributes:nil error:nil];
                    }
                    NSArray *tmp = [onlyCropsFullPathCopy objectsAtIndexes:removeSet];
                    for (int i = 0; i < tmp.count;i++) {
                        NSString *path =[tmp objectAtIndex:i];
                        [fm moveItemAtPath:path toPath:[newFolderPathOtherDate stringByAppendingPathComponent:path.lastPathComponent] error:nil];
                    }
                    NSLog(@"removed %lu bad images from cropped set",(unsigned long)removeSet.count);
                    NSString *logString = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
                    NSMutableArray *frameNumbers = [[NSMutableArray alloc] init];
                    NSArray *logRows = [logString componentsSeparatedByString:@"\n"];
                    for(int i = 1; i < logRows.count; i++)
                    {
                        NSArray *logCol = [[logRows objectAtIndex:i] componentsSeparatedByString:@","];
                        if (logCol.count > 1) {
                            [frameNumbers addObject:@([[logCol objectAtIndex:0] integerValue])];
                        }
                    }
                    if (frameNumbers.count == onlyCropsFullPath.count) {
                        fixStatusLabel.stringValue = [NSString stringWithFormat:@"fixing %lu cropped images",(unsigned long)frameNumbers.count];
                        NSMutableDictionary *renamedFileMap = [[NSMutableDictionary alloc] init];
                        for (int i = 0; i < frameNumbers.count; i++) {
                            NSString *renamedName = [[[onlyCropsFullPath objectAtIndex:i] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"temp_%i",i]];
                            [renamedFileMap setObject:renamedName forKey:[onlyCropsFullPath objectAtIndex:i]];
                            [fm moveItemAtPath:[onlyCropsFullPath objectAtIndex:i] toPath:renamedName error:nil];
                        }
                        
                        for (int i = 0; i < frameNumbers.count; i++) {
                            NSString *croppedFileOriginalPath = [onlyCropsFullPath objectAtIndex:i];
                            int croppedFileFrame = [[frameNumbers objectAtIndex:i] intValue];
                            if (croppedFileFrame >= 0 && croppedFileFrame < onlyImages.count) {
                                NSString *realImageFileName = [onlyImages objectAtIndex:croppedFileFrame];
                                NSString *saveImgPath = [[croppedFileOriginalPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[NSString stringWithFormat:@"Cropped0_%@",realImageFileName]] stringByAppendingPathExtension:@"png"];
                                [fm moveItemAtPath:[renamedFileMap objectForKey:croppedFileOriginalPath] toPath:saveImgPath error:nil];
                                [noCheckSet addIndex:croppedFileFrame];
                                if (![croppedFileOriginalPath isEqualToString:saveImgPath]) {
                                    renamedAmount++;
                                }
                            }
                            else{
                                fixStatusLabel.stringValue = [NSString stringWithFormat:@"Error: Cropped file frame %i too large for image set", croppedFileFrame];
                                NSLog(@"error!");
                                
                            }
                        }
                    }
                    else
                    {
                        NSLog(@"error!");
                        fixStatusLabel.stringValue = [NSString stringWithFormat:@"Error: a dimension mismatch occured between the log file \"log.csv\" and the number of cropped images"];
                        return;
                    }
                    
                }
                else{
                    bruteFix = false;
                    
                    foundMatches = 0;
                    fixStatusLabel.stringValue = [NSString stringWithFormat:@"Running brute force on %lu images",onlyCropsFullPath.count];
                    
                    NSMutableDictionary *renamedFileMap = [[NSMutableDictionary alloc] init];
                    for (int i = 0; i < onlyCropsFullPath.count; i++) {
                        NSString *renamedName = [[[onlyCropsFullPath objectAtIndex:i] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"temp_%i",i]];
                        [renamedFileMap setObject:renamedName forKey:[onlyCropsFullPath objectAtIndex:i]];
                        [fm moveItemAtPath:[onlyCropsFullPath objectAtIndex:i] toPath:renamedName error:nil];
                    }
                    
                    NSMutableIndexSet *notFixed = [[NSMutableIndexSet alloc]   init];
                    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                    for(int i = 0; i < onlyCropsFullPath.count; i++)
                    {
                        
                        NSString *unchangedFilePath = [onlyCropsFullPath objectAtIndex:i];
                        NSString *filePathToRename = [renamedFileMap objectForKey:unchangedFilePath];
                        cv::Mat templ = cv::imread(filePathToRename.UTF8String);
                        NSFileManager *fm = [NSFileManager defaultManager];
                        bool wasreplaced = false;
                        for (int j = 0; j < sceneImages.size(); j++) {
                            NSString *fileToRenameTo =[onlyImagesFullPath objectAtIndex:j];
                            cv::Mat scene = sceneImages[j];
                            cv::Mat result;
                            if (!scene.empty() && !templ.empty()) {
                                NSString *filePathToRename = [renamedFileMap objectForKey:unchangedFilePath];
                                NSString *renamedFilePath = [filePathToRename.stringByDeletingLastPathComponent stringByAppendingPathComponent:[NSString stringWithFormat:@"Cropped0_%@",fileToRenameTo.lastPathComponent]];
                                [NSThread detachNewThreadSelector:@selector(matchImg:) toTarget:self withObject:@[@(i),@(j),filePathToRename,renamedFilePath]];
                                
                                
                            }
                        }
                        
                    }
                    [onlyCropsFullPath removeObjectsAtIndexes:notFixed];
                    
                    fixStatusLabel.stringValue = [NSString stringWithFormat:@"Warning: %lu cropped images could not be correctly matched.",(unsigned long)notFixed.count];
                }
                
            }
            else{
                NSLog(@"error!");
                fixStatusLabel.stringValue = [NSString stringWithFormat:@"Error: Log file \"log.csv\" does not exist in cropped file folder"];
                return;
            }
        }
        else{
            NSLog(@"error!");
            fixStatusLabel.stringValue = [NSString stringWithFormat:@"Error: Folder paths invalid"];
            return;
        }
        
    }
    else{
        NSLog(@"error!");
        fixStatusLabel.stringValue = [NSString
                                      stringWithFormat:@"Error: Folder paths invalid"];
        return;
    }
    fixStatusLabel.stringValue = [NSString stringWithFormat:@"Success! %i of %lu needed renaming",renamedAmount,(unsigned long)onlyCropsFullPath.count];
    if (removeSet.count > 0) {
        int foundMatches = 0;
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        [alert setMessageText:[NSString stringWithFormat:@"%lu files could not be correctly matched according to the log file provided.  Would you like to attempt to brute force matches for them?",(unsigned long)removeSet.count]];
        [alert setInformativeText:@"This could take a while."];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            // OK clicked, delete the record
            
        }
    }
}

-(void)findMatchForCroppedImage:(NSArray *)args
{
    int templIndex = [[args objectAtIndex:0] intValue];
    
}

-(void)matchImg:(NSArray *)args
{
    int templIndex = [[args objectAtIndex:0] intValue];
    int sceneIndex = [[args objectAtIndex:1] intValue];
    if (templatesFound[templIndex] || templatesFound[sceneIndex]) {
        return;
    }
    NSString *currentPathName = [args objectAtIndex:2];
    NSString *renameToPathName = [args objectAtIndex:3];
    if ([renameToPathName hasSuffix:@".png.png"]) {
        NSLog(@"stop!");
    }
    cv::Mat templ = templImages[templIndex].clone();
    cv::Mat scene = sceneImages[sceneIndex].clone();
    cv::Mat result;
    //    for(int x = 0; x < scene.cols-templ.cols; x++)
    //    {
    //        for (int y = 0; y < scene.rows-templ.rows; y++) {
    //            <#statements#>
    //        }
    //    }
    
    cv::matchTemplate(scene, templ, result, CV_TM_SQDIFF);
    //    normalize( result, result, 0, 1, cv::NORM_MINMAX, -1, cv::Mat() );
    double minval;
    cv::minMaxLoc(result, &minval,NULL);
    if (minval == 0) {
        [lock lock];
        if (templatesFound[templIndex] || templatesFound[sceneIndex]) {
            [lock unlock];
            return;
        }
        NSLog(@"replaced!");
        cv::resize(templ,templ,cv::Size(templ.cols*5,templ.rows*5));
        //        cv::imshow([[NSString stringWithFormat:@"%i,%i crop",templIndex,sceneIndex] UTF8String], templ);
        //        cv::imshow([[NSString stringWithFormat:@"%i,%i scene",templIndex,sceneIndex] UTF8String], scene);
        //        cv::waitKey();
        foundMatches++;
        templatesFound[templIndex] = true;
        scenesFound[sceneIndex] = true;
        [[NSFileManager defaultManager] moveItemAtPath:currentPathName toPath:renameToPathName error:nil];
        [lock unlock];
    }
}
Mat norm_0_255(InputArray _src) {
    Mat src = _src.getMat();
    // Create and return normalized image:
    Mat dst;
    switch(src.channels()) {
        case 1:
            cv::normalize(_src, dst, 0, 255, NORM_MINMAX, CV_8UC1);
            break;
        case 3:
            cv::normalize(_src, dst, 0, 255, NORM_MINMAX, CV_8UC3);
            break;
        default:
            src.copyTo(dst);
            break;
    }
    return dst;
}

-(bool)object:(std::vector<cv::Point>)obj1 isEntirelyWithinObject:(std::vector<cv::Point>)obj2
{
    bool iswithin = true;
    for (int i = 0; i < obj1.size(); i++) {
        float dist = cv::pointPolygonTest(obj2, obj1[i], false);
        if (dist < 0)
        {
            iswithin = false;
            break;
        }
    }
    return iswithin;
}

-(bool)RunSaveAsDialog
{
    NSSavePanel *tvarNSSavePanelObj	= [NSSavePanel savePanel];
    int tvarInt	= [tvarNSSavePanelObj runModal];
    if(tvarInt == NSOKButton){
        hasSavePath = true;
    } else if(tvarInt == NSCancelButton) {
        return false;
    } else {
        return false;
    } // end if
    
    saveProjectFileDir = [tvarNSSavePanelObj directory];
    saveProjectFilePath= [tvarNSSavePanelObj filename];
    return true;
}

-(bool)saveOverDialog:(NSString *)name
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:name];
//    [alert setInformativeText:@"This will irreversible over-write the previous file"];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        // OK clicked, delete the record
        return true;
    }
    if ([alert runModal] == NSAlertSecondButtonReturn) {
        return false;
    }
    else return false;
}

-(IBAction)saveAs:(id)sender
{
    bool isGoodPath =false;
    bool shouldcontinue = true;
    while (!isGoodPath and shouldcontinue) {
        shouldcontinue = [self RunSaveAsDialog];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isPathDir;
        BOOL isDirDir;
        [fm fileExistsAtPath:saveProjectFilePath isDirectory:&isPathDir];
        [fm fileExistsAtPath:saveProjectFileDir isDirectory:&isDirDir];
        if (shouldcontinue) {
            if (isPathDir) { //file already exists here
                bool go = [self saveOverDialog:[NSString stringWithFormat:@"A file with the name '%@' already exists in this directory. Would you like to replace it?",saveProjectFilePath.lastPathComponent]];
                if (go)
                {
                    shouldcontinue = true;
                }
                isGoodPath = false;
            }
            else if (!isDirDir) { //this folder doesn't exist
                bool go = [self saveOverDialog:[NSString stringWithFormat:@"The folder '%@' Does not exist. Would you like to create it?",saveProjectFileDir]];
                if (go)
                {
                    shouldcontinue = false;
                    [fm createDirectoryAtPath:saveProjectFileDir withIntermediateDirectories:YES attributes:nil error:nil];
                    hasSavePath = true;
                }
                else{
                    isGoodPath = false;
                    shouldcontinue = true;
                }
                
            }
            else{
                isGoodPath = true;
                hasSavePath = true;
            }
        }

    }
    [self save:sender];

    
}

- (IBAction)save:(id)senders
{
    savingStatusLabel.stringValue = @"Saving Project a...";
    if(!hasSavePath)
    {
        [self saveAs:senders];
    }
    else
    {
    NSMutableDictionary *annotations = [[NSMutableDictionary alloc] init];
    for(NSString *k in mainGLView.mouseOverController.allTools.allKeys) [annotations setObject:[[mainGLView.mouseOverController.allTools objectForKey:k] getElements] forKey:k];
    [annotationsForFrames setObject:annotations forKey:@(frameNum)]; //save current rects for current frame
    
    NSMutableString *fullSaveFile = [[NSMutableString alloc] init];
    BOOL isdir = NO;
    if(saveProjectFilePath != nil and ![saveProjectFilePath isEqualToString:@""] and [[NSFileManager defaultManager] fileExistsAtPath:saveProjectFilePath.stringByDeletingLastPathComponent isDirectory:&isdir] and isdir)
    {
        
        //first find all of the different headers there need to be
        NSMutableDictionary *uniquePropertyKeyDict = [[NSMutableDictionary alloc] init];
        for(int i =0; i < annotationsForFrames.count; i++)
        {
            NSNumber *frameKey = [annotationsForFrames.allKeys objectAtIndex:i];
            NSDictionary *allAnnotationsForFrame = [annotationsForFrames objectForKey:frameKey];
        for (int j = 0; j < allAnnotationsForFrame.count; j++) {
            NSString *toolKey = [allAnnotationsForFrame.allKeys objectAtIndex:j];
            NSDictionary *annotationsFromTool = [allAnnotationsForFrame objectForKey:toolKey];
            for(NSString *elementKey in annotationsFromTool.allKeys){
                NSDictionary *elements = [annotationsFromTool objectForKey:elementKey];
                for (NSString *key in elements.allKeys) [uniquePropertyKeyDict setObject:@"" forKey:key];
            }
        }
        }
        NSMutableArray *propertyKeys =  uniquePropertyKeyDict.allKeys.mutableCopy;
        [propertyKeys removeObject:@"coords"];
        [propertyKeys sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [propertyKeys insertObjects:@[@"annotationType",@"name"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]];
        
        //now begin saving the annotations for each image file
        for(int i =0; i < annotationsForFrames.count; i++)
        {
            NSMutableString *saveCSV = @"".mutableCopy;
            NSNumber *frameKey = [annotationsForFrames.allKeys objectAtIndex:i];
            NSString *framePath = [framePathForFrameNum objectForKey:frameKey];
            NSDictionary *allAnnotationsForFrame = [annotationsForFrames objectForKey:frameKey];
            
                        //Create the csv headers
            [saveCSV appendString:[propertyKeys componentsJoinedByString:@","]];
            [saveCSV appendString:@"\n"];
            
            
            //Write the annotation data
            for (int j = 0; j < allAnnotationsForFrame.count; j++) {
                NSString *toolKey = [allAnnotationsForFrame.allKeys objectAtIndex:j];
                NSDictionary *annotationsFromTool = [allAnnotationsForFrame objectForKey:toolKey];
                if (annotationsFromTool.count > 0)
                {
                    for(int k = 0; k < annotationsFromTool.count; k++)
                    {
                        NSString *elementKey = [annotationsFromTool.allKeys objectAtIndex:k];
                        NSDictionary *elementDict = [annotationsFromTool objectForKey:elementKey];
                        [saveCSV appendFormat:@"%@,%@",toolKey,elementKey];
                        if ([toolKey isEqualToString:@"pointTool"]) {
                            [saveCSV appendString:@"\n"];
                            NSArray *points = [elementDict objectForKey:@"coords"];
                            for (int n = 0; n < points.count; n++) {
                                NSPoint p = [[points objectAtIndex:n] pointValue];
                                for (int m = 0; m < propertyKeys.count; m++) {
                                    NSString *propKey = [propertyKeys objectAtIndex:m];
                                    if ([propKey isEqualToString:@"x coord"]) [saveCSV appendFormat:@"%i,",(int)p.y];
                                    else if([propKey isEqualToString:@"y coord"]) [saveCSV appendFormat:@"%i,",(int)p.y];
                                    else [saveCSV appendString:@","];
                                }
                                [saveCSV appendString:@"\n"];
                            }
                        }
                        else {
                            for (int l = 2; l < propertyKeys.count; l++) {
                                NSObject *o =[elementDict objectForKey:[propertyKeys objectAtIndex:l]];
                                if ( o != nil) {
                                    [saveCSV appendFormat:@",%@",o.description];
                                }
                                else {
                                    [saveCSV appendString:@","];
                                }
                            }
                            [saveCSV appendString:@"\n"];
                        }
                    }
                    
                    
                }
                
            }
            [fullSaveFile appendFormat:@"%@\n",framePath];
            [fullSaveFile appendString:saveCSV];
            NSString *individualFileSaveFolder = [saveProjectFileDir stringByAppendingPathComponent:@"logFiles"];
            BOOL isDirAlready;
            if ([[NSFileManager defaultManager] fileExistsAtPath:individualFileSaveFolder isDirectory:&isDirAlready] or !isDirAlready) {
                [[NSFileManager defaultManager] createDirectoryAtPath:individualFileSaveFolder withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *individualFileSavePath = [[individualFileSaveFolder stringByAppendingPathComponent:framePath.lastPathComponent ] stringByAppendingString:@"_log.csv"];
            [saveCSV writeToFile:individualFileSavePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        [fullSaveFile writeToFile:[saveProjectFilePath stringByAppendingPathExtension:@"saproj"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    savingStatusLabel.stringValue = [NSString stringWithFormat:@"Project saved at %@",dateString];
    }
}
@end