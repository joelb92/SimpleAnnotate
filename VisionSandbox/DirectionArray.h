//
//  DirectionArray.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 9/19/12.
//  Copyright (c)2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Vector2.h"

@interface DirectionArray : NSWindowController
{
    Direction*arr;
	int Length;
	int elements;
	int VisableLength;
}
- (id)init;
- (id)initWithCapacity:(int)length;
- (id)initWithLength:(int)length;
- (void)addCapacity;
- (void)addElement:(Direction)element;
- (void)removeLastElement;
- (int)Length;
- (void)Reset;
- (int)numberOfElements;
- (Direction)elementAtIndex:(int)index;
- (void)replaceElementAtIndex:(int)index With:(Direction)element;
@end
