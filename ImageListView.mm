//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "ImageListView.h"

@implementation ImageListView
-(id)init
{
	self = [super init];
	if (self)
	{
		
		GLViewList*viewList = [[GLViewList alloc] initWithBackupPath:@"/Users/joel/Documents/Programming/VisionSandbox/Settings/View List Backup.vis"];
		mainGLView.objectList = [[GLObjectList alloc] init] ;//WithBackupPath:@"/Users/joel/Documents/Programming/VisionSandbox/Settings/Main View List Backup.vis"];
		[viewList AddObject:mainGLView ForKeyPath:@"MainView"];
		mainGLOutlineView.viewList = viewList;
		[GLViewListCommand SetViewKeyPath:@"MainView" MaxImageSpaceRect:vector2Rect(0, 0, 400, 400)];
		OpenImageHandler * h = [[OpenImageHandler alloc] initWithCVMat:cv::Mat(400,400,CV_8UC3,cv::Scalar(0,255,0)) Color:White BinaryImage:false];
		[GLViewListCommand AddObject:h ToViewKeyPath:@"MainView" ForKeyPath:@"TestThing"];
		[mainGLOutlineView reloadData];
	}
	return self;
}
@end
