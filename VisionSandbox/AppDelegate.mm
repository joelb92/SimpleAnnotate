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
    mainGLView.objectList = [[[GLObjectList alloc] initWithBackupPath:@""] autorelease];
    [viewList AddObject:mainGLView ForKeyPath:@"MainView"];
    mainGLOutlineView.viewList = viewList;
    [mainGLView.mouseOverController ToggleInView:mainGLView];
    frameNum = 0;
    frameSkip = 10;
    [frameSkipField setStringValue:@"10"];
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
    [self GoToFrame:frameNum-frameSkip];
}
- (IBAction)NextFrame:(id)sender
{
    [self GoToFrame:frameNum+frameSkip];
}

-(bool)GoToFrame:(int)newFrameNum
{
    bool stillGood = false;
    if (newFrameNum >= 0) {
        
        if (![frameForFrameNumber.allKeys containsObject:@(newFrameNum)]){//we need to get the new frame
            if (newFrameNum > frameNum) {//go forward
                int framesToJump = newFrameNum-frameNum;
                cv::Mat frame;
                for(int i = 0; i < framesToJump-1; i++)
                {
                    capture >> frame;
                    if (!frame.empty()) {
                        OpenImageHandler *img =[[OpenImageHandler alloc] initWithCVMat:frame Color:White BinaryImage:false];
                        [frameForFrameNumber setObject:img forKey:@(frameNum+i+1)];
                    }
                    else {
                        stillGood = false;
                        break;
                    }
                }
                capture >> frame;
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
                    [GLViewListCommand AddObject:[frameForFrameNumber objectForKey:@(newFrameNum)] ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
                    [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",newFrameNum,(int)capture.get(CV_CAP_PROP_FRAME_COUNT)]];
                    
                    stillGood = true;
                }
                
                
                
                
            }
            else if (newFrameNum == frameNum) NSLog(@"Warning: This is the same frame number you are on, but we don't seem to have the data stored.  Thats bad!");
            else
            {
                NSLog(@"Warning: This is the same earlier number you are on, but we don't seem to have the data stored.  Thats bad!");
            }
            
        }
        else
        {
            [rectsForFrames setObject:mainGLView.mouseOverController.rectangleTool.getRects forKey:@(frameNum)]; //save current rects for current frame
            if ([[rectsForFrames allKeys] containsObject:@(newFrameNum)]) {
                [mainGLView.mouseOverController.rectangleTool setRects:[rectsForFrames objectForKey:@(newFrameNum)]]; //load new rects for next frame
            }
            [GLViewListCommand AddObject:[frameForFrameNumber objectForKey:@(newFrameNum)] ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
            [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",newFrameNum,(int)capture.get(CV_CAP_PROP_FRAME_COUNT)]];
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
    if (capture.isOpened()) {
        cv::Mat frame;
        for(int i  = 0; i < skipAmount; i++)capture.grab();
        capture >> frame;
        cv::cvtColor(frame, frame, CV_BGR2BGRA);
        if (!frame.empty()) {
            OpenImageHandler *img =[[OpenImageHandler alloc] initWithCVMat:frame Color:White BinaryImage:false];
            [frameForFrameNumber setObject:img forKey:@(frameNum)];
            [allFrames addObject:img];
            return true;
        }
    }
    return false;
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
    [self GoToFrame:frameJumpField.intValue];
    
}

- (IBAction)OpenM:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setPrompt:@"Open"];
    if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        NSArray* files = [openDlg filenames];
        if (files.count > 0) {
            NSString *fileName = [[openDlg filenames] objectAtIndex:0];
            currentFilePath = [fileName retain];
            capture.open(fileName.UTF8String);
            [self loadNewFrame:0];
            [GLViewListCommand AddObject:[allFrames objectAtIndex:frameNum] ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
            [infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",frameNum,(int)capture.get(CV_CAP_PROP_FRAME_COUNT)]];
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
                
                OpenImageHandler *img = [allFrames objectAtIndex:frameNumber];
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
                saveImgPath = [[cropFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"crop_frame%i_gID%i_x%i_y%i_w%i_h%i",frameNum,0,cvr.x,cvr.y,cvr.width,cvr.height]] stringByAppendingPathExtension:@"png"];
                cv::imwrite(saveImgPath.UTF8String, m);
                    NSLog(@"written %i,%i,%i,%i",x,y,width,height);
                }
            }
            
        }
        [rectOutputLog writeToFile:[[cropFilePath stringByAppendingPathComponent:@"log"] stringByAppendingPathExtension:@"csv"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }
}

@end
