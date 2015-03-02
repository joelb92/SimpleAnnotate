//
//  ROTableView.m
//  SimpleAnnotate
//
//  Created by Joel Brogan on 3/2/15.
//  Copyright (c) 2015 Magna Mirrors. All rights reserved.
//

#import "ROTableView.h"

@implementation ROTableView
@synthesize mouseOverRow;
- (void)awakeFromNib
{
    [[self window] setAcceptsMouseMovedEvents:YES];
    trackingTag = [self addTrackingRect:[self frame] owner:self userData:nil assumeInside:NO];
    mouseOverView = NO;
    mouseOverRow = -1;
    lastOverRow = -1;
    
}

- (void)mouseEntered:(NSEvent*)theEvent
{
    mouseOverView = YES;
    [self.window makeFirstResponder:self];
}

- (void)mouseMoved:(NSEvent*)theEvent
{
    id myDelegate = [self delegate];
    if (!myDelegate)
        return; // No delegate, no need to track the mouse.
    if (![myDelegate respondsToSelector:@selector(tableView:willDisplayCell:forTableColumn:row:)])
        return; // If the delegate doesn't modify the drawing, don't track.
    
    if (mouseOverView) {
        
        mouseOverRow = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
        if (lastOverRow == mouseOverRow)
            return;
        else {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:mouseOverRow];
            [self selectRowIndexes:indexSet byExtendingSelection:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewHoverChanged" object:@(mouseOverRow)];
            lastOverRow = mouseOverRow;
        }
        
        [self setNeedsDisplayInRect:[self rectOfRow:mouseOverRow]];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    mouseOverView = NO;
    [self setNeedsDisplayInRect:[self rectOfRow:mouseOverRow]];
    mouseOverRow = -1;
    lastOverRow = -1;
}

- (int)mouseOverRow
{
    return mouseOverRow;
}

- (void)viewDidEndLiveResize
{
    [super viewDidEndLiveResize];
    
    [self removeTrackingRect:trackingTag];
    trackingTag = [self addTrackingRect:[self frame] owner:self userData:nil assumeInside:NO];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
