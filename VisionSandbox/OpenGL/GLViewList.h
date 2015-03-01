//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingleViewCellView.h"
#import "GLViewListCommand.h"
#import "TreeList.h"
#import "GL2DView.h"
#import "GL3DView.h"

@interface GLViewList : TreeList <NSOutlineViewDataSource, NSOutlineViewDelegate, NSCoding>
{
	NSOutlineView*theOutlineView;
	NSArray*_itemsBeingDragged;
	NSMutableDictionary*Views;
	
	BOOL ViewReloadingData;
}
@property (readwrite) BOOL ViewReloadingData;

- (void)SaveRendersAtPath:(NSString*)path WithNamePrefix:(NSString*)namePrefix;
@end
