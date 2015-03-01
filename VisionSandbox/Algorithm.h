//
//  Algorithm.h
//  VisionSandbox
//
//  Created by Joel Brogan on 8/11/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import "Function.h"
#import "Algorithm.h"
@interface Algorithm : Function
{
	NSMutableArray *functions;
}
-(Function *)FunctionAtIndex:(int)index;
-(void)addFunction:(Function *)function;
-(void)addFunctions:(NSArray *)functionsArr;
-(void)insertFunction:(Function *)function atIndex:(int)index;
-(void)replaceFunctionAtIndex:(int)index withFunction:(Function *)function;
-(void)removeFunctionAtIndex:(int)index;
-(void)removeFunction:(Function *)func;
-(int)indexForFunction:(Function *)func;
-(int)count;
@end
