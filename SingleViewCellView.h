//
//  SingleViewCellView.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 6/6/13.
//
//

#import <Cocoa/Cocoa.h>

@interface SingleViewCellView : NSTableCellView <NSTextFieldDelegate>
{
	IBOutlet NSControl*view;
	IBOutlet NSView*nonControlView;
}
@property (readonly) NSView*nonControlView;
@property (readonly) NSControl*view;
- (IBAction)ValueChanged:(id)sender;
@end
