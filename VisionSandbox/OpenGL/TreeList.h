//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeListItem.h"
#import "ReadWriteLock.h"
@interface TreeList : NSObject <NSCoding>
{
	ReadWriteLock*lock;
	int countOfNonExpandableItems;
	TreeListItem*root;
	NSMutableDictionary*Objects;
	
	NSString*BackupPath;
}
@property (readonly) NSMutableDictionary*Objects;
@property (readonly) TreeListItem*root;

- (id)initWithBackupPath:(NSString*)backupPath;

- (NSString*)FormattedKeyPathForKeyPath:(NSString*)key;

- (id)ObjectForKeyPath:(NSString*)key;

- (void)AddObject:(id)object ForKeyPath:(NSString*)key;
- (void)AddObject:(id)object ForKeyPath:(NSString*)key AfterKeyPath:(NSString*)afterKey;
- (void)AddObject:(id)object ForKeyPath:(NSString*)key BeforeKeyPath:(NSString*)beforeKey;
- (TreeListItem*)ItemCreatingIfNessisaryWithObject:(id)object ForKey:(NSString*)key ItemWasCreated:(BOOL*)CreatedANew;

- (bool)PossibleToMoveItem:(TreeListItem*)Item ToParent:(TreeListItem*)parent AtIndex:(int)index;
- (void)MoveItem:(TreeListItem*)Item ToParent:(TreeListItem*)parent AtIndex:(int)index; /*It is assumed that you checked "- (bool)PossibleToMoveObject:(TreeListItem*)object ToParent:(TreeListItem*)parent AtIndex:(int)index" first, if you did not, not my problem.*/

- (void)RemoveItem:(TreeListItem*)Item Recursively:(BOOL)recursively;
- (void)RemoveListItemForKeyPath:(NSString*)key Recursively:(BOOL)recursively;
- (void)RemoveAll;

- (void)ClearItem:(TreeListItem*)Item Recursively:(BOOL)recursively;
- (void)ClearItemForKeyPath:(NSString*)key Recursively:(BOOL)recursively;
- (void)InternalClearItem:(TreeListItem*)Item Recursively:(BOOL)recursively;
- (void)ClearAll;

- (void)Save;
@end
