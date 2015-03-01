//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "ImageThresholdMask.h"

@implementation ImageThresholdMask
@synthesize Mask;
@synthesize cvMask;
@synthesize Image;
@synthesize Min;
@synthesize Max;

-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:Mask forKey:@"Mask"];
	[aCoder encodeObject:Image forKey:@"Image"];
	[aCoder encodeObject:Min.AsNSColor() forKey:@"Min"];
	[aCoder encodeObject:Max.AsNSColor() forKey:@"Max"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self)
	{
		Mask = [aDecoder decodeObjectForKey:@"Mask"];
		Image = [aDecoder decodeObjectForKey:@"Image"];
		Min = Color([aDecoder decodeObjectForKey:@"Min"]);
		Max = Color([aDecoder decodeObjectForKey:@"Max"]);
	}
	return self;
}
- (id)initWithImage:(OpenImageHandler*)image Color:(Color)c MinValue:(double)min MaxColor:(double)max
{
	self = [super init];
	if(self)
	{
		if(image!=nil && !image.null)
		{
			Image = [image retain];
			Min = Color(min,min,min);
			Max = Color(max,max,max);
			cv::Mat mat;
			cv::threshold(image.GreyScaled.Cv, mat, min, max, image.Cv.type());
			Mask = [[OpenImageHandler alloc] initWithCVMat:mat Color:c BinaryImage:true];
		}
		else
		{
			[self release];
			return nil;
		}
	}
	return self;
}
- (id)initWithImage:(OpenImageHandler*)image Color:(Color)c MinColor:(Color)min MaxColor:(Color)max
{
	self = [super init];
	if(self)
	{
		if(image!=nil && !image.null)
		{
			Image = [image retain];
			Min = min;
			Max = max;
			cv::Mat mat;
			cv::inRange(image.Cv, cv::Scalar(min.b-1, min.g-1, min.r-1), cv::Scalar(max.b, max.g, max.r), mat);
			Mask = [[OpenImageHandler alloc] initWithCVMat:mat Color:c BinaryImage:true];
		}
		else
		{
			[self release];
			return nil;
		}
	}
	return self;
}
- (id)initWithMask:(OpenImageHandler*)mask
{
	self = [super init];
	if(self)
	{
		if(mask!=NULL)
		{
			Mask = [mask retain];
		}
	}
	return self;
}
- (void)AddMask:(OpenImageHandler*)mask
{
	cv::add(Mask.Cv, mask.Cv, Mask.Cv);
}
- (bool)MaskedAtX:(int)x Y:(int)y
{
	if(Mask.Cv.at<unsigned char>(y,x) > 0)
	{
		return true;
	}
	return false;
}
- (bool)MaskedAtPoint:(Vector2)point
{
	if(Mask)
	{
		int x = floor(point.x);
		int y = floor(point.y);
		
		if(x>=0 && x<Mask.size.width && y>=0 && y<Mask.size.height)
		{
			int index = (int)(y*Mask.cv->widthStep+x);
			int isExcluded = Mask.cv->imageData[index];
			
			if(isExcluded < 0)
			{
				return true;
			}
		}
	}
	return false;
}
- (void)dealloc
{
	[Image release];
	[Mask release];
	[super dealloc];
}
@end