//
//  AppDelegate.m
//  VisionSandbox
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//
#import "AppDelegate.h"
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self splashSequence];
    allFrames = [[NSMutableArray alloc] init];
    rectsForFrames = [[NSMutableDictionary alloc] init];
    frameForFrameNumber = [[NSMutableDictionary alloc] init];
    viewList = [[GLViewList alloc] initWithBackupPath:@""];
    usedImagePathArray = [[NSMutableArray alloc] init];
    mainGLView.objectList = [[[GLObjectList alloc] initWithBackupPath:@""] autorelease];
    [viewList AddObject:mainGLView ForKeyPath:@"MainView"];
    mainGLOutlineView.viewList = viewList;
    [mainGLView.mouseOverController ToggleInView:mainGLView];
    frameNum = 0;
    frameSkip = 10;
    [frameSkipField setStringValue:@"10"];
    [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,1000,1000)];
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
                    std::cout << "Requesting frame " << noFrame << " but current position == " << currentPos << std::endl;
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
                        [mainGLView.mouseOverController.rectangleTool clearAll];
                    }
                    [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
                    [GLViewListCommand AddObject:[frameForFrameNumber objectForKey:@(newFrameNum)] ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
//                    [mainGLView.mouseOverController.rectangleTool setCurrentFrame:[(OpenImageHandler *)[frameForFrameNumber objectForKey:@(newFrameNum)] Cv]];
                    [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",newFrameNum,(int)capture.get(CV_CAP_PROP_FRAME_COUNT)]];
                    
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
            int finalVal =(int)capture.get(CV_CAP_PROP_FRAME_COUNT);
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
        frameNum = newFrameNum;
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
            
            cv::cvtColor(frame, frame, CV_BGR2BGRA);
            if (!frame.empty()) {
                OpenImageHandler *img =[[OpenImageHandler alloc] initWithCVMat:frame Color:White BinaryImage:false];
                [frameForFrameNumber setObject:img forKey:@(frameNum)];
                [allFrames addObject:img];
//                [mainGLView.mouseOverController.rectangleTool setCurrentFrame:frame];
                
                return true;
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
        if (rects && rects.count > 0) {
            [mainGLView.mouseOverController.rectangleTool setRects:rects]; //load new rects for next frame
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
    NSArray *acceptableImageTypes = @[[NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.bmp'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.ppm'"],[NSPredicate predicateWithFormat:@"self ENDSWITH '.gif'"]];
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
                    capture.open(fileName.UTF8String);
                    [self loadNewFrame:0];
                    OpenImageHandler *img = [allFrames objectAtIndex:frameNum];
                    [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
                    [GLViewListCommand AddObject:img ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
                    [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",frameNum,(int)capture.get(CV_CAP_PROP_FRAME_COUNT)]];
                }
                
                
            }
            
        }
        else if(files.count > 1)
        {
            videoMode = false;
            NSMutableArray *onlyImages = [[NSMutableArray alloc] init];
            NSMutableArray *onlyImagesFullPath = [[NSMutableArray alloc] init];
            for(NSPredicate *fltr in acceptableImageTypes)
            {
                [onlyImages addObjectsFromArray:[files filteredArrayUsingPredicate:fltr]];
            }
            imagePathArray = onlyImages;
            [self loadNewFrame:0];
            OpenImageHandler *img = [allFrames objectAtIndex:frameNum];
//            [mainGLView setMaxImageSpaceRect:vector2Rect(0,0,img.size.width,img.size.height)];
            [GLViewListCommand AddObject:img ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
            [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%li",1,imagePathArray.count]];
        }
    }
}
- (IBAction)save:(id)sender
{
    if ([self shouldStoreRects]) [rectsForFrames setObject:mainGLView.mouseOverController.rectangleTool.getRects forKey:@(frameNum)];
    NSMutableString *rectOutputLog = [@"Frame,Rectagle Key,X,Y,Width,Height\n" mutableCopy];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (currentFilePath) {
        NSString *cropFilePath = [[currentFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"pedestrianCrops"];
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
                [rectOutputLog appendFormat:@"%i,%@,%i,%i,%i,%i\n",frameNumber,key,(int)r.origin.x,(int)r.origin.y,(int)r.size.width,(int)r.size.height];
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
                        if (!videoMode)
                        {
                            saveImgPath = [[cropFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"Cropped%i_%@",j,[[usedImagePathArray objectAtIndex:i] lastPathComponent]]] stringByAppendingPathExtension:@"png"];
                        }
                    }
                    else
                    {
                        NSString *formattedName = [NSString stringWithFormat:@"crop_frame%08d_gID%@_x%04d_y%04d_w%04d_h%04d",frameNumber,key,cvr.x,cvr.y,cvr.width,cvr.height];
                        saveImgPath = [[cropFilePath stringByAppendingPathComponent:formattedName] stringByAppendingPathExtension:@"png"];
                        if (!videoMode)
                        {
                            saveImgPath = [[cropFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",[usedImagePathArray objectAtIndex:i],formattedName]] stringByAppendingPathExtension:@"png"];
                        }
                    }
                    cv::imwrite(saveImgPath.UTF8String, m);
                    //                    NSLog(@"written %i,%i,%i,%i",x,y,width,height);
                }
            }
            
        }
        [rectOutputLog writeToFile:[[cropFilePath stringByAppendingPathComponent:@"log"] stringByAppendingPathExtension:@"csv"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }
}

@end
