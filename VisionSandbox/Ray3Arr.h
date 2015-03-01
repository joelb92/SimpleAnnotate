//
//  Ray3Arr.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 3/22/13.
//
//

#import <Foundation/Foundation.h>
#import "Vector3Arr.h"
#import "Ray3.h"

@interface Ray3Arr : NSObject
{
    Ray3*arr;
	int Length;
	int elements;
	int VisableLength;
}
- (id)init;
- (id)initWithCapacity:(int)length;
- (id)initWithLength:(int)length;
- (void)addCapacity:(int)capacityIncrease;
- (void)addElement:(Ray3)element;
- (void)removeLastElement;

- (int)Length;

- (int)numberOfElements;
- (Ray3)elementAtIndex:(int)index;
- (void)replaceElementAtIndex:(int)index With:(Ray3)element;
- (void)reset;

- (Vector3Arr)RaycastRaysForRayEndsWithRadius:(float)radius Ray:(Ray3)ray;
- (intArr)RaycastRaysForIndexesWithRadius:(float)radius Ray:(Ray3)ray;
@end