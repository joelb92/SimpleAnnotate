//
//  Timer.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/9/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject
{
    NSDate *start;
    NSDate *end;
}
- (void) startTimer;
- (void) stopTimer;
- (double) timeElapsedInSeconds;
- (double) timeElapsedInMilliseconds;
- (double) timeElapsedInMinutes;
@end
