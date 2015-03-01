//
//  Timer.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/9/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import "Timer.h"

@implementation Timer
- (id) init {
    self = [super init];
    if (self != nil) {
        start = nil;
        end = nil;
    }
    return self;
}

- (void) startTimer {
    start = [NSDate date];
}

- (void) stopTimer {
    end = [NSDate date];
}

- (double) timeElapsedInSeconds {
    return [end timeIntervalSinceDate:start];
}

- (double) timeElapsedInMilliseconds {
    return [self timeElapsedInSeconds] * 1000.0f;
}

- (double) timeElapsedInMinutes {
    return [self timeElapsedInSeconds] / 60.0f;
}
@end
