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
    allFrames = [[NSMutableArray alloc] init];
    rectsForFrames = [[NSMutableDictionary alloc] init];
    frameForFrameNumber = [[NSMutableDictionary alloc] init];
    framePathForFrameNum = [[NSMutableDictionary alloc] init];
    viewList = [[GLViewList alloc] initWithBackupPath:@""];
    usedImagePathArray = [[NSMutableArray alloc] init];
    mainGLView.objectList = [[[GLObjectList alloc] initWithBackupPath:@""] autorelease];
    [viewList AddObject:mainGLView ForKeyPath:@"MainView"];
    mainGLOutlineView.viewList = viewList;
    [mainGLView.mouseOverController ToggleInView:mainGLView];
    frameNum = 0;
    frameSkip = 1;
    [frameSkipField setStringValue:@"1"];
    [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,1000,1000)];
    acceptableImageTypes = @[[NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.bmp'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.ppm'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.gif'"]];
    NSLog(@"loaded");
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
    int newFrameNum = frameNum-frameSkip;
    if (!videoMode) newFrameNum = frameNum-1;
    [self GoToFrame:newFrameNum];
}
- (IBAction)NextFrame:(id)sender
{
    int newFrameNum = frameNum+frameSkip;
    if (!videoMode) newFrameNum = frameNum+1;
    [self GoToFrame:newFrameNum];
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
                    [rectsForFrames setObject:mainGLView.mouseOverController.rectangleTool.getRects forKey:@(frameNum)];
                    if ([[rectsForFrames allKeys] containsObject:@(newFrameNum)]) {
                        [mainGLView.mouseOverController.rectangleTool setRects:[rectsForFrames objectForKey:@(newFrameNum)]];
                    }
                    else
                    {
                        [mainGLView.mouseOverController.tool clearAll];
                    }
                    [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
                    [GLViewListCommand AddObject:[frameForFrameNumber objectForKey:@(newFrameNum)] ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
                    //                    [mainGLView.mouseOverController.rectangleTool setCurrentFrame:[(OpenImageHandler *)[frameForFrameNumber objectForKey:@(newFrameNum)] Cv]];
                    [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",newFrameNum,numFrames]];
                    
                    stillGood = true;
                }
            }
            else
            {
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
                    [usedImagePathArray addObject:[imagePathArray objectAtIndex:i-1]];
                    OpenImageHandler *img =[[OpenImageHandler alloc] initWithCVMat:frame Color:White BinaryImage:false];
                    [framePathForFrameNum setObject:[imagePathArray objectAtIndex:i-1] forKey:@(newFrameNum)];
                    [frameForFrameNumber setObject:img forKey:@(newFrameNum)];
                    [rectsForFrames setObject:mainGLView.mouseOverController.rectangleTool.getRects forKey:@(frameNum)];
                    if ([[rectsForFrames allKeys] containsObject:@(newFrameNum)]) {
                        [mainGLView.mouseOverController.rectangleTool setRects:[rectsForFrames objectForKey:@(newFrameNum)]];
                    }
                    else
                    {
                        [mainGLView.mouseOverController.rectangleTool clearAll];
                    }
                    [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
                    [GLViewListCommand AddObject:img ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
                    //                    [mainGLView.mouseOverController.rectangleTool setCurrentFrame:[(OpenImageHandler *)[frameForFrameNumber objectForKey:@(newFrameNum)] Cv]];
                    [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%li",newFrameNum+1,imagePathArray.count]];
                    
                    stillGood = true;
                }
                
            }
            
        }
        else //this frame already exists in our cached frame list
        {
            [rectsForFrames setObject:mainGLView.mouseOverController.rectangleTool.getRects forKey:@(frameNum)]; //save current rects for current frame
            if ([[rectsForFrames allKeys] containsObject:@(newFrameNum)]) {
                [mainGLView.mouseOverController.rectangleTool setRects:[rectsForFrames objectForKey:@(newFrameNum)]]; //load new rects for next frame
            }
            OpenImageHandler *img = [frameForFrameNumber objectForKey:@(newFrameNum)];
            [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
            [GLViewListCommand AddObject:img ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
            //            [mainGLView.mouseOverController.rectangleTool setCurrentFrame:[(OpenImageHandler *)[frameForFrameNumber objectForKey:@(newFrameNum)] Cv]];
            int finalVal =numFrames;
            int displayFrameNum = newFrameNum;
            if (!videoMode){
                finalVal = imagePathArray.count;
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
                    [allFrames addObject:img];
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
            [usedImagePathArray addObject:[imagePathArray objectAtIndex:i-1]];
            OpenImageHandler *img =[[OpenImageHandler alloc] initWithCVMat:frame Color:White BinaryImage:false];
            [framePathForFrameNum setObject:[imagePathArray objectAtIndex:i-1] forKey:@(0)];
            [frameForFrameNumber setObject:img forKey:@(0)];
            [allFrames addObject:img];
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
        NSMutableDictionary* rects = [rectsForFrames objectForKey:@(i)];
       
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
            [mainGLView.mouseOverController.rectangleTool setRects:newRects]; //load new rects for next frame
            return;
        }
    }
}
- (IBAction)ClearCurrentRects:(id)sender
{
    mainGLView.mouseOverController.rectangleTool.clearAll;
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
    if (mainGLView.mouseOverController.rectangleTool.getRects.count > 0)
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
        if (files.count == 1) {
            NSString *fileName = [files objectAtIndex:0];
            BOOL isDir = NO;
            
            if( [fm fileExistsAtPath:fileName isDirectory:&isDir])
            {
                if (isDir) {
                    videoMode =false;
                    currentFilePath = [fileName retain];
                    NSArray *dirContents = [fm contentsOfDirectoryAtPath:fileName error:nil];
                    NSMutableArray *onlyImages = [[NSMutableArray alloc] init];
                    NSMutableArray *onlyImagesFullPath = [[NSMutableArray alloc] init];
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
                    imagePathArray = onlyImagesFullPath;
                    [self loadNewFrame:0];
                    OpenImageHandler *img = [allFrames objectAtIndex:frameNum];
                    //                    [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
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
                            OpenImageHandler *img = [allFrames objectAtIndex:frameNum];
                            [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
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
        else if(files.count > 1)
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
            //            OpenImageHandler *img = [allFrames objectAtIndex:frameNum];
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

- (IBAction)save:(id)sender
{
    savingStatusLabel.stringValue = @"Saving Crops...";
    if ([self shouldStoreRects]) [rectsForFrames setObject:mainGLView.mouseOverController.rectangleTool.getRects forKey:@(frameNum)];
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
        for(int i = 0; i < rectsForFrames.count;i++)
        {
            NSNumber *key = [rectsForFrames.allKeys objectAtIndex:i];
            NSDictionary *rects = [rectsForFrames objectForKey:key];
            int frameNumber = [key intValue];
            for (int j = 0; j < rects.count; j++) {
                NSString *key = [[rects allKeys] objectAtIndex:j];
                NSRect r = [[rects objectForKey:key] rectValue];
                
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
@end