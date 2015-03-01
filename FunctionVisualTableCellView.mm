//
//  FunctionVisualTableCellView.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/9/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "FunctionVisualTableCellView.h"

@implementation FunctionVisualTableCellView
-(void)applySetting:(id)setting forKey:(NSString *)key
{
	NSString *selectorString =[NSString stringWithFormat:@"setting_%@:",key];
	SEL selector = NSSelectorFromString(selectorString);
	if ([self respondsToSelector:selector]) {
		[self performSelector:selector withObject:setting];
	}
	else
	{
		NSLog(@"WARNING: Visual Parameter <%@> does not respond to the setting \"%@\"",NSStringFromClass(self.class),key);
	}
}

-(void)applyValue:(id)val
{
	
}
-(void)settingChanged
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Setting Changed" object:self];
}
-(id)getValue
{
	return nil;
}
@end
