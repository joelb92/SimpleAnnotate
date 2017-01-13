//
//  ImageAnnotationView.m
//  SimpleAnnotate
//
//  Created by Joel Brogan on 11/25/16.
//  Copyright © 2016 University of Notre Dame. All rights reserved.
//

#import "ImageAnnotationView.h"

@implementation ImageAnnotationView

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        [self setImageScaling:NSImageScaleProportionallyUpOrDown];
        eyebox = self.frame;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setDisplayedImage:(NSImage *)im
{
    [self setImage:im];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    NSLog(@"entered");
}

- (void)mouseMoved:(NSEvent *)theEvent {
    NSLog(@"moved");
}

- (void)mouseExited:(NSEvent *)theEvent {
    NSLog(@"exited");
}

//- (void)rotateWithEvent:(NSEvent *)event{
//    [self setFrameCenterRotation:([self frameCenterRotation] + [event rotation])];
//}
- (void)awakeFromNib
{
//    [self setTranslatesAutoresizingMaskIntoConstraints:NO]; // compatibility with Auto Layout; without this, there could be Auto Layout error messages when we are resized (delete this line if your app does not use Auto Layout)
    [self setAcceptsMouseMovedEvents:YES];
}

//
//// FixedIKImageView must *only* be used embedded within an NSScrollView. This means that setFrame: should never be called explicitly from outside the scroll view. Instead, this method is overwritten here to provide the correct behavior within a scroll view. The new implementation ignores the frameRect parameter.
//- (void)setFrame:(NSRect)frameRect
//{
//    NSSize  imageSize = [self imageSize];
//    CGFloat zoomFactor = [self zoomFactor];
//    NSSize  clipViewSize = [[self superview] frame].size;
//    
//    // The content of our scroll view (which is ourselves) should stay at least as large as the scroll clip view, so we make ourselves as large as the clip view in case our (zoomed) image is smaller. However, if our image is larger than the clip view, we make ourselves as large as the image, to make the scrollbars appear and scale appropriately.
//    CGFloat newWidth = (imageSize.width * zoomFactor < clipViewSize.width)?  clipViewSize.width : imageSize.width * zoomFactor;
//    CGFloat newHeight = (imageSize.height * zoomFactor < clipViewSize.height)?  clipViewSize.height : imageSize.height * zoomFactor;
//    
//    [super setFrame:NSMakeRect(0, 0, newWidth - 2, newHeight - 2)]; // actually, the clip view is 1 pixel larger than the content view on each side, so we must take that into account
//}
//
//
////// We forward size affecting messages to our superclass, but add [self setFrame:NSZeroRect] to update the scroll bars. We also add [self setAutoresizes:NO]. Since IKImageView, instead of using [self setAutoresizes:NO], seems to set the autoresizes instance variable to NO directly, the scrollers would not be activated again without invoking [self setAutoresizes:NO] ourselves when these methods are invoked.
//
//- (void)setZoomFactor:(CGFloat)zoomFactor
//{
//    [super setZoomFactor:zoomFactor];
//    [self setFrame:NSZeroRect];
//    [self setAutoresizes:NO];
//}
//
//
//- (void)zoomImageToRect:(NSRect)rect
//{
//    [super zoomImageToRect:rect];
//    [self setFrame:NSZeroRect];
//    [self setAutoresizes:NO];
//}
//
//
//- (void)zoomIn:(id)sender
//{
//    [super zoomIn:self];
//    [self setFrame:NSZeroRect];
//    [self setAutoresizes:NO];
//}
//
//
//- (void)zoomOut:(id)sender
//{
//    [super zoomOut:self];
//    [self setFrame:NSZeroRect];
//    [self setAutoresizes:NO];
//}
//
//
//- (void)zoomImageToActualSize:(id)sender
//{
//    [super zoomImageToActualSize:sender];
//    [self setFrame:NSZeroRect];
//    [self setAutoresizes:NO];
//}
//
//
//- (void)zoomImageToFit:(id)sender
//{
//    [self setAutoresizes:YES];  // instead of invoking super's zoomImageToFit: method, which has problems of its own, we invoke setAutoresizes:YES, which does the same thing, but also makes sure the image stays zoomed to fit even if the scroll view is resized, which is the most intuitive behavior, anyway. Since there are no scroll bars in autoresize mode, we need not add [self setFrame:NSZeroRect].
//}
//
//
//- (void)setAutoresizes:(BOOL)autoresizes    // As long as we autoresize, make sure that no scrollers flicker up occasionally during live update.
//{
//    [self setHasHorizontalScroller:!autoresizes];
//    [self setHasVerticalScroller:!autoresizes];
//    [super setAutoresizes:autoresizes];
//}


@end
