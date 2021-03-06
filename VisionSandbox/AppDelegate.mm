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
	allFrames = [[NSMutableArray alloc] init];
	rectsForFrames = [[NSMutableDictionary alloc] init];
	viewList = [[GLViewList alloc] initWithBackupPath:@""];
	mainGLView.objectList = [[[GLObjectList alloc] initWithBackupPath:@""] autorelease];
	[viewList AddObject:mainGLView ForKeyPath:@"MainView"];
	mainGLOutlineView.viewList = viewList;
	[mainGLView.mouseOverController ToggleInView:mainGLView];
	frameNum = 0;
	frameSkip = 10;
	[frameSkipField setStringValue:@"10"];
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
	if (frameNum > 0) {
		if ([self shouldStoreRects]) [rectsForFrames setObject:mainGLView.mouseOverController.rectangleTool.getRects forKey:@(frameNum)];
		frameNum--;
		if ([[rectsForFrames allKeys] containsObject:@(frameNum)]) {
			[mainGLView.mouseOverController.rectangleTool setRects:[rectsForFrames objectForKey:@(frameNum)]];
		}
		[GLViewListCommand AddObject:[allFrames objectAtIndex:frameNum] ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
		[infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",frameNum*(frameSkip),(int)capture.get(CV_CAP_PROP_FRAME_COUNT)]];
	}
}
- (IBAction)NextFrame:(id)sender
{
	bool goodFrame = true;
	if (frameNum == allFrames.count-1 && frameNum < allFrames.count) {
		goodFrame = [self loadNewFrame:frameSkip]; //goodframe will be true only if the frame is already loaded or a new frame is loadable
	}
	if (goodFrame && allFrames.count > 0) { //If the frame hasn't already been loaded
		if ([self shouldStoreRects]) [rectsForFrames setObject:mainGLView.mouseOverController.rectangleTool.getRects forKey:@(frameNum)];
		frameNum++;
		if ([[rectsForFrames allKeys] containsObject:@(frameNum)]) {
			[mainGLView.mouseOverController.rectangleTool setRects:[rectsForFrames objectForKey:@(frameNum)]];
		}
		[GLViewListCommand AddObject:[allFrames objectAtIndex:frameNum] ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
		[infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",frameNum*(frameSkip),(int)capture.get(CV_CAP_PROP_FRAME_COUNT)]];
		
	}
	else{
		isPlaying = false;
	}
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

- (IBAction)OpenM:(id)sender
{
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	[openDlg setCanChooseFiles:YES];
	[openDlg setCanChooseDirectories:YES];
	[openDlg setPrompt:@"Open"];
	if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton )
	{
		NSArray* files = [openDlg filenames];
		NSString *fileName = [[openDlg filenames] objectAtIndex:0];
		currentFilePath = [fileName retain];
		capture.open(fileName.UTF8String);
		[self loadNewFrame:0];
		[GLViewListCommand AddObject:[allFrames objectAtIndex:frameNum] ToViewKeyPath:@"MainView" ForKeyPath:@"First"];
		[infoOutput.frameNumLabel setStringValue:[NSString stringWithFormat:@"%i/%i",frameNum,(int)capture.get(CV_CAP_PROP_FRAME_COUNT)]];
		//		for( i = 0; i < [files count]; i++ )
		//		{
		//			[files objectAtIndex:i];
		//
		//		}
		
	}
}
- (IBAction)save:(id)sender
{
	if ([self shouldStoreRects]) [rectsForFrames setObject:mainGLView.mouseOverController.rectangleTool.getRects forKey:@(frameNum)];
	NSMutableString *rectOutputLog = [@"Frame,Rectagle Key,X,Y,Width,Height\n" mutableCopy];
	if (currentFilePath) {
		for(int i = 0; i < rectsForFrames.count;i++)
		{
			NSNumber *key = [rectsForFrames.allKeys objectAtIndex:i];
			NSDictionary *rects = [rectsForFrames objectForKey:key];
			int frameNumber = [key intValue];
			for (int j = 0; j < rects.count; j++) {
				NSNumber *key = [[rects allKeys] objectAtIndex:j];
				NSRect r = [[rects objectForKey:key] rectValue];
				[rectOutputLog appendFormat:@"%i,%i,%i,%i,%i,%i\n",frameNumber,key.intValue,(int)r.origin.x,(int)r.origin.y,(int)r.size.width,(int)r.size.height];
				NSString *saveImgPath = [[[currentFilePath stringByDeletingPathExtension] stringByAppendingFormat:@"Frame%i_Rect%i",frameNumber,key.intValue] stringByAppendingPathExtension:@"jpg"];
				OpenImageHandler *img = [allFrames objectAtIndex:frameNumber];
				cv::Mat m = img.Cv;
				cv::Rect cvr(r.origin.x,r.origin.y,r.size.width,r.size.height);
				m = m(cvr);
				cv::imwrite(saveImgPath.UTF8String, m);
			}
			
		}
		[rectOutputLog writeToFile:[[[currentFilePath stringByDeletingPathExtension] stringByAppendingFormat:@"_RectLog"] stringByAppendingPathExtension:@"csv"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
	}
}

@end
