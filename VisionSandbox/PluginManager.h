//
//  FunctionTreeCollector.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/11/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/objc-api.h>
#import <objc/runtime.h>
#import "Threshold.h"
#import "Algorithm.h"
@interface PluginManager : NSObject
{
	NSMutableArray *functionClasses;
	NSMutableArray *FunctionObjects;
	NSMutableArray *AlgorithmObjects;
	NSMutableArray *classTypesToLoad;
}
@property NSMutableArray *FunctionObjects;
+ (id)sharedManager;
- (void)DiscoverAllViableFunctions;
- (void) addFunctionClassType:(Class) c;
- (void) addFunctionClassTypes:(NSArray *)classes;
@end
