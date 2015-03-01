//
//  Function.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/9/14.
//  Copyright (c) 2014 Magna Mirrors. All rights reserved.
//

#import "Function.h"

@implementation Function
@synthesize parametersView,functionName,documentation,runTime,displayStepAsLayer,inputType,outputType,functionTreePath,hasSettingsWindow;

-(id)initWithCoder:(NSCoder *)aDecoder
{
	{
		self = [super init];
		if (self) {
			functionName = [aDecoder decodeObjectForKey:@"functionName"];
			functionTreePath = [aDecoder decodeObjectForKey:@"functionTreePath"];
			runTime = 0;
			displayStepAsLayer = [aDecoder decodeBoolForKey:@"displayStepAsLayer"];
			hasSettingsWindow = [aDecoder decodeBoolForKey:@"hasSettingsWindow"];
			inputType = NSClassFromString([aDecoder decodeObjectForKey:@"inputType"]);
			outputType = NSClassFromString([aDecoder decodeObjectForKey:@"outputType"]);
			timer = [[Timer alloc] init];
			propertySettings = [[NSDictionary alloc] init];
			inputType = OpenImageHandler.class;
			outputType = inputType;
			[self createParameterView];
			
		}
		return self;
	}
}
- (id)init
{
	self = [super init];
	if (self) {
		parametersView = [[FunctionVisualParametersView alloc] init];
		timer = [[Timer alloc] init];
		runTime = 0;
		displayStepAsLayer = true;
		hasSettingsWindow = true;
		[self createParameterView];
		propertySettings = [[NSDictionary alloc] init];
	}
	return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:functionName forKey:@"functionName"];
	[aCoder encodeObject:functionTreePath forKey:@"functionTreePath"];
	[aCoder encodeBool:displayStepAsLayer forKey:@"displayStepAsLayer"];
	[aCoder encodeBool:hasSettingsWindow forKey:@"hasSettingsWindow"];
	[aCoder encodeObject:NSStringFromClass(inputType) forKey:@"inputType"];
	[aCoder encodeObject:NSStringFromClass(outputType) forKey:@"outputType"];
}
-(id)copyWithZone:(NSZone *)zone
{
	Function *newFunc = [[self.class allocWithZone:zone] init];
	newFunc.functionName = functionName.copy;
	newFunc.functionTreePath = functionTreePath.copy;
	newFunc.documentation = documentation;
	newFunc->dynamicProps = dynamicProps.copy;
	newFunc->hasSettingsWindow = hasSettingsWindow;
	newFunc->displayStepAsLayer = displayStepAsLayer;
	newFunc->inputType = inputType;
	newFunc->outputType = outputType;
	newFunc->propertySettings = propertySettings.copy;
	return newFunc;
}
-(id)runMethod:(id)input
{
	return input;
}

- (id)run:(id)input;
{
	[self beginRun];
	id output = nil;
	if ([input isKindOfClass:inputType]) {
		output = [self runMethod:[(NSObject *)input copy]];
	}
	else{
		[self sendError];
	}
	[self endRun];
	return output;
}
- (void)beginRun
{
	[self loadViewToParameters];
	[timer startTimer];
}
- (void)endRun
{
	[timer stopTimer];
	runTime = [timer timeElapsedInMilliseconds];
}
-(void)loadParametersToView
{
	for(NSString *key in dynamicProps.allKeys)
	{
		NSTableCellView *subview = [parametersView subviewForKey:key];
		if (subview && [subview isKindOfClass:FunctionVisualTableCellView.class])
		{
			 [(FunctionVisualTableCellView *)subview applyValue:[self valueForKey:key]];
		}
	}
	
}
-(void)loadViewToParameters
{
	for(NSString *key in dynamicProps.allKeys)
	{
		NSTableCellView *subview = [parametersView subviewForKey:key];
		if (subview && [subview isKindOfClass:FunctionVisualTableCellView.class])
		{
			
			[self setValue:[(FunctionVisualTableCellView *)subview getValue] forKey:key];
		}
	}
}
- (void)applyParameterViewSettings
{
	for(int i = 0; i < propertySettings.count; i++)
	{
		NSString *key1 = [propertySettings.allKeys objectAtIndex:i];
		NSDictionary *sets = [propertySettings objectForKey:key1];
		NSTableCellView *subview = [parametersView subviewForKey:key1];
		if (subview) {
			for(int j = 0; j < sets.count; j++)
			{
				NSString *key = [sets.allKeys objectAtIndex:j];
				if ([subview isKindOfClass:FunctionVisualTableCellView.class])
				{
					[(FunctionVisualTableCellView *)subview applySetting:[sets objectForKey:key] forKey:key];
				}
			}
		}

	}
}

- (void)createParameterView
{
	VisualFunctionViewHolder *sharedHolder = [VisualFunctionViewHolder sharedViewHolder];
	NSDictionary *props = [PropertyUtility classPropsFor:self.class];
	NSArray *setKeys = [props.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH 'set_'"]];
	dynamicProps = [NSMutableDictionary dictionaryWithObjects:[props objectsForKeys:setKeys notFoundMarker:@""] forKeys:setKeys];
	for(int i = 0; i < dynamicProps.count; i++)
	{
		NSString *key = [dynamicProps.allKeys objectAtIndex:i];
		NSString *propType = [dynamicProps objectForKey:key];
		if ([propType isEqualToString:@"f"]) propType = @"d";
		FunctionVisualTableCellView *subview = [sharedHolder.viewHolder makeViewWithIdentifier:propType owner:self];
		if(subview)[parametersView addSubview:subview forKey:key];
		else NSLog(@"WARNING: A visual view does not exist for property %@.  Please create a custom view.",key);
	}
	if (dynamicProps.count <1)hasSettingsWindow = false;
	
//	[subview setBackgroundColor:[NSColor redColor]];
//	if (subview) [parametersView addSubview:subview forKey:@"sliderThing"];
//	ComboView *cView = [sharedHolder.viewHolder makeViewWithIdentifier:@"Combo" owner:self];
//	[cView setItems:@{@"One": [NSNumber numberWithInteger:1],@"Two":[NSNumber numberWithInteger:2]}.mutableCopy];
//	if (cView)[parametersView addSubview:cView forKey:@"comboBox"];
	
}

- (NSArray*)writableTypesForPasteboard:(NSPasteboard*)pasteboard
{
	return @[@"Function.func"];
}
- (id)pasteboardPropertyListForType:(NSString *)type
{
    return nil;
}
- (NSPasteboardWritingOptions)writingOptionsForType:(NSString*)type pasteboard:(NSPasteboard*)pasteboard
{
	return 0;
}
+ (NSArray*)readableTypesForPasteboard:(NSPasteboard*)pasteboard
{
    return @[@"Function.func"];
}
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString*)type pasteboard:(NSPasteboard*)pasteboard
{
//	NSPasteboardReadingAsData
    return NSPasteboardReadingAsString;
}


-(void)sendError
{
	NSLog(@"error!");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Runtime Error" object:self];
}
@end
