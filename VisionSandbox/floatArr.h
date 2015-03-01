//
//  floatArr.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface floatArr : NSObject
{
    float*arr;
	int Length;
	int elements;
	int VisableLength;
}
- (id)init;
- (id)initWithCapacity:(int)length;
- (id)initWithLength:(int)length;
- (void)addCapacity:(int)capacityIncrease;
- (void)addElement:(float)element;
- (void)removeLastElement;

- (int)Length;

- (int)numberOfElements;
- (float)elementAtIndex:(int)index;
- (void)replaceElementAtIndex:(int)index With:(float)element;
@end
