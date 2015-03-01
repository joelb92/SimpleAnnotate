//
//  ComboView.m
//  VisionSandbox
//
//  Created by Joel Brogan on 8/13/14.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "ComboView.h"

@implementation ComboView
@dynamic items;
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		items = @{}.mutableCopy;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		items = @{}.mutableCopy;
	}
	return self;
}

-(void)applyValue:(id)val
{
	if ([val respondsToSelector:@selector(stringValue)]) {
		[comboBox selectItemAtIndex:[[comboBox objectValues] indexOfObject:[val stringValue]]];
	}
}

-(id)getValue
{
	return [self selectedValue];
}

-(void)setting_items:(NSMutableDictionary *)its
{
	[self setItems:its];
}

-(void)setItems:(NSMutableDictionary *)its
{
	items = its;
	[comboBox removeAllItems];
	[comboBox addItemsWithObjectValues:items.allKeys];
}

-(IBAction)comboChanged:(id)sender
{
	[self settingChanged];
}

-(id)selectedValue
{
	return [items objectForKey:comboBox.objectValueOfSelectedItem];
}
@end
