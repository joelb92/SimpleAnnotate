//
//  ReadWriteLock.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 2/6/13.
//
//

//Found at http://cocoaheads.byu.edu/wiki/locks

#import <Foundation/Foundation.h>
#import <pthread.h>

@interface ReadWriteLock : NSObject <NSLocking>
{
	pthread_rwlock_t lock;
}
- (void) lockForWriting;
- (BOOL) tryLock;
- (BOOL) tryLockForWriting;
@end
