//
//  NSData+ValueToData.m
//  VisionSandbox
//
//  Created by Joel Brogan on 12/25/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import "NSData+ValueToData.h"

@implementation NSData (ValueToData)
+(NSData*) dataWithValue:(NSValue*)value
{
    NSUInteger size;
    const char* encoding = [value objCType];
    NSGetSizeAndAlignment(encoding, &size, NULL);
	
    void* ptr = malloc(size);
    [value getValue:ptr];
    NSData* data = [NSData dataWithBytes:ptr length:size];
    free(ptr);
	
    return data;
}

+(NSData*) dataWithNumber:(NSNumber*)number
{
    return [NSData dataWithValue:(NSValue*)number];
}
@end