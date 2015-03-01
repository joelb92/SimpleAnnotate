//
//  AMMSarr.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMMS.h"

@interface AMMSarr : NSObject
{
    AMMS**arr;
	int Length;
	int arrays;
	int VisableLength;
}
- (id)init;
- (id)initWithCapacity:(int)length;
- (id)initWithLength:(int)length;
- (id)initWithLength:(int)length MaxValuesPerAMMS:(int)num;

- (void)addCapacity:(int)capacityIncrease;
- (void)addArray:(AMMS*)array;
- (void)removeLastArray;
- (int)Length;
- (int)numberOfArrays;
- (AMMS*)arrayAtIndex:(int)index;
- (void)replaceArrayAtIndex:(int)index With:(AMMS*)array;
@end