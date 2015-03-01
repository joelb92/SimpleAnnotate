//
//  PlaneArr.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 3/22/13.
//
//

#import <Foundation/Foundation.h>
#import "Vector3Arr.h"
#import "Plane.h"

@interface PlaneArr : NSObject
{
    Plane*arr;
	int Length;
	int elements;
	int VisableLength;
}
- (id)init;
- (id)initWithCapacity:(int)length;
- (id)initWithLength:(int)length;
- (void)addCapacity:(int)capacityIncrease;
- (void)addElement:(Plane)element;
- (void)removeLastElement;

- (int)Length;

- (int)numberOfElements;
- (Plane)elementAtIndex:(int)index;
- (void)replaceElementAtIndex:(int)index With:(Plane)element;
- (void)reset;

- (Vector3Arr)RaycastPlanesForPlanePointsWithRadius:(float)radius Ray:(Ray3)ray;
- (intArr)RaycastPlanesForIndexesWithRadius:(float)radius Ray:(Ray3)ray;
@end