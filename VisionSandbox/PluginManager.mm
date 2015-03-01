//
//  FunctionTreeCollector.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/11/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import "PluginManager.h"
#import "Function.h"
@implementation PluginManager
@synthesize FunctionObjects;
+ (id)sharedManager
{
    static PluginManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init
{
	if (self = [super init])
	{
		functionClasses = [[NSMutableArray alloc] init];
		FunctionObjects = [[NSMutableArray alloc] init];
		AlgorithmObjects = [[NSMutableArray alloc] init];
		classTypesToLoad = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) addFunctionClassTypes:(NSArray *)classes
{
	[classTypesToLoad addObjectsFromArray:classes];
	[self DiscoverAllViableFunctions];
}

- (void) addFunctionClassType:(Class) c
{
	[classTypesToLoad addObject:c];
	[self DiscoverAllViableFunctions];
}
- (void)DiscoverAllViableFunctions
{
	[functionClasses removeAllObjects];
	for(Class c in classTypesToLoad)
	{
		NSMutableArray *classes = [self getAllSubclassesOfClassType:Function.class];
		[functionClasses addObjectsFromArray:classes];
	}
	[self createFunctionObjects];
	
}

-(void)createFunctionObjects
{
	[FunctionObjects removeAllObjects];
	for (int i = 0; i < functionClasses.count; i++) {
		Class c = [functionClasses objectAtIndex:i];
		id obj = [[c alloc] init];
		[FunctionObjects addObject:obj];
	}
}

- (NSMutableArray*) getAllSubclassesOfClassType:(Class)superClassType {
	NSMutableArray *array = [NSMutableArray array];
	
	int numClasses;
	Class * classes = NULL;
	
	classes = NULL;
	numClasses = objc_getClassList(NULL, 0);
	
	if (numClasses > 0 ) {
		classes = (Class *)malloc(sizeof(Class) * numClasses);
		numClasses = objc_getClassList(classes, numClasses);
		
		Class classType = nil;
		for (int i = 0; i < numClasses; i++) {
			classType = classes[i];
			bool isCorrectSublcass =false;
			Class superClass = class_getSuperclass(classType);
			while (superClass) {
				if (superClass == superClassType)
				{
					isCorrectSublcass = true;
					break;
				}
				superClass = class_getSuperclass(superClass);
			}
			if (isCorrectSublcass && ![classTypesToLoad containsObject:classType] && classType != Algorithm.class) {
				[array addObject:classType];
			}
		}
		free(classes);
	}
	return [array copy];
}
@end
