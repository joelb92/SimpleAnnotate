//
//  Tooltip.h
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 6/24/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Tooltip : NSView
{
    IBOutlet NSComboBox * typeSelectionBox;
    IBOutlet NSTextField *nameField;
}
@property  NSComboBox *typeSelectionBox;
@property NSTextField *nameField;
@end
