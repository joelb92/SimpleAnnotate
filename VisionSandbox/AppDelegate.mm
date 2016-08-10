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
//    [self extractPatchesFromProjectFile:@"/Volumes/biometrics/Biometric_Datasets/ORNL_Tattos_Piercings/tattoos/tattoos_nisha/nisha.saproj"];
    [self extractNonTattooPatchesFromProjectFile:@"/Volumes/BTAS/ORNL_Tattos_Piercings/tattoos/tattoos_joel_project/joel_tattoos_project.saproj"];
    [self splashSequence];
    lock = [[NSLock alloc] init];
    matchedScenes = [[NSMutableIndexSet alloc] init];
    imagePathArray = [[NSMutableArray alloc] init];
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
    for(int i = 0; i < faceDetector.dets.size(); i++)
    {
        NSRect nsr = faceDetector.dets[i];
        cv::Rect r(nsr.origin.x,nsr.origin.y,nsr.size.width,nsr.size.height);
        //        cv::Mat face = currentImage.Cv(r).clone();
        //        OpenImageHandler *faceImage = [[OpenImageHandler alloc] initWithCVMat:face Color:Black BinaryImage:false];
        [[mainGLView.mouseOverController rectangleTool] addElement:nsr color:Green forKey:[NSString stringWithFormat:@"Face %i",i] andType:@"Face"];
    }
    
    //    NSAlert *alert = [[NSAlert alloc] init];
    //    [alert addButtonWithTitle:@"Yes"];
    //    [alert addButtonWithTitle:@"No"];
    //    [alert setMessageText:[NSString stringWithFormat:@"%lu Faces have been detected.  Would you like to split them?",(unsigned long)faceDetector.faceRectDict.count]];
    //    [alert setInformativeText:@"This will allow you to work on each individual face separately"];
    //    [alert setAlertStyle:NSWarningAlertStyle];
    //    if ([alert runModal] == NSAlertFirstButtonReturn) {
    //        //split the faces
    //    }
    
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
        //        NSLog(@"Is first responder: %@", [[mainWindow firstResponder] description]);
        //        NSLog(@"Is first responder: %@", [[NSApp targetForAction:@selector(mouseDown:)] description]);
        
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
    [tooltip setHidden:YES];
    bool stillGood = false;
    if (newFrameNum < 0) {
        newFrameNum = imagePathArray.count-1;
    }
    else if (newFrameNum >= imagePathArray.count)
    {
        newFrameNum = 0;
    }
    if (newFrameNum >= 0 and newFrameNum < imagePathArray.count) {
        
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
                    [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%lu",newFrameNum,(unsigned long)imagePathArray.count]];
                    
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
                    //                    annotations  = mainGLView.mouseOverController.allTools.mutableCopy;
                    for(NSString *k in mainGLView.mouseOverController.allTools.allKeys) [annotations setObject:[[mainGLView.mouseOverController.allTools objectForKey:k] getElements] forKey:k];
                    [annotationsForFrames setObject:annotations forKey:@(frameNum)];
                    
                    if ([[annotationsForFrames allKeys] containsObject:@(newFrameNum)]) {
                        NSDictionary *annDict = [annotationsForFrames objectForKey:@(newFrameNum)];
                        
                        for(GLViewTool *k in mainGLView.mouseOverController.allTools.allValues) [k clearAll];
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
                    [mainGLView.mouseOverController.scissorTool setIm:img.Cv];
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
            int total = 0;
            for(NSString *k in mainGLView.mouseOverController.allTools.allKeys){
                NSDictionary *d = [[mainGLView.mouseOverController.allTools objectForKey:k] getElements];
                [annotations setObject:d forKey:k];
                total+= (int)d.count;
            }
            if(!justLoadedNewProject)
            {
                justLoadedNewProject = false;
                [annotationsForFrames setObject:annotations forKey:@(frameNum)]; //save current rects for current frame
            }
            else justLoadedNewProject = false;
            
            
            for(GLViewTool *t in mainGLView.mouseOverController.allTools.allValues) [t clearAll];
            if ([[annotationsForFrames allKeys] containsObject:@(newFrameNum)]) {
                NSDictionary *annDict = [annotationsForFrames objectForKey:@(newFrameNum)];
                for (NSString *k in annDict.allKeys) {
                    [[mainGLView.mouseOverController.allTools objectForKey:k] setElements:[[annotationsForFrames objectForKey:@(newFrameNum)] objectForKey:k]];
                } //load new rects for next frame
            }
            OpenImageHandler *img = [frameForFrameNumber objectForKey:@(newFrameNum)];
            [GLViewListCommand AddObject:img ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
            [mainGLView.mouseOverController.scissorTool setIm:img.Cv];
            [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
            
            //            [mainGLView.mouseOverController.rectangleTool setCurrentFrame:[(OpenImageHandler *)[frameForFrameNumber objectForKey:@(newFrameNum)] Cv]];
            int finalVal =numFrames;
            int displayFrameNum = newFrameNum;
            if (!videoMode){
                finalVal = frameForFrameNumber.count;
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
    [self autoSave];
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
        NSMutableDictionary *annotations = [annotationsForFrames objectForKey:@(i)];
        if (annotations) {
            NSMutableDictionary* rects = [annotations objectForKey:mainGLView.mouseOverController.currentToolKey];
            [mainGLView.mouseOverController.tool setElements:rects];
            
            
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
    acceptableImageTypes = @[[NSPredicate predicateWithFormat:@"self ENDSWITH '.tga'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.pgm'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.pct'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.pbm'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.jpe'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.jbg'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.img'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.tiff'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.jpeg'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.bmp'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.ppm'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.gif'"]];
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:YES];
    [openDlg setPrompt:@"Open"];
    if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSMutableArray* files = [[openDlg filenames] mutableCopy];
        
        NSMutableArray *onlyImages2 = [[NSMutableArray alloc] init];
        for(int i = 0; i < files.count; i++)
        {
            [files replaceObjectAtIndex:i withObject:[[files objectAtIndex:i] lowercaseString]];
        }
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
                    //we have a directory selected, look for all images in directory
                    
                    saveProjectFileDir = fileName.retain;
                    saveProjectFilePath = [fileName stringByAppendingPathComponent:@"mainProject"].retain;
                    hasSavePath = true;
                    
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
                        [onlyImages sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
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
                    [mainGLView.mouseOverController.scissorTool setIm:img.Cv];
                    [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%li",1,imagePathArray.count]];
                }
                else{ //we most likely have a video
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
                            [mainGLView.mouseOverController.scissorTool setIm:img.Cv];
                            [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",frameNum,imagePathArray.count]];
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
        didCancelSave = false;
        hasSavePath = true;
    } else if(tvarInt == NSCancelButton) {
        didCancelSave = true;
        return false;
    } else {
        didCancelSave = true;
        return false;
    } // end if
    
    saveProjectFileDir = [[tvarNSSavePanelObj directory] retain];
    saveProjectFilePath= [[tvarNSSavePanelObj filename] retain];
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

-(void)autoSave
{
    NSString *prevSaveDir = saveProjectFileDir.copy;
    NSString *prevSavePath = saveProjectFilePath.copy;
    saveProjectFileDir = [[NSBundle mainBundle] resourcePath];
    saveProjectFilePath = [saveProjectFileDir stringByAppendingPathComponent:@"autosavefile"];
    bool prevHasPath = hasSavePath;
    hasSavePath = true;
    didCancelSave = false;
    [self save:nil];
    saveProjectFilePath = prevSavePath;
    saveProjectFileDir = prevSaveDir;
    hasSavePath = prevHasPath;
    
}

-(IBAction)recoverProject:(id)sender
{
    NSString *recoverFilePath = [[NSBundle mainBundle] pathForResource:@"autosavefile" ofType:@"saproj"];
    [self loadProjectFile:recoverFilePath];
}

- (IBAction)save:(id)senders
{
    
    if (didCancelSave){ didCancelSave = false; return;}
    if(!hasSavePath)
    {
        [self saveAs:senders];
        if (didCancelSave){didCancelSave = false; return;}
    }
    else
    {
        savingStatusLabel.stringValue = @"Saving Project...";
        NSMutableDictionary *annotations = [[NSMutableDictionary alloc] init];
        for(NSString *k in mainGLView.mouseOverController.allTools.allKeys) [annotations setObject:[[mainGLView.mouseOverController.allTools objectForKey:k] getElements] forKey:k];
        [annotationsForFrames setObject:annotations forKey:@(frameNum)]; //save current rects for current frame
        
        NSMutableString *fullSaveFile = [[NSMutableString alloc] init];
        [fullSaveFile appendFormat:@"%@,\n",saveProjectFileDir];
        BOOL isdir = NO;
        if(saveProjectFilePath != nil and ![saveProjectFilePath isEqualToString:@""] and [[NSFileManager defaultManager] fileExistsAtPath:saveProjectFilePath.stringByDeletingLastPathComponent isDirectory:&isdir] and isdir)
        {
            
            //first find all of the different headers there need to be
            NSMutableDictionary *uniquePropertyKeyDict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *numAnnotationsForFrame = [[NSMutableDictionary alloc] init];
            for(int i =0; i < annotationsForFrames.count; i++)
            {
                NSNumber *frameKey = [annotationsForFrames.allKeys objectAtIndex:i];
                NSDictionary *allAnnotationsForFrame = [annotationsForFrames objectForKey:frameKey];
                int total = 0;
                for (int j = 0; j < allAnnotationsForFrame.count; j++) {
                    NSString *toolKey = [allAnnotationsForFrame.allKeys objectAtIndex:j];
                    NSDictionary *annotationsFromTool = [allAnnotationsForFrame objectForKey:toolKey];
                    total += annotationsFromTool.count;
                    for(NSString *elementKey in annotationsFromTool.allKeys){
                        NSDictionary *elements = [annotationsFromTool objectForKey:elementKey];
                        for (NSString *key in elements.allKeys) [uniquePropertyKeyDict setObject:@"" forKey:key];
                        
                    }
                }
                [numAnnotationsForFrame setObject:@(total) forKey:frameKey];
            }
            NSMutableArray *propertyKeys =  uniquePropertyKeyDict.allKeys.mutableCopy;
            [propertyKeys removeObject:@"coords"];
            [propertyKeys sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [propertyKeys insertObjects:@[@"annotationType",@"name"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]];
            
            //now begin saving the annotations for each image file
            int i = 0;
            NSMutableArray *sortedKeysForAnnotationsForFrames= [annotationsForFrames.allKeys mutableCopy];
            [sortedKeysForAnnotationsForFrames sortUsingSelector:@selector(compare:)];
            for(i =0; i < annotationsForFrames.count; i++)
            {
                NSMutableString *saveCSV = @"".mutableCopy;
                NSNumber *frameKey = [sortedKeysForAnnotationsForFrames objectAtIndex:i];
                NSString *framePath = [framePathForFrameNum objectForKey:frameKey];
                NSDictionary *allAnnotationsForFrame = [annotationsForFrames objectForKey:frameKey];
                cv::Mat img = cv::imread(framePath.UTF8String);
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
                            if ([toolKey isEqualToString:@"pointTool"]) {
                                
                                NSArray *points = [elementDict objectForKey:@"coords"];
                                std::vector<cv::Point> cont;
                                for (int n = 0; n < points.count; n++) {
                                    
                                    NSPoint p = [[points objectAtIndex:n] pointValue];
                                    cont.push_back(cv::Point(p.x,p.y));
                                    for (int m = 0; m < propertyKeys.count; m++) {
                                        NSString *propKey = [propertyKeys objectAtIndex:m];
                                        if ([propKey isEqualToString:@"x coord"]) [saveCSV appendFormat:@"%i,",(int)p.x];
                                        else if([propKey isEqualToString:@"y coord"]) [saveCSV appendFormat:@"%i,",(int)p.y];
                                        else [saveCSV appendString:@","];
                                    }
                                    [saveCSV appendString:@"\n"];
                                }
                                cv::Mat heat = cv::Mat::zeros(img.rows, img.cols, CV_8UC1);
                                cv::imshow("img", img);
                                cv::waitKey();
                                cv::Mat mask = heat.clone();
                                cv::Mat heatMap,final;
                                for(int x = 0; x < img.cols; x++)
                                {
                                    for (int y = 0; y < img.rows; y++)
                                    {
                                        double val = cv::pointPolygonTest(cont, cv::Point(x,y), true);
                                        if(val >= 0){
                                            mask.at<unsigned char>(y,x) = 255;
                                            heat.at<unsigned char>(y,x) = uchar(int(floor(val*255)));
                                        }
                                    }
                                }
                                cv::imshow("mask", mask);
                                cv::waitKey();
                                cv::applyColorMap(heat, heatMap, COLORMAP_JET);
                                cv::imwrite("heatmap.jpg", heatMap);
                                cv::imwrite("heat.jpg", heat);
                                
                                
                            }
                        }
                        
                        
                    }
                    
                }
                [fullSaveFile appendFormat:@"f:%@\n",framePath];
                [fullSaveFile appendString:saveCSV];
                NSString *individualFileSaveFolder = [saveProjectFileDir stringByAppendingPathComponent:@"logFiles"];
                BOOL isDirAlready;
                if ([[NSFileManager defaultManager] fileExistsAtPath:individualFileSaveFolder isDirectory:&isDirAlready] or !isDirAlready) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:individualFileSaveFolder withIntermediateDirectories:YES attributes:nil error:nil];
                }
                NSString *individualFileSavePath = [[individualFileSaveFolder stringByAppendingPathComponent:framePath.lastPathComponent ] stringByAppendingString:@"_log.csv"];
                if ([[NSFileManager defaultManager] fileExistsAtPath:individualFileSavePath isDirectory:&isDirAlready] and !isDirAlready)
                {
                    [[NSFileManager defaultManager] removeItemAtPath:individualFileSavePath error:nil];
                }
                if ([numAnnotationsForFrame objectForKey:frameKey] != nil and [[numAnnotationsForFrame objectForKey:frameKey] intValue] > 0) {
                    BOOL isDir;
                    if ([[NSFileManager defaultManager] fileExistsAtPath:individualFileSavePath isDirectory:&isDir] and !isDir) {
                        [[NSFileManager defaultManager] removeItemAtPath:individualFileSavePath error:nil];
                    }
                    [saveCSV writeToFile:individualFileSavePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                }
                
            }
            //add the rest of the files we loaded
            //            if (i >0) i -= 1;
            for(i = i; i < imagePathArray.count; i++)
            {
                [fullSaveFile appendFormat:@"f:%@\n",[imagePathArray objectAtIndex:i]];
            }
            BOOL isDir;
            if ([[NSFileManager defaultManager] fileExistsAtPath:[saveProjectFilePath stringByAppendingPathExtension:@"saproj"] isDirectory:&isDir] and !isDir)
            {
                [[NSFileManager defaultManager] removeItemAtPath:[saveProjectFilePath stringByAppendingPathExtension:@"saproj"] error:nil];
            }
            [fullSaveFile appendFormat:@"Frame:%i\n",frameNum];
            [fullSaveFile writeToFile:[saveProjectFilePath stringByAppendingPathExtension:@"saproj"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        NSDate *currDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:currDate];
        savingStatusLabel.stringValue = [NSString stringWithFormat:@"Project saved at %@",dateString];
    }
}


- (IBAction)save_legacy:(id)sender
{
    savingStatusLabel.stringValue = @"Saving Crops...";
    
    NSMutableDictionary *annotations = [[NSMutableDictionary alloc] init];
    for(NSString *k in mainGLView.mouseOverController.allTools.allKeys) [annotations setObject:[[mainGLView.mouseOverController.allTools objectForKey:k] getElements] forKey:k];
    [annotationsForFrames setObject:annotations forKey:@(frameNum)]; //save current rects for current frame
    
    NSMutableString *rectOutputLog = [@"Frame,Rectagle Key,X,Y,Width,Height,FileName\n" mutableCopy];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (currentFilePath) {
        NSString *cropFilePath = [[currentFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"pedestrianCrops"];
        if (!videoMode) {
            cropFilePath = [currentFilePath stringByAppendingPathComponent:@"pedestrianCrops"];
        }
        BOOL DirExists =false;
        if( !([fm fileExistsAtPath:cropFilePath isDirectory:&DirExists] && DirExists))
        {
            [fm createDirectoryAtPath:cropFilePath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        for(int i = 0; i < annotationsForFrames.count;i++)
        {
            NSNumber *key = [annotationsForFrames.allKeys objectAtIndex:i];
            NSDictionary *anns = [annotationsForFrames objectForKey:key];
            NSDictionary *rectangleDict = [anns objectForKey:@"rectangleTool"];
            int frameNumber = [key intValue];
            for (int j = 0; j < rectangleDict.count; j++) {
                NSString *key = [[rectangleDict allKeys] objectAtIndex:j];
                NSDictionary *rdict = [rectangleDict objectForKey:key];
                NSRect r = NSMakeRect([[rdict objectForKey:@"x coord"] intValue], [[rdict objectForKey:@"y coord"] intValue], [[rdict objectForKey:@"width"] intValue], [[rdict objectForKey:@"height" ] intValue]);
                
                NSString *saveImgPath = [[[currentFilePath stringByDeletingPathExtension] stringByAppendingFormat:@"Frame%i_Rect%i",frameNumber,key.intValue] stringByAppendingPathExtension:@"jpg"];
                if([key hasPrefix:@"Rectangle "])
                {
                    key = [key substringFromIndex:10];
                }
                OpenImageHandler *img = [frameForFrameNumber objectForKey:@(frameNumber)];
                cv::Mat m = img.Cv;
                int x = r.origin.x;
                int y = r.origin.y;
                int x2 = x+r.size.width;
                int y2 = y+r.size.height;
                if (x < 0) x = 0;
                if (y < 0) y = 0;
                if (x2 >= m.cols) x2 = m.cols;
                if (y2 >= m.rows) y2 = m.rows;
                int width = x2-x;
                int height = y2-y;
                if(height > 0 && width > 0 && x < m.cols && y < m.rows && x2 >= 0 && y2 >= 0){
                    cv::Rect cvr(x,y,width,height);
                    m = m(cvr);
                    BOOL valid;
                    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
                    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:key];
                    valid = [alphaNums isSupersetOfSet:inStringSet];
                    if (valid) //numeric
                    {
                        int num = key.intValue;
                        NSString *formattedName =[NSString stringWithFormat:@"crop_frame%08d_gID%06d_x%04d_y%04d_w%04d_h%04d",frameNumber,num,cvr.x,cvr.y,cvr.width,cvr.height];
                        saveImgPath = [[cropFilePath stringByAppendingPathComponent:formattedName] stringByAppendingPathExtension:@"png"];
                        if (false or !videoMode)
                        {
                            //                            saveImgPath = [[cropFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"Cropped%i_%@",j,[[framePathForFrameNum objectForKey:@(frameNumber)] lastPathComponent]]] stringByAppendingPathExtension:@"png"];
                            saveImgPath = [[cropFilePath stringByAppendingPathComponent:formattedName] stringByAppendingPathExtension:@"png"];
                        }
                    }
                    else //named without numbers
                    {
                        NSString *formattedName = [NSString stringWithFormat:@"crop_frame%08d_gID%@_x%04d_y%04d_w%04d_h%04d",frameNumber,key,cvr.x,cvr.y,cvr.width,cvr.height];
                        saveImgPath = [[cropFilePath stringByAppendingPathComponent:formattedName] stringByAppendingPathExtension:@"png"];
                        if (false or !videoMode)
                        {
                            //                            saveImgPath = [[cropFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",[framePathForFrameNum objectForKey:@(frameNumber)],formattedName]] stringByAppendingPathExtension:@"png"];
                            saveImgPath = [[cropFilePath stringByAppendingPathComponent:formattedName] stringByAppendingPathExtension:@"png"];
                        }
                    }
                    
                    [rectOutputLog appendFormat:@"%i,%@,%i,%i,%i,%i,%@\n",frameNumber,key,(int)r.origin.x,(int)r.origin.y,(int)r.size.width,(int)r.size.height,saveImgPath.lastPathComponent];
                    cv::imwrite(saveImgPath.UTF8String, m);
                    //                    NSLog(@"written %i,%i,%i,%i",x,y,width,height);
                }
            }
            
        }
        BOOL CropFileFolderExists;
        if ([fm fileExistsAtPath:cropFilePath isDirectory:&CropFileFolderExists] && CropFileFolderExists) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"Choose New Location"];
            [alert addButtonWithTitle:@"Save Here"];
            [alert addButtonWithTitle:@"Cancel"];
            [alert setMessageText:[NSString stringWithFormat:@"A folder at %@ already exists.  Would you like to chose a different folder?",cropFilePath]];
            [alert setInformativeText:@"You may overwrite previous files in this folder"];
            [alert setAlertStyle:NSWarningAlertStyle];
            NSInteger modalOut =  [alert runModal];
            if (modalOut == NSAlertFirstButtonReturn) {
            chooseFolder: NSOpenPanel* openDlg = [NSOpenPanel openPanel];
                [openDlg setCanChooseFiles:YES];
                [openDlg setCanChooseDirectories:YES];
                [openDlg setCanCreateDirectories:YES];
                [openDlg setAllowsMultipleSelection:NO];
                [openDlg setPrompt:@"Save"];
                if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton )
                {
                    NSString *newSaveLocation = [openDlg filename];
                    if ([fm fileExistsAtPath:newSaveLocation isDirectory:&CropFileFolderExists] && !CropFileFolderExists) {
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert addButtonWithTitle:@"OK"];
                        [alert setMessageText:[NSString stringWithFormat:@"You must chose a folder to save to, not a file"]];
                        [alert setAlertStyle:NSWarningAlertStyle];
                        if ([alert runModal] == NSAlertFirstButtonReturn) {
                            goto chooseFolder;
                        }
                    }
                    else
                    {
                        cropFilePath = newSaveLocation;
                    }
                }
                
            }
            else if(modalOut == NSAlertThirdButtonReturn)
            {
                return;
            }
            
        }
        [rectOutputLog writeToFile:[[cropFilePath stringByAppendingPathComponent:@"log"] stringByAppendingPathExtension:@"csv"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        savingStatusLabel.stringValue = [NSString stringWithFormat:@"Crops saved to: %@",cropFilePath];
    }
    
}


-(IBAction)openProject:(id)sender
{
    savingStatusLabel.stringValue = @"Opening Files...";
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setPrompt:@"Open"];
    if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray* files = [openDlg filenames];
        BOOL isdir;
        if ([fm fileExistsAtPath:[files objectAtIndex:0] isDirectory:&isdir] and !isdir) {
            [self loadProjectFile:[files objectAtIndex:0]];
        }
    }
}

-(void)clearCurrentProject
{
    [frameForFrameNumber removeAllObjects];
    [framePathForFrameNum removeAllObjects];
    [annotationsForFrames removeAllObjects];
    [imagePathArray removeAllObjects];
}


-(void)loadProjectFile:(NSString *)projFilePath
{
    NSString *projectName = [[projFilePath lastPathComponent] stringByDeletingPathExtension];
    savingStatusLabel.stringValue = [NSString stringWithFormat:@"Loading Project %@", projectName];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isdir;
    if ([fm fileExistsAtPath:projFilePath isDirectory:&isdir] and !isdir and [projFilePath hasSuffix:@"saproj"]) {
        [self clearCurrentProject];
        NSString *projectCSVString = [NSString stringWithContentsOfFile:projFilePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *projectLines = [projectCSVString componentsSeparatedByString:@"\n"];
        if (projectLines.count > 0) {
            int frameCounter = 0;
            bool shouldSkipFile = false;
            bool startNewFile = false;
            NSArray *projectOriginationPath = [projectLines objectAtIndex:0];
            NSMutableArray *propertyKeys = [[NSMutableArray alloc] init];
            NSMutableArray *allAnnotations = [[NSMutableArray alloc] init];
            NSMutableArray *allFileNames = [[NSMutableArray alloc] init];
            NSMutableDictionary *allAnnotationsForFileName = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *annotationsForSingleFile = [[NSMutableDictionary alloc] init];
            //Build the initial dictionary containing all entries
            NSString *currentFileName = @"";
            int i = 1;
            int resumeFrameNum = 0;
            for(i = 1; i < projectLines.count; i++)
            {
                NSArray *lineValues = [[projectLines objectAtIndex:i] componentsSeparatedByString:@","];
                if (lineValues.count > 0 and [[lineValues objectAtIndex:0]hasPrefix:@"Frame:"]) {
                    NSArray *frameResumeArr = [[lineValues objectAtIndex:0] componentsSeparatedByString:@":"];
                    if (frameResumeArr.count > 1) {
                        resumeFrameNum = [[frameResumeArr objectAtIndex:1] intValue];
                    }
                }
                if (lineValues.count > 0 and [[lineValues objectAtIndex:0] hasPrefix:@"f:"]) { //this starts a new file
                    if (allAnnotations.count > 0)
                    {
                        [allAnnotationsForFileName setObject:allAnnotations.copy forKey:currentFileName];
                    }
                    [allAnnotations removeAllObjects];
                    currentFileName = [[lineValues objectAtIndex:0] substringFromIndex:2];
                    [imagePathArray addObject:currentFileName];
                    [allFileNames addObject:currentFileName];
                    startNewFile = true;
                }
                else if (lineValues.count > 1){
                    if (startNewFile) {
                        startNewFile = false;
                        [propertyKeys removeAllObjects];
                        [propertyKeys addObjectsFromArray:lineValues];
                        [annotationsForSingleFile removeAllObjects];
                    }
                    else{
                        NSMutableDictionary *entryDictionary = [[NSMutableDictionary alloc] init];
                        for (int j = 0; j < lineValues.count; j++) {
                            NSString *val = [lineValues objectAtIndex:j];
                            if (j < propertyKeys.count)
                            {
                                NSString *pkey = [propertyKeys objectAtIndex:j];
                                if (![val isEqualToString:@""]) {
                                    [entryDictionary setObject:val forKey:pkey];
                                }
                            }
                            
                        }
                        [allAnnotations addObject:entryDictionary];
                    }
                }
            }
            if (allAnnotations.count > 0) {
                [allAnnotationsForFileName setObject:allAnnotations.copy forKey:currentFileName];
            }
            //Build individual annotation sets for each image file
            for (int i = 0; i < allFileNames.count; i++) {
                NSString *fileName =[allFileNames objectAtIndex:i];
                NSArray *annotationsForFile = [allAnnotationsForFileName objectForKey:fileName];
                if (annotationsForFile){
                    NSMutableDictionary *annotationsByToolForFile = [[NSMutableDictionary alloc] init];
                    NSString *currentTool = @"";
                    for (int j = 0; j < annotationsForFile.count; j++) {
                        NSMutableDictionary *entry = [[annotationsForFile objectAtIndex:j] mutableCopy];
                        NSString *entryName = [entry objectForKey:@"name"];
                        NSString *toolType = [entry objectForKey:@"annotationType"];
                        if ([toolType isEqualToString:@"pointTool"]) {
                            NSMutableArray *coords = [[NSMutableArray alloc] init];
                            NSDictionary *nextEntry = [annotationsForFile objectAtIndex:j+1];
                            while(j+1 < annotationsForFile.count and nextEntry and ([nextEntry objectForKey:@"name"] == nil or [[nextEntry objectForKey:@"name"] isEqualToString:@""]))
                            {
                                NSPoint p = NSMakePoint([[nextEntry objectForKey:@"x coord"] floatValue], [[nextEntry objectForKey:@"y coord"] floatValue]);
                                
                                [coords addObject:[NSValue valueWithPoint:p]];
                                j++;
                                if (j+1 >= annotationsForFile.count) {
                                    nextEntry = nil;
                                }
                                else
                                {
                                    nextEntry = [annotationsForFile objectAtIndex:j+1];
                                }
                            }
                            //                        j++;
                            [entry setObject:coords forKey:@"coords"];
                        }
                        NSMutableDictionary *toolAnnotationEntries;
                        if ([annotationsByToolForFile objectForKey:toolType]) {
                            toolAnnotationEntries = [annotationsByToolForFile objectForKey:toolType];
                        }
                        else
                        {
                            toolAnnotationEntries = [[NSMutableDictionary alloc] init];
                            [annotationsByToolForFile setObject:toolAnnotationEntries forKey:toolType];
                        }
                        [toolAnnotationEntries setObject:entry forKey:[entry objectForKey:@"name"]];
                    }
                    if (i == 0)
                    {
                        cv::Mat img = cv::imread(fileName.UTF8String);
                        
                        if (img.empty()) {
                            NSLog(@"WARNING: could not open '%@', the file is either corrupt or non-existant",fileName);
                            img = cv::Mat::eye(500, 500, CV_8UC3);
                        }
                        OpenImageHandler *imageH = [[OpenImageHandler alloc] initWithCVMat:img Color:White BinaryImage:false];
                        [frameForFrameNumber setObject:imageH forKey:@(i)];
                    }
                    [framePathForFrameNum setObject:fileName forKey:@(i)];
                    [annotationsForFrames setObject:annotationsByToolForFile forKey:@(i)];
                }
            }
            numFrames = allFileNames.count;
            //            OpenImageHandler *img = [frameForFrameNumber objectForKey:@(0)];
            //            [GLViewListCommand AddObject:img ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
            //            [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
            //            [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",0,framePathForFrameNum.count]];
            justLoadedNewProject = true;
            [self GoToFrame:0];
            if (resumeFrameNum >= 0 and resumeFrameNum < allFileNames.count) {
                [self GoToFrame:resumeFrameNum];
            }
            
        }
    }
}


-(void)extractPatchesFromProjectFile:(NSString *)projFilePath
{
    int normalFaceWidthPx = 800;
    int sampleDivision = 20;
    float boxPercent = .10; // We will be creating boxes that are 5% of the face (20 boxes wide)
    
    Landmarker_zhuramanan *landmarker = new Landmarker_zhuramanan();
    Model3D *model = new Model3D("");
    NSString *projectName = [[projFilePath lastPathComponent] stringByDeletingPathExtension];
    //    savingStatusLabel.stringValue = [NSString stringWithFormat:@"Loading Project %@", projectName];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isdir;
    if ([fm fileExistsAtPath:projFilePath isDirectory:&isdir] and !isdir and [projFilePath hasSuffix:@"saproj"]) {
        NSString *projectCSVString = [NSString stringWithContentsOfFile:projFilePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *projectLines = [projectCSVString componentsSeparatedByString:@"\n"];
        if (projectLines.count > 0) {
            int frameCounter = 0;
            bool shouldSkipFile = false;
            bool startNewFile = false;
            NSArray *projectOriginationPath = [projectLines objectAtIndex:0];
            NSMutableArray *propertyKeys = [[NSMutableArray alloc] init];
            NSMutableArray *allAnnotations = [[NSMutableArray alloc] init];
            NSMutableArray *allFileNames = [[NSMutableArray alloc] init];
            NSMutableDictionary *allAnnotationsForFileName = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *annotationsForSingleFile = [[NSMutableDictionary alloc] init];
            //Build the initial dictionary containing all entries
            NSString *currentFileName = @"";
            int i = 1;
            int resumeFrameNum = 0;
            for(i = 1; i < projectLines.count; i++)
            {
                NSArray *lineValues = [[projectLines objectAtIndex:i] componentsSeparatedByString:@","];
                if (lineValues.count > 0 and [[lineValues objectAtIndex:0]hasPrefix:@"Frame:"]) {
                    NSArray *frameResumeArr = [[lineValues objectAtIndex:0] componentsSeparatedByString:@":"];
                    if (frameResumeArr.count > 1) {
                        resumeFrameNum = [[frameResumeArr objectAtIndex:1] intValue];
                    }
                }
                if (lineValues.count > 0 and [[lineValues objectAtIndex:0] hasPrefix:@"f:"]) { //this starts a new file
                    if (allAnnotations.count > 0)
                    {
                        [allAnnotationsForFileName setObject:allAnnotations.copy forKey:currentFileName];
                    }
                    [allAnnotations removeAllObjects];
                    currentFileName = [[lineValues objectAtIndex:0] substringFromIndex:2];
                    [imagePathArray addObject:currentFileName];
                    [allFileNames addObject:currentFileName];
                    startNewFile = true;
                }
                else if (lineValues.count > 1){
                    if (startNewFile) {
                        startNewFile = false;
                        [propertyKeys removeAllObjects];
                        [propertyKeys addObjectsFromArray:lineValues];
                        [annotationsForSingleFile removeAllObjects];
                    }
                    else{
                        NSMutableDictionary *entryDictionary = [[NSMutableDictionary alloc] init];
                        for (int j = 0; j < lineValues.count; j++) {
                            NSString *val = [lineValues objectAtIndex:j];
                            if (j < propertyKeys.count)
                            {
                                NSString *pkey = [propertyKeys objectAtIndex:j];
                                if (![val isEqualToString:@""]) {
                                    [entryDictionary setObject:val forKey:pkey];
                                }
                            }
                            
                        }
                        [allAnnotations addObject:entryDictionary];
                    }
                }
            }
            if (allAnnotations.count > 0) {
                [allAnnotationsForFileName setObject:allAnnotations.copy forKey:currentFileName];
            }
            //Build individual annotation sets for each image file
            for (int i = 0; i < allFileNames.count; i++) {
                NSString *fileName =[allFileNames objectAtIndex:i];
                cv::Mat img = cv::imread(fileName.UTF8String);
                NSArray *annotationsForFile = [allAnnotationsForFileName objectForKey:fileName];
                if (annotationsForFile){
                    NSMutableDictionary *annotationsByToolForFile = [[NSMutableDictionary alloc] init];
                    NSString *currentTool = @"";
                    std::vector<cv::Rect> facesInImage;
                    NSMutableArray *skipIndexes = [[NSMutableArray alloc] init];
                    for (int j = 0; j < annotationsForFile.count; j++) {
                        NSMutableDictionary *entry = [[annotationsForFile objectAtIndex:j] mutableCopy];
                        NSString *entryName = [entry objectForKey:@"name"];
                        NSString *toolType = [entry objectForKey:@"annotationType"];
                        NSString *typeName = [[entry objectForKey:@"type"] lowercaseString];
                        if (typeName != nil and ( [typeName isEqualToString:@"face"] or [typeName hasPrefix:@"face"] or [typeName rangeOfString:@"face"].location != NSNotFound)){
                            cv::Rect f([[entry objectForKey:@"x coord"] intValue],[[entry objectForKey:@"y coord"] intValue],[[entry objectForKey:@"width"] intValue],[[entry objectForKey:@"height"] intValue]);
                            facesInImage.push_back(f);
                            if(typeName != nil and [typeName rangeOfString:@"face"].location != NSNotFound and [typeName rangeOfString:@"full"].location != NSNotFound)
                            {
                                //This is a full face tatoo annotation.  We should extract this.
                                NSLog(@"found full face tattoo");
                            }
                            else{
                                [skipIndexes addObject:@(j)];
                            }
                        }
                        
                    }
                    if (!img.empty() && img.cols > 0 && img.rows > 0) {
                        cv::imshow("image", img);
                    }
                    
                    if (facesInImage.size() == 0) {
                        facesInImage = [self findFacesUsingDlibInFrame:img];
                        NSLog(@"Found %lu dlib faces",facesInImage.size());
                    }
                    if (facesInImage.size() == 0) {
                        std::vector<bbox_t> faceboxes;
                        NSLog(@"Detecting Faces");
                        std::vector<std::vector<cv::Point> > faceLandmarks = landmarker->findLandmarks(img,faceboxes);
                        
                        NSLog(@"Found %lu zr faces", faceLandmarks.size());
                        for(int j = 0; j < faceboxes.size(); j++)
                        {
                            bbox_t box = faceboxes[j];
                            cv::Rect r(box.outer.x1,box.outer.y1,box.outer.x2-box.outer.x1,box.outer.y2-box.outer.y1);
                            facesInImage.push_back(r);
                        }
                    }
                    for (int j = 0; j < annotationsForFile.count; j++) {
                        if ([skipIndexes containsObject:@(j)]) {
                            continue;
                        }
                        NSMutableDictionary *entry = [[annotationsForFile objectAtIndex:j] mutableCopy];
                        NSString *entryName = [entry objectForKey:@"name"];
                        NSString *toolType = [entry objectForKey:@"annotationType"];
                        if ([toolType isEqualToString:@"pointTool"]) {
                            NSMutableArray *coords = [[NSMutableArray alloc] init];
                            NSDictionary *nextEntry = [annotationsForFile objectAtIndex:j+1];
                            while(j+1 < annotationsForFile.count and nextEntry and ([nextEntry objectForKey:@"name"] == nil or [[nextEntry objectForKey:@"name"] isEqualToString:@""]))
                            {
                                NSPoint p = NSMakePoint([[nextEntry objectForKey:@"x coord"] floatValue], [[nextEntry objectForKey:@"y coord"] floatValue]);
                                
                                [coords addObject:[NSValue valueWithPoint:p]];
                                j++;
                                if (j+1 >= annotationsForFile.count) {
                                    nextEntry = nil;
                                }
                                else
                                {
                                    nextEntry = [annotationsForFile objectAtIndex:j+1];
                                }
                            }
                            //                        j++;
                            [entry setObject:coords forKey:@"coords"];
                        }
                        cv::Mat imageChip;
                        std::vector<cv::Mat>imageChips;
                        NSMutableArray *imageChipNames = [[NSMutableArray alloc] init];
                        
                        
                        if ([toolType isEqualToString:@"pointTool"]) {
                            NSArray *coords = [entry objectForKey:@"coords"];
                            std::vector<std::vector<cv::Point> > conts;
                            std::vector<cv::Point > cont;
                            for(int x = 0; x < coords.count; x++)
                            {
                                NSPoint p = [[coords objectAtIndex:x] pointValue];
                                cont.push_back(cv::Point(p.x,p.y));
                            }
                            conts.push_back(cont);
                            cv::Rect roi = cv::boundingRect(cont);
                            if (roi.x >=0 and roi.y >= 0 and roi.x < img.cols and roi.y < img.rows and roi.x+roi.width < img.cols and roi.y+roi.height < img.rows)
                            {
                                //                            NSLog(@"x: %i y:%i W:%i H:%i",roi.x,roi.y,roi.width,roi.height);
                                int maxoverlap = 0;
                                int maxoverlapIndex = -1;
                                //calcualte what face the given annoation belongs to via how much the annotation overlaps with the faces in the image
                                for (int k = 0; k < facesInImage.size(); k++) {
                                    cv::Rect faceWithForhead(facesInImage[k].x,facesInImage[k].y-facesInImage[k].height*.40,facesInImage[k].width,facesInImage[k].height*1.4);
                                    int overlaparea = calculateIntersectionArea(cv::Mat::zeros(img.rows, img.cols, CV_8UC1), faceWithForhead, cont);
                                    if (overlaparea > maxoverlap)
                                    {
                                        maxoverlap = overlaparea;
                                        maxoverlapIndex = k;
                                    }
                                }
                                int faceWidth = -1;
                                if (maxoverlapIndex == -1)
                                {
                                    //doesnt belong to a face at all
                                    faceWidth = 100;
                                }
                                else{
                                    faceWidth = facesInImage[maxoverlapIndex].width;
                                }
                                float scalefactor = normalFaceWidthPx*(1.0)/faceWidth;
                                cv::Mat mask = cv::Mat::zeros(img.rows, img.cols, CV_8UC1);
                                cv::drawContours(mask, conts, 0, 255,-1);
                                img.copyTo(imageChip);
                                
                                cv::Rect roi = cv::boundingRect(cont);
                                imageChip = imageChip(roi).clone();
                                mask = mask(roi).clone();
                                
                                //                            cv::resize(imageChip, imageChip, cv::Size(imageChip.cols*scalefactor,imageChip.rows*scalefactor));
                                //                            cv::imshow("image",img);
                                NSLog(@"Face Width: %i",faceWidth);
                                std::vector<cv::Mat> fillChips;
                                cv::Mat rotatedChip, rotatedMask,sizedChip,sizedMask;
                                //Normalize the chip to contain the face at 800px wide
                                cv::Size resizedSize(imageChip.cols*scalefactor,imageChip.rows*scalefactor);
                                if (resizedSize.width > 0 and resizedSize.height > 0 and !imageChip.empty() && imageChip.cols > 0 && imageChip.rows > 0) {
                                    cv::resize(imageChip, sizedChip,resizedSize);
                                    cv::resize(mask, sizedMask,resizedSize);
                                    int roiWidth =normalFaceWidthPx*boxPercent;
                                    int roiHeight =normalFaceWidthPx*boxPercent;
                                    
                                    
                                    int counter = 0;
                                    for(int r = -30; r <= 30; r+=15)
                                    {
                                        cv::Point2f rcenter(sizedChip.cols/2.0,sizedChip.rows/2.0);
                                        cv::Mat rmat = cv::getRotationMatrix2D(rcenter, r, 1);
                                        cv::warpAffine(sizedChip, rotatedChip, rmat, sizedChip.size());
                                        cv::warpAffine(sizedMask, rotatedMask, rmat, sizedMask.size());
                                        cv::threshold(rotatedMask, rotatedMask, 127, 255, CV_8UC1);
                                        for(int y = 0; y < rotatedChip.rows-roiHeight; y+=(roiWidth*1.0)/5)
                                        {
                                            for(int x = 0; x < rotatedChip.cols-roiWidth; x+=(roiWidth*1.0)/5)
                                            {
                                                cv::Rect r(x,y,roiWidth,roiHeight);
                                                if (r.x >= 0 && r.y >= 0 && r.x+r.width < rotatedChip.cols && r.y+r.height < rotatedChip.rows ) {
                                                    cv::Mat overlap = rotatedMask(r).clone();
                                                    int nonzero = cv::countNonZero(overlap);
                                                    if (nonzero > int(overlap.cols*overlap.rows*1.0/1.5)) {
                                                        //this rect doesn't contain areas of masked out sace
                                                        if ([[[entry objectForKey:@"type"] lowercaseString] rangeOfString:@"tattoo"].location != NSNotFound) {
                                                            imageChips.push_back(rotatedChip(r).clone());
                                                            NSString *saveName = [[[fileName stringByDeletingPathExtension] stringByAppendingFormat:@"_%@_%@_%i",[entry objectForKey:@"type"],entryName,counter] stringByAppendingPathExtension:@".png"];
                                                            [imageChipNames addObject:saveName];
                                                            //                                            cv::imshow("chip", rotatedChip(r).clone());
                                                            //                                            cv::waitKey();
                                                            counter++;
                                                            
                                                        }
                                                        //                                            fillChips.push_back(rotatedChip(r).clone());
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                    //                            for(int y = 0; y < imageChip.rows-roiHeight; y++)
                                    //                            {
                                    //                                for(int x = 0; x < imageChip.cols-roiWidth; x++)
                                    //                                {
                                    //                                    cv::Rect r(x,y,roiWidth,roiHeight);
                                    //                                    cv::Mat overlap = mask(r).clone();
                                    //                                    int nonzero = cv::countNonZero(overlap);
                                    //                                    if (nonzero == overlap.cols*overlap.rows) {
                                    //                                        //this rect doesn't contain areas of masked out sace
                                    //                                        fillChips.push_back(imageChip(r).clone());
                                    //                                    }
                                    //                                }
                                    //                            }
                                    //                            cv::Mat filledImageChip = cv::Mat::zeros(imageChip.rows*(1+boxPercent), imageChip.cols*(1+boxPercent), CV_8UC3);
                                    //                            for(int y = 0; y < filledImageChip.rows-roiHeight; y+=roiHeight)
                                    //                            {
                                    //                                for(int x = 0; x < filledImageChip.cols-roiWidth; x+=roiWidth)
                                    //                                {
                                    //                                    cv::Rect r(x,y,roiWidth,roiHeight);
                                    //                                    fillChips[arc4random() % fillChips.size()-1].copyTo(filledImageChip(r));
                                    //
                                    //                                }
                                    //                            }
                                    //                            cv::Mat fillImagetmp;
                                    //                            filledImageChip = filledImageChip(cv::Rect(0,0,imageChip.cols,imageChip.rows)).clone();
                                    //                            filledImageChip.copyTo(fillImagetmp, 255-mask);
                                    //                            imageChip+=fillImagetmp;
                                    //                            cv::imshow("chip_patched", imageChip);
                                    //                            cv::waitKey();
                                }
                            }
                        }
                        else if ([toolType isEqualToString:@"rectangleTool"])
                        {
                            cv::Rect roi([[entry objectForKey:@"x coord"] intValue],[[entry objectForKey:@"y coord"] intValue], [[entry objectForKey:@"width"] intValue], [[entry objectForKey:@"height"] intValue]);
                            int maxoverlap = 0;
                            int maxoverlapIndex = -1;
                            //calcualte what face the given annoation belongs to via how much the annotation overlaps with the faces in the image
                            for (int k = 0; k < facesInImage.size(); k++) {
                                cv::Rect faceWithForhead(facesInImage[k].x,facesInImage[k].y-facesInImage[k].height*.40,facesInImage[k].width,facesInImage[k].height*1.4);
                                int overlaparea = calculateIntersectionArea(cv::Mat::zeros(img.rows, img.cols, CV_8UC1), faceWithForhead, roi);
                                if (overlaparea > maxoverlap)
                                {
                                    maxoverlap = overlaparea;
                                    maxoverlapIndex = k;
                                }
                            }
                            int faceWidth = -1;
                            if (maxoverlapIndex == -1)
                            {
                                //doesnt belong to a face at all
                                faceWidth = 100;
                            }
                            else{
                                faceWidth = facesInImage[maxoverlapIndex].width;
                            }
                            float scalefactor = normalFaceWidthPx*(1.0)/faceWidth;
                            
                            imageChip = img.clone();
                            
                            cv::Mat rotatedChip, rotatedMask,sizedChip,sizedMask;
                            //Normalize the chip to contain the face at 800px wide
                            cv::Size resizedSize(imageChip.cols*scalefactor,imageChip.rows*scalefactor);
                            if (resizedSize.width > 0 and resizedSize.height > 0 and !imageChip.empty() && imageChip.cols > 0 && imageChip.rows > 0) {
                                cv::resize(imageChip, sizedChip,cv::Size(imageChip.cols*scalefactor,imageChip.rows*scalefactor));
                                roi.x *= scalefactor;
                                roi.y *= scalefactor;
                                roi.width *= scalefactor;
                                roi.height *= scalefactor;
                                int roiWidth =roi.width;
                                int roiHeight =roi.height;
                                NSMutableDictionary *entry = [[annotationsForFile objectAtIndex:j] mutableCopy];
                                NSString *typeName = [[entry objectForKey:@"type"] lowercaseString];
                                //                        if(typeName != nil and [typeName rangeOfString:@"face"].location != NSNotFound and [typeName rangeOfString:@"full"].location != NSNotFound)
                                //                        {
                                roiWidth =normalFaceWidthPx*boxPercent;
                                roiHeight =normalFaceWidthPx*boxPercent;
                                //                        }
                                
                                
                                
                                int counter = 0;
                                for(int r = -30; r <= 30; r+=15)
                                {
                                    NSLog(@"extracting chips at rotation %i",r);
                                    cv::Point2f rCenter(roi.x+roi.width/2,roi.y+roi.height/2);
                                    cv::Mat rmat = cv::getRotationMatrix2D(rCenter, r, 1);
                                    cv::warpAffine(sizedChip, rotatedChip, rmat, sizedChip.size());
                                    cv::Point rotatedCenter(rmat.at<double>(0,0)*rCenter.x + rmat.at<double>(0,1)*rCenter.y + rmat.at<double>(0,2),rmat.at<double>(1,0)*rCenter.x + rmat.at<double>(1,1)*rCenter.y + rmat.at<double>(1,2));
                                    cv::Point2f rotatedStart(rotatedCenter.x-roi.width*1.0/2,rotatedCenter.y-roi.height*1.0/2);
                                    int startX = rotatedStart.x-roi.width/2;
                                    int startY = rotatedStart.y-roi.height/2;
                                    if (startX < 0) startX = rotatedStart.x;
                                    if (startY < 0) startY = rotatedStart.y;
                                    for(int y = startY; y < rotatedChip.rows-roiHeight and y < rotatedStart.y+roi.height/2 ; y+=(roiWidth*1.0)/5)
                                    {
                                        for(int x = startX; x < rotatedChip.cols-roiWidth and x < rotatedStart.x+roi.width/2; x+=(roiWidth*1.0)/5)
                                        {
                                            cv::Rect r(x,y,roiWidth,roiHeight);
                                            if (true) {
                                                //this rect doesn't contain areas of masked out sace
                                                if (r.x >= 0 && r.y >= 0 && r.x+r.width < rotatedChip.cols && r.y+r.height < rotatedChip.rows ) {
                                                    if ([[[entry objectForKey:@"type"] lowercaseString] rangeOfString:@"tattoo"].location != NSNotFound or true) {
                                                        
                                                        imageChips.push_back(rotatedChip(r).clone());
                                                        NSString *saveName = [[[fileName stringByDeletingPathExtension] stringByAppendingFormat:@"_%@_%@_%i",[entry objectForKey:@"type"],entryName,counter] stringByAppendingPathExtension:@".png"];
                                                        [imageChipNames addObject:saveName];
                                                        counter++;
                                                    }
                                                }
                                                //                                            fillChips.push_back(rotatedChip(r).clone());
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else if ([toolType isEqualToString:@"ellipseTool"])
                        {
                            cv::Rect roi([[entry objectForKey:@"x coord"] intValue],[[entry objectForKey:@"y coord"] intValue], [[entry objectForKey:@"width"] intValue], [[entry objectForKey:@"height"] intValue]);
                            imageChip = img(roi).clone();
                        }
                        //                        NSString *saveDir = [[fileName stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"SavedChips"];
                        NSString *saveDir = [@"/Users/bog/Desktop" stringByAppendingPathComponent: fileName.stringByDeletingLastPathComponent.lastPathComponent];
                        BOOL isDir;
                        if (![[NSFileManager defaultManager] fileExistsAtPath:saveDir isDirectory:&isDir] or !isDir) {
                            [[NSFileManager defaultManager] createDirectoryAtPath:saveDir withIntermediateDirectories:YES attributes:nil error:nil];
                        }
                        if (imageChips.size() == 0) {
                            //                            NSLog(@"on ho");
                        }
                        //                        NSLog(@"Writing %lu files...",imageChips.size());
                        int writecount = 0;
                        for (int x = 0; x < imageChips.size(); x++) {
                            cv::Mat im = imageChips[x];
                            NSString *savePath = [saveDir stringByAppendingPathComponent:[[imageChipNames objectAtIndex:x] lastPathComponent]];
                            //                        NSLog(@"saving to: %@",savePath);
                            cv::Scalar sum = cv::sum(im);
                            int imsum = sum[0]+sum[1]+sum[2];
                            //at max, we want 200 randomly sampled images per annotation
                            float guessnum = imageChips.size()/30.0;
                            if (guessnum < 1) guessnum = 1;
                            int randSample = arc4random() % (int)guessnum;
                            if (imsum and randSample == 0)
                            {
                                cv::imwrite(savePath.UTF8String, im);
                                writecount++;
                            }
                            else{
                                //                            NSLog(@"all dark");
                            }
                        }
                        NSLog(@"Wrote %i files",writecount);
                    }
                }
            }
            
        }
    }
}

-(void)extractNonTattooPatchesFromProjectFile:(NSString *)projFilePath
{
    int normalFaceWidthPx = 800;
    int sampleDivision = 20;
    float boxPercent = .10; // We will be creating boxes that are 5% of the face (20 boxes wide)
    
    Landmarker_zhuramanan *landmarker = new Landmarker_zhuramanan();
    Model3D *model = new Model3D("");
    NSString *projectName = [[projFilePath lastPathComponent] stringByDeletingPathExtension];
    //    savingStatusLabel.stringValue = [NSString stringWithFormat:@"Loading Project %@", projectName];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isdir;
    if ([fm fileExistsAtPath:projFilePath isDirectory:&isdir] and !isdir and [projFilePath hasSuffix:@"saproj"]) {
        NSString *projectCSVString = [NSString stringWithContentsOfFile:projFilePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *projectLines = [projectCSVString componentsSeparatedByString:@"\n"];
        if (projectLines.count > 0) {
            int frameCounter = 0;
            bool shouldSkipFile = false;
            bool startNewFile = false;
            NSArray *projectOriginationPath = [projectLines objectAtIndex:0];
            NSMutableArray *propertyKeys = [[NSMutableArray alloc] init];
            NSMutableArray *allAnnotations = [[NSMutableArray alloc] init];
            NSMutableArray *allFileNames = [[NSMutableArray alloc] init];
            NSMutableDictionary *allAnnotationsForFileName = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *annotationsForSingleFile = [[NSMutableDictionary alloc] init];
            //Build the initial dictionary containing all entries
            NSString *currentFileName = @"";
            int i = 1;
            int resumeFrameNum = 0;
            for(i = 1; i < projectLines.count; i++)
            {
                NSArray *lineValues = [[projectLines objectAtIndex:i] componentsSeparatedByString:@","];
                if (lineValues.count > 0 and [[lineValues objectAtIndex:0]hasPrefix:@"Frame:"]) {
                    NSArray *frameResumeArr = [[lineValues objectAtIndex:0] componentsSeparatedByString:@":"];
                    if (frameResumeArr.count > 1) {
                        resumeFrameNum = [[frameResumeArr objectAtIndex:1] intValue];
                    }
                }
                if (lineValues.count > 0 and [[lineValues objectAtIndex:0] hasPrefix:@"f:"]) { //this starts a new file
                    if (allAnnotations.count > 0)
                    {
                        [allAnnotationsForFileName setObject:allAnnotations.copy forKey:currentFileName];
                    }
                    [allAnnotations removeAllObjects];
                    currentFileName = [[lineValues objectAtIndex:0] substringFromIndex:2];
                    [imagePathArray addObject:currentFileName];
                    [allFileNames addObject:currentFileName];
                    startNewFile = true;
                }
                else if (lineValues.count > 1){
                    if (startNewFile) {
                        startNewFile = false;
                        [propertyKeys removeAllObjects];
                        [propertyKeys addObjectsFromArray:lineValues];
                        [annotationsForSingleFile removeAllObjects];
                    }
                    else{
                        NSMutableDictionary *entryDictionary = [[NSMutableDictionary alloc] init];
                        for (int j = 0; j < lineValues.count; j++) {
                            NSString *val = [lineValues objectAtIndex:j];
                            if (j < propertyKeys.count)
                            {
                                NSString *pkey = [propertyKeys objectAtIndex:j];
                                if (![val isEqualToString:@""]) {
                                    [entryDictionary setObject:val forKey:pkey];
                                }
                            }
                            
                        }
                        [allAnnotations addObject:entryDictionary];
                    }
                }
            }
            if (allAnnotations.count > 0) {
                [allAnnotationsForFileName setObject:allAnnotations.copy forKey:currentFileName];
            }
            //Build individual annotation sets for each image file
            for (int i = 0; i < allFileNames.count; i++) {
                NSString *fileName =[allFileNames objectAtIndex:i];
                cv::Mat img = cv::imread(fileName.UTF8String);
                NSArray *annotationsForFile = [allAnnotationsForFileName objectForKey:fileName];
                if (annotationsForFile and !img.empty() and img.cols > 0 and img.rows > 0){
                    NSMutableDictionary *annotationsByToolForFile = [[NSMutableDictionary alloc] init];
                    NSString *currentTool = @"";
                    std::vector<cv::Rect> facesInImage;
                    NSMutableArray *skipIndexes = [[NSMutableArray alloc] init];
                    for (int j = 0; j < annotationsForFile.count; j++) {
                        NSMutableDictionary *entry = [[annotationsForFile objectAtIndex:j] mutableCopy];
                        NSString *entryName = [entry objectForKey:@"name"];
                        NSString *toolType = [entry objectForKey:@"annotationType"];
                        NSString *typeName = [[entry objectForKey:@"type"] lowercaseString];
                        if (typeName != nil and ( [typeName isEqualToString:@"face"] or [typeName hasPrefix:@"face"] or [typeName rangeOfString:@"face"].location != NSNotFound)){
                            cv::Rect f([[entry objectForKey:@"x coord"] intValue],[[entry objectForKey:@"y coord"] intValue],[[entry objectForKey:@"width"] intValue],[[entry objectForKey:@"height"] intValue]);
                            facesInImage.push_back(f);
                            if(typeName != nil and [typeName rangeOfString:@"face"].location != NSNotFound and [typeName rangeOfString:@"full"].location != NSNotFound)
                            {
                                //This is a full face tatoo annotation.  We should extract this.
                                NSLog(@"found full face tattoo");
                                [skipIndexes addObject:@(j)];

                            }
                            else{
                                [skipIndexes addObject:@(j)];
                            }
                        }
                        
                    }
                    if (!img.empty() && img.cols > 0 && img.rows > 0) {
                        cv::imshow("image", img);
                    }
                    
                    if (facesInImage.size() == 0) {
                        facesInImage = [self findFacesUsingDlibInFrame:img];
                        NSLog(@"Found %lu dlib faces",facesInImage.size());
                    }
                    if (facesInImage.size() == 0) {
                        std::vector<bbox_t> faceboxes;
                        NSLog(@"Detecting Faces");
                        std::vector<std::vector<cv::Point> > faceLandmarks = landmarker->findLandmarks(img,faceboxes);
                        
                        NSLog(@"Found %lu zr faces", faceLandmarks.size());
                        for(int j = 0; j < faceboxes.size(); j++)
                        {
                            bbox_t box = faceboxes[j];
                            cv::Rect r(box.outer.x1,box.outer.y1,box.outer.x2-box.outer.x1,box.outer.y2-box.outer.y1);
                            facesInImage.push_back(r);
                        }
                    }
                    std::vector<std::vector<cv::Point> > conts;
                    for (int j = 0; j < annotationsForFile.count; j++) {
                        if ([skipIndexes containsObject:@(j)]) {
                            continue;
                        }
                        NSMutableDictionary *entry = [[annotationsForFile objectAtIndex:j] mutableCopy];
                        NSString *entryName = [entry objectForKey:@"name"];
                        NSString *toolType = [entry objectForKey:@"annotationType"];
                        if ([toolType isEqualToString:@"pointTool"]) {
                            NSMutableArray *coords = [[NSMutableArray alloc] init];
                            NSDictionary *nextEntry = [annotationsForFile objectAtIndex:j+1];
                            while(j+1 < annotationsForFile.count and nextEntry and ([nextEntry objectForKey:@"name"] == nil or [[nextEntry objectForKey:@"name"] isEqualToString:@""]))
                            {
                                NSPoint p = NSMakePoint([[nextEntry objectForKey:@"x coord"] floatValue], [[nextEntry objectForKey:@"y coord"] floatValue]);
                                
                                [coords addObject:[NSValue valueWithPoint:p]];
                                j++;
                                if (j+1 >= annotationsForFile.count) {
                                    nextEntry = nil;
                                }
                                else
                                {
                                    nextEntry = [annotationsForFile objectAtIndex:j+1];
                                }
                            }
                            //                        j++;
                            [entry setObject:coords forKey:@"coords"];
                        }
                        cv::Mat imageChip;
                        std::vector<cv::Mat>imageChips;
                        NSMutableArray *imageChipNames = [[NSMutableArray alloc] init];
                        
                        
                        if ([toolType isEqualToString:@"pointTool"]) {
                            NSArray *coords = [entry objectForKey:@"coords"];
                            std::vector<std::vector<cv::Point> > conts;
                            std::vector<cv::Point > cont;
                            for(int x = 0; x < coords.count; x++)
                            {
                                NSPoint p = [[coords objectAtIndex:x] pointValue];
                                cont.push_back(cv::Point(p.x,p.y));
                            }
                            conts.push_back(cont);
                            
                        }
                        else if ([toolType isEqualToString:@"rectangleTool"])
                        {
                            cv::Rect roi([[entry objectForKey:@"x coord"] intValue],[[entry objectForKey:@"y coord"] intValue], [[entry objectForKey:@"width"] intValue], [[entry objectForKey:@"height"] intValue]);
                            std::vector<cv::Point> cont;
                            cont.push_back(cv::Point(roi.x,roi.y));
                            cont.push_back(cv::Point(roi.x,roi.y+roi.height));
                            cont.push_back(cv::Point(roi.x+roi.width,roi.y+roi.height));
                            cont.push_back(cv::Point(roi.x+roi.width,roi.y));
                            conts.push_back(cont);
                        }
                        
                        
                    }
                    cv::Mat mask = cv::Mat::zeros(img.rows, img.cols, CV_8UC1);
                    cv::drawContours(mask, conts, -1, 255,-1);
                    mask = 255-mask;
                    std::vector<cv::Mat> imageChips;
                    NSMutableArray *imageChipNames = [[NSMutableArray alloc] init];
                    for(int f = 0; f < facesInImage.size(); f++)
                    {
                        cv::Rect faceROI = facesInImage[f];
                        float scalefactor = normalFaceWidthPx*(1.0)/faceROI.width;
                        if (faceROI.x >= 0 and faceROI.y >=0 and faceROI.x+faceROI.width < img.cols and faceROI.y+faceROI.height < img.rows) {
                            cv::Mat faceImgsmall = img(faceROI).clone();
                            cv::Mat faceImg,faceMasksmall,faceMask;
                            cv::Size scaleSize(faceImgsmall.cols*scalefactor,faceImgsmall.rows*scalefactor);
                            if (scaleSize.width > 0 and scaleSize.height >0 and !faceImgsmall.empty() and faceImgsmall.rows > 0 and faceImgsmall.cols > 0) {
                                cv::resize(faceImgsmall, faceImg, scaleSize);
                                faceMasksmall = mask(faceROI).clone();
                                cv::resize(faceMasksmall, faceMask, scaleSize);
                                cv::threshold(faceMask, faceMask, 127, 255, CV_8UC1);
                                int roiWidth =normalFaceWidthPx*boxPercent;
                                int roiHeight =normalFaceWidthPx*boxPercent;
                                int chipCounter = 0;
                                for(int y = 0; y < faceImg.rows-roiHeight; y+=(roiWidth*1.0)/2)
                                {
                                    for(int x = 0; x < faceImg.cols-roiWidth; x+=(roiWidth*1.0)/2)
                                    {
                                        cv::Rect r(x,y,roiWidth,roiHeight);
                                        if (r.x >= 0 && r.y >= 0 && r.x+r.width < faceImg.cols && r.y+r.height < faceImg.rows ) {
                                            cv::Mat overlap = faceMask(r).clone();
                                            int nonzero = cv::countNonZero(overlap);
                                            if (nonzero >= int(overlap.cols*overlap.rows*1.0/1.2)) {
                                                cv::Mat chip = faceImg(r).clone();
                                                NSString *saveName = [[fileName.lastPathComponent stringByDeletingPathExtension] stringByAppendingFormat:@"_%i.jpg",chipCounter];
                                                imageChips.push_back(chip);
                                                [imageChipNames addObject:saveName];
                                                chipCounter++;
                                            }
                                        }
                                    }
                                }
                                
                                
                            }
                            
                        }
                        
                        
                    }
                    NSString *saveDir = [[@"/Users/bog/Desktop" stringByAppendingPathComponent:fileName.stringByDeletingLastPathComponent.lastPathComponent] stringByAppendingString:@"non-tattoo"];
                    BOOL isDir;
                    if (![[NSFileManager defaultManager] fileExistsAtPath:saveDir isDirectory:&isDir] or !isDir) {
                        [[NSFileManager defaultManager] createDirectoryAtPath:saveDir withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    if (imageChips.size() == 0) {
                        //                            NSLog(@"on ho");
                    }
                    //                        NSLog(@"Writing %lu files...",imageChips.size());
                    int writecount = 0;
                    for (int x = 0; x < imageChips.size(); x++) {
                        cv::Mat im = imageChips[x];
                        NSString *savePath = [saveDir stringByAppendingPathComponent:[imageChipNames objectAtIndex:x]];
                        //                        NSLog(@"saving to: %@",savePath);
                        cv::Scalar sum = cv::sum(im);
                        int imsum = sum[0]+sum[1]+sum[2];
                        //at max, we want 200 randomly sampled images per annotation
                        float guessnum = imageChips.size()/50.0;
                        if (guessnum < 1) guessnum = 1;
                        int randSample = arc4random() % (int)guessnum;
                        if (imsum and randSample == 0)
                        {
                            cv::imwrite(savePath.UTF8String, im);
                            writecount++;
                        }
                        else{
                            //                            NSLog(@"all dark");
                        }
                    }
                    NSLog(@"Wrote %i files",writecount);
                    
                }
            }
            
        }
    }
}
-(std::vector<cv::Rect>)findFacesUsingDlibInFrame:(cv::Mat)img
{
    OpenImageHandler *currentImage =[frameForFrameNumber objectForKey:@(frameNum)];
    [faceDetector detectFacesInImage:currentImage atScale:0];
    std::vector<cv::Rect> faces;
    for(int i = 0; i < faceDetector.dets.size(); i++)
    {
        NSRect nsr = faceDetector.dets[i];
        cv::Rect r(nsr.origin.x,nsr.origin.y,nsr.size.width,nsr.size.height);
        //        cv::Mat face = currentImage.Cv(r).clone();
        //        OpenImageHandler *faceImage = [[OpenImageHandler alloc] initWithCVMat:face Color:Black BinaryImage:false];
        faces.push_back(r);
    }
    return faces;
}


int calculateIntersectionArea(const cv::Mat& blobImg, cv::Rect contour1, const std::vector<cv::Point> contour2)
{
    return  calculateIntersectionArea(blobImg, contour1, cv::boundingRect(contour2));
}

int calculateIntersectionArea(const cv::Mat& blobImg, cv::Rect contour1, cv::Rect contour2)
{
    cv::Mat aux1 = cv::Mat::zeros(blobImg.size(), CV_8UC1);
    cv::Mat aux2 = cv::Mat::zeros(blobImg.size(), CV_8UC1);
    cv::Mat blob = blobImg.clone();
    cv::rectangle(aux1, contour1, 255, -1, 8, 0);
    cv::rectangle(aux2, contour2, 255, -1, 8, 0);
    cv::Mat intersectionMat = aux1 & aux2;
    cv::Scalar intersectionArea = cv::sum(intersectionMat);
    return (intersectionArea[0]);
}

@end