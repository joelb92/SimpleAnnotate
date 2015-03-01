//
//  NSImage+saveAsJpegWithName.m
//  DIF Map Decoder
//
//  Copied by Charlie Mehlenbeck on 1/9/13 from http://stackoverflow.com/questions/3038820/how-to-save-a-nsimage-as-a-new-file.
//
//

#import "NSImage+saveAsJpegWithName.h"


@implementation NSImage(saveAsJpegWithName)

- (void)saveAsJpegWithName:(NSString*)fileName
{
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:fileName atomically:NO];
}

@end