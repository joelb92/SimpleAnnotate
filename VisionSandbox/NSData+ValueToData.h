//
//  NSData+ValueToData.h
//  VisionSandbox
//
//  Created by Joel Brogan on 12/25/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (ValueToData)
+(NSData*) dataWithValue:(NSValue*)value;
+(NSData*) dataWithNumber:(NSNumber*)number;
@end