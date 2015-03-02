//
//  ROTableView.h
//  SimpleAnnotate
//
//  Created by Joel Brogan on 3/2/15.
//  Copyright (c) 2015 Magna Mirrors. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ROTableView : NSTableView
{
    NSTrackingRectTag trackingTag;
    BOOL mouseOverView;
    int mouseOverRow;
    int lastOverRow;
}
@property int mouseOverRow;
@end
