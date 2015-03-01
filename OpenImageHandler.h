//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpaceConverter.h"
#import "OpenGL/glu.h"
#import "Color.h"
#import "GLObject.h"

@interface OpenImageHandler : GLObject
{
	IplImage*cv;
	cv::Mat Cv;
	bool ownsAnIPL;
	CGSize size;
	CGRect imageRect;
	float aspectRatio;
	bool null;
	
	GLint format;
	bool binary;

	Vector2 startCenter;
	Vector2 endCenter;
	GLKQuaternion rotation;
	
	Vector2 LL;
	Vector2 UL;
	Vector2 UR;
	Vector2 LR;
	
	NSString *namePrefix;
	NSString *currentPath;
	NSString *extenshion;
}
@property (readonly) cv::Mat Cv;
- (void)setCvMat:(cv::Mat)cvMat;
@property (readonly) IplImage*cv;
- (void)setCvIPL:(IplImage*)cvIPL;
@property (readonly) CGSize size;
@property (readonly) CGRect imageRect;
@property (readonly) float aspectRatio;
@property (readonly) GLint format;
@property (readonly) bool null;
@property (readonly) bool binary;
@property (assign) NSString *namePrefix;
@property (assign) NSString *currentPath;
@property (assign) NSString *extenshion;

- (void)setStartCenter:(Vector2)sc;
- (void)setEndCenter:(Vector2)ec;
- (void)setRotation:(GLKQuaternion)rot;
 
- (id)initWithIplImage:(IplImage*)image Color:(Color)c BinaryImage:(bool)b;
- (id)initWithCVMat:(cv::Mat)image Color:(Color)c BinaryImage:(bool)b;
- (id)initWithChannels:(NSArray*)channels Color:(Color)c BinaryImage:(bool)b;
- (id)initWithFilePath:(const char*)path Color:(Color)c BinaryImage:(bool)b;
- (id)initWithFilePath:(const char*)path Color:(Color)c BinaryImage:(bool)b NamePrefix:(NSString*)nP;

- (void)SetRenderOffset:(Vector2)renderOffset;
- (bool)LoadGLTexture;
- (void)SaveAtPath:(NSString*)path;
- (NSDictionary*)MetaData;

+ (OpenImageHandler*)ZerosWithSize:(CGSize)s;
+ (OpenImageHandler*)WhiteWithSize:(CGSize)s;
- (OpenImageHandler*)GreyScaled;
- (OpenImageHandler*)BGR_2_HSV;
- (OpenImageHandler*)HSV_2_BGR;
- (OpenImageHandler*)BGR_2_YCrCb;
- (OpenImageHandler*)GREY_2_FalseColor;
- (OpenImageHandler*)BGR_2_H_FalseColor;
- (OpenImageHandler*)HSV_2_H_FalseColor;
- (OpenImageHandler*)SobelOfOrder:(Vector2)order;
- (OpenImageHandler*)ThreeChannel;
- (OpenImageHandler*)Normalized;
- (OpenImageHandler*)EqualizeHistograms;
- (OpenImageHandler*)FloodFillResultFromPoint:(Vector2)seed WithChangeInColorFromSeedLower:(Color)lowerDif Upper:(Color)upperDif;
- (OpenImageHandler*)Demosiaced;
- (OpenImageHandler*)OpenedBy:(float)radius;
- (OpenImageHandler*)ClosedBy:(float)radius;
- (OpenImageHandler*)DilatedBy:(float)radius;
- (OpenImageHandler*)ErodedBy:(float)radius;
- (OpenImageHandler*)MultiplyBy:(OpenImageHandler*)factor;
- (OpenImageHandler*)GausianBlurUsingKernalSize:(Vector2)kSize Sigma:(double)sigma;
- (OpenImageHandler*)Subtract:(OpenImageHandler*)sub;
- (OpenImageHandler *)Displayable;
- (NSArray*)Channels;
- (void)MakeGreyScale;

+ (BOOL)ImageIsReadableAtPath:(NSString*)path;
@end