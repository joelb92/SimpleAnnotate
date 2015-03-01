//
//  idArr.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 2/7/13.
//
//

#import <Foundation/Foundation.h>
#import "ReadWriteLock.h"
@interface idArr : NSObject
{
	NSMutableArray *arr;
	int Length;
	int VisibleLength;
	ReadWriteLock*lock;
}
- (id)init;
- (id)initWithCapacity:(int)length;
- (id)initWithLength:(int)length;
- (void)addElement:(id)element;
- (void)removeElementAtIndex:(int)index;
- (void)removeLastElement;

- (int)Length;

- (int)numberOfElements;
- (id)elementAtIndex:(int)index;
- (void)replaceElementAtIndex:(int)index With:(id)element;
- (void)reset;
@end
