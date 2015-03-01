//
//  SingleViewCellView.m
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 6/6/13.
//
//

#import "SingleViewCellView.h"

@implementation SingleViewCellView
@synthesize view,nonControlView;
- (IBAction)ValueChanged:(id)sender
{
	[[[self superview] superview] objectDidEndEditing:sender];
}
- (void)controlTextDidChange:(NSNotification*)obj
{
	[[[self superview] superview] objectDidEndEditing:obj.object];
}
- (BOOL)becomeFirstResponder
{
	return [[view window] makeFirstResponder:view];
}
@end