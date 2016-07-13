//
//  Tooltip.h
//  SimpleAnnotate
//
//  Created by Brogan, Joel R. on 6/24/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TextFieldWithMouseOver.h"
#import "ComboBoxWithMouseOver.h"
@interface Tooltip : NSView
{
    IBOutlet ComboBoxWithMouseOver * typeSelectionBox;
    IBOutlet TextFieldWithMouseOver *nameField;
}
@property  ComboBoxWithMouseOver *typeSelectionBox;
@property TextFieldWithMouseOver *nameField;
@end
