//
//  NSImage+saveAsJpegWithName.h
//  DIF Map Decoder
//
//  Copied by Charlie Mehlenbeck on 1/9/13 from http://stackoverflow.com/questions/3038820/how-to-save-a-nsimage-as-a-new-file.
//
//

#import <Cocoa/Cocoa.h>

@interface NSImage(saveAsJpegWithName)
- (void) saveAsJpegWithName:(NSString*) fileName;
@end