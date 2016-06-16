//
//  FrameHandler.h
//  SimpleAnnotate
//
//  Created by Joel Brogan on 6/14/16.
//  Copyright (c) 2016 University of Notre Dame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageHandler.h"
@interface FrameHandler : NSObject
{
    
}
- (id)initWithVideoPath:(NSString *)videoPath;
- (id)initWithFolderPath:(NSString *)folderPath;
- (id)initWithImageFiles:(NSString *)filePaths;

- (void)nextFrame;
- (void)previousFrame;
- (void)jumpToFrame:(int) frameNum;
- (ImageHandler *)getCurrentFrame;


@end
