//
//  colorArr.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 3/22/12.
//  Copyright (c) 2012 Magna Mirrors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Color.h"

@interface colorArr : NSObject
{
    Color*arr;
	int Length;
	int elements;
	int VisableLength;
}
- (id)init;
- (id)initWithCapacity:(int)length;
- (id)initWithLength:(int)length;
- (void)addCapacity:(int)capacityIncrease;
- (void)addElement:(Color)element;
- (void)addElements:(colorArr*)cols;
- (void)removeLastElement;
- (void) removeElementAtIndex:(int)k;

- (int)Length;

- (int)numberOfElements;
- (Color)elementAtIndex:(int)index;
- (void)replaceElementAtIndex:(int)index With:(Color)element;

- (void)Reset;
@end
