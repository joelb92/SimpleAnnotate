//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "OpenImageHandler.h"
#import "NSImage+OpenCV.h"

std::pair<int, GLenum> CVtoGLtypes[] =
{
	std::make_pair(CV_8U, GL_UNSIGNED_BYTE),
	std::make_pair(CV_8S, GL_BYTE),
	std::make_pair(CV_16U, GL_UNSIGNED_SHORT),
	std::make_pair(CV_16S, GL_SHORT),
	std::make_pair(CV_32S, GL_INT),
	std::make_pair(CV_32F, GL_FLOAT),
	std::make_pair(CV_64F, GL_DOUBLE)
};

std::map<int, GLenum> CVtoGLtype(CVtoGLtypes,
								 CVtoGLtypes + sizeof CVtoGLtypes / sizeof CVtoGLtypes[0]);


@implementation OpenImageHandler
@synthesize size;
@synthesize imageRect;
@synthesize aspectRatio;
@synthesize format;
@synthesize null;
@synthesize binary;
@synthesize namePrefix,currentPath,extenshion;
- (void)setStartCenter:(Vector2)sc
{
	[lock lockForWriting];
	startCenter = sc;
	[self CalculateCorners];
	[lock unlock];
}
- (void)setEndCenter:(Vector2)ec
{
	[lock lockForWriting];
	endCenter = ec;
	[self CalculateCorners];
	[lock unlock];
}
- (void)setRotation:(GLKQuaternion)rot
{
	[lock lockForWriting];
	rotation = rot;
	[self CalculateCorners];
	[lock unlock];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:[NSNumber numberWithBool:null] forKey:@"null"];
	if(!null)
	{
		std::vector<uchar> encodedMat;
		std::vector<int> encodedMatParams(2);
		encodedMatParams[0] = CV_IMWRITE_JPEG_QUALITY;
		encodedMatParams[1] = 100; //jpeg compression quality
		cv::imencode(".jpg", Cv, encodedMat);
		[aCoder encodeObject:[NSData dataWithBytes:encodedMat.data() length:encodedMat.size()*sizeof(uchar)] forKey:@"Image"];
		[aCoder encodeObject:[NSValue valueWithPoint:NSMakePoint(Cv.cols, Cv.rows)] forKey:@"CvSize"];
		[aCoder encodeObject:[NSNumber numberWithInt:Cv.elemSize()] forKey:@"MatElemSize"];
		[aCoder encodeObject:[NSData dataWithBytes:Cv.data length:Cv.cols*Cv.rows*Cv.elemSize()]   forKey:@"CvData"];
		[aCoder encodeObject:[NSValue valueWithSize:NSMakeSize(size.width, size.height)] forKey:@"size"];
		[aCoder encodeObject:[NSValue valueWithRect:NSMakeRect(imageRect.origin.x,imageRect.origin.y, imageRect.size.width, imageRect.size.height)] forKey:@"imageRect"];
		[aCoder encodeObject:[NSNumber numberWithFloat:aspectRatio] forKey:@"aspectRatio"];
		[aCoder encodeObject:[NSNumber numberWithInt:format] forKey:@"format"];
		[aCoder encodeObject:[NSNumber numberWithBool:binary] forKey:@"binary"];
	}
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		null =[(NSNumber *)[aDecoder decodeObjectForKey:@"null"] boolValue];
		if(!null)
		{
			NSData *CvData = (NSData *)[aDecoder decodeObjectForKey:@"Image"];
			uchar * imageBytes = (uchar *)[CvData bytes];
			std::vector<uchar> imageVector(imageBytes,imageBytes+CvData.length/sizeof(uchar));
			Cv = cv::imdecode(imageVector, CV_LOAD_IMAGE_ANYDEPTH);
			cv = new IplImage(Cv);
			NSSize s= [(NSValue *)[aDecoder decodeObjectForKey:@"size"] sizeValue];
			size = CGSizeMake(s.width, s.height);
			NSRect r = [[aDecoder decodeObjectForKey:@"imageRect"] rectValue];
			imageRect = CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height);
			aspectRatio = [[aDecoder decodeObjectForKey:@"aspectRatio"] floatValue];
			format = [[aDecoder decodeObjectForKey:@"format"] intValue];
			binary =[[aDecoder decodeObjectForKey:@"binary"] boolValue];
		}
	}
	return self;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		
		namePrefix = nil;
		currentPath = nil;
		extenshion = [@".JPG" retain];
		
		color = Color();
		
		cv = NULL;
		data.gl = NULL;
		null = true;
		data.glSet = false;
		binary = false;
		
		size.width = 0;
		size.height = 0;
		aspectRatio = 1;
		imageRect.size = size;
		imageRect.origin.x = 0;
		imageRect.origin.y = 0;
		
		startCenter = Vector2(0,0);
		endCenter = Vector2(0,0);
		rotation = GLKQuaternionIdentity;
		
		[self CalculateCorners];
	}
	return self;
}
- (id)initWithIplImage:(IplImage*)image Color:(Color)c BinaryImage:(bool)b
{
	self = [super init];
	if(self)
	{
		namePrefix = nil;
		currentPath = nil;
		extenshion = [@".JPG" retain];
		
		color = c;
		
		cv = image;
		Cv = cv::cvarrToMat(image);
		ownsAnIPL = true;
		binary = b;
		
		data.glSet = false;
		
		if(cv!=NULL)
		{
			null = false;
			size.width = cv->width;
			size.height = cv->height;
			aspectRatio = size.width/size.height;
		}
		else
		{
			null = true;
			size.width = 0;
			size.height = 0;
			aspectRatio = 1;
		}
		imageRect.size = size;
		imageRect.origin.x = 0;
		imageRect.origin.y = 0;
		
		startCenter = Vector2(0,0);
		endCenter = Vector2(0,0);
		rotation = GLKQuaternionIdentity;
		
		[self CalculateCorners];
	}
	return self;
}
- (id)initWithCVMat:(cv::Mat)image Color:(Color)c BinaryImage:(bool)b
{
	self = [super init];
	if(self)
	{
		namePrefix = nil;
		currentPath = nil;
		extenshion = [@".JPG" retain];
		
		color = c;
		Cv = image;
		cv = new IplImage(Cv);
		binary = b;
		
		data.glSet = false;
		
		if(cv!=NULL)
		{
			null = false;
			size.width = cv->width;
			size.height = cv->height;
			aspectRatio = size.width/size.height;
		}
		else
		{
			null = true;
			size.width = 0;
			size.height = 0;
			aspectRatio = 1;
		}
		imageRect.size = size;
		imageRect.origin.x = 0;
		imageRect.origin.y = 0;
		
		startCenter = Vector2(0,0);
		endCenter = Vector2(0,0);
		rotation = GLKQuaternionIdentity;
		
		[self CalculateCorners];
	}
	return self;
}
- (id)initWithChannels:(NSArray*)channels Color:(Color)c BinaryImage:(bool)b
{
	self = [super init];
	if(self)
	{
		namePrefix = nil;
		currentPath = nil;
		extenshion = [@".JPG" retain];
		
		color = c;
		
		std::vector<cv::Mat> chans;
		for(int i=0; i<channels.count; i++)
		{
			id obj = [channels objectAtIndex:i];
			NSAssert([obj isKindOfClass:OpenImageHandler.class], @"You can not merge any thing but Open Image Handlers into an OpenImageHandler");
			chans.push_back(((OpenImageHandler*)obj).Cv);
		}
		
		cv::Mat image;
		cv::merge(chans, image);
		
		Cv = image;
		cv = new IplImage(Cv);
		binary = b;
		
		data.glSet = false;
		
		if(cv!=NULL)
		{
			null = false;
			size.width = cv->width;
			size.height = cv->height;
			aspectRatio = size.width/size.height;
		}
		else
		{
			null = true;
			size.width = 0;
			size.height = 0;
			aspectRatio = 1;
		}
		imageRect.size = size;
		imageRect.origin.x = 0;
		imageRect.origin.y = 0;
		
		startCenter = Vector2(0,0);
		endCenter = Vector2(0,0);
		rotation = GLKQuaternionIdentity;
		
		[self CalculateCorners];
	}
	return self;
}
- (id)initWithFilePath:(const char*)path Color:(Color)c BinaryImage:(bool)b
{
	self = [super init];
	if(self)
	{
		currentPath = [[NSString stringWithUTF8String:path] retain];
		namePrefix = [[[currentPath lastPathComponent] stringByDeletingPathExtension] retain];
		extenshion = [[currentPath pathExtension] retain];
		if([[extenshion uppercaseString] isEqualToString:@"CR2"])
		{
			NSImage*image = [[NSImage alloc] initWithContentsOfFile:currentPath];
			Cv = image.CVMat;
			[image release];
		}
		else
		{
			if(b)
			{
				Cv = cv::imread(path,0);
			}
			else
			{
				Cv = cv::imread(path);
			}
		}
		color = c;
		cv = new IplImage(Cv);
		
		data.glSet = false;
		binary = b;
		
		if(cv!=NULL)
		{
			null = false;
			//			size.width = cV.cols;
			//			size.height = cV.rows;
			size.width = cv->width;
			size.height = cv->height;
			
			
			aspectRatio = size.width/size.height;
		}
		else
		{
			null = true;
			size.width = 0;
			size.height = 0;
			aspectRatio = 1;
		}
		imageRect.size = size;
		imageRect.origin.x = 0;
		imageRect.origin.y = 0;
		
		startCenter = Vector2(0,0);
		endCenter = Vector2(0,0);
		rotation = GLKQuaternionIdentity;
		
		[self CalculateCorners];
	}
	return self;
}
- (id)initWithFilePath:(const char*)path Color:(Color)c BinaryImage:(bool)b NamePrefix:(NSString*)nP
{
	self = [super init];
	if(self)
	{
		currentPath = [[NSString stringWithUTF8String:path] retain];
		namePrefix = [nP retain];
		extenshion = [[currentPath pathExtension] retain];
		
		color = c;
		Cv = cv::imread(path);
		cv = new IplImage(Cv);
		
		data.glSet = false;
		binary = b;
		
		if(cv!=NULL)
		{
			null = false;
			//			size.width = cV.cols;
			//			size.height = cV.rows;
			size.width = cv->width;
			size.height = cv->height;
			
			
			aspectRatio = size.width/size.height;
		}
		else
		{
			null = true;
			size.width = 0;
			size.height = 0;
			aspectRatio = 1;
		}
		imageRect.size = size;
		imageRect.origin.x = 0;
		imageRect.origin.y = 0;
		
		startCenter = Vector2(0,0);
		endCenter = Vector2(0,0);
		rotation = GLKQuaternionIdentity;
		
		[self CalculateCorners];
	}
	return self;
}
- (id)initWithNamePrefix:(NSString*)nP
{
	self = [self init];
	if(self)
	{
		namePrefix = [nP retain];
		currentPath = nil;
		extenshion = [@".JPG" retain];
	}
	return self;
}
- (id)initWithIplImage:(IplImage*)image Color:(Color)c BinaryImage:(bool)b NamePrefix:(NSString*)nP
{
	self = [self initWithIplImage:image Color:c BinaryImage:b];
	if(self)
	{
		namePrefix = [nP retain];
		currentPath = nil;
		extenshion = [@".JPG" retain];
	}
	return self;
}
- (id)initWithCVMat:(cv::Mat)image Color:(Color)c BinaryImage:(bool)b NamePrefix:(NSString*)nP
{
	self = [self initWithCVMat:image Color:c BinaryImage:b];
	if(self)
	{
		namePrefix = [nP retain];
		currentPath = nil;
		extenshion = [@".JPG" retain];
	}
	return self;
}
- (id)copy
{
	cv::Mat copyedMat;
	Cv.copyTo(copyedMat);
	OpenImageHandler*copiedImage = [[OpenImageHandler alloc] initWithCVMat:copyedMat Color:color BinaryImage:binary];
	copiedImage.namePrefix = namePrefix;
	copiedImage.currentPath = nil;
	copiedImage.extenshion = extenshion;
	return copiedImage;
}

- (void)SetRenderOffset:(Vector2)renderOffset
{
	[lock lockForWriting];
	imageRect.origin = CGPointMake(renderOffset.x, renderOffset.y);
	[lock unlock];
}
- (GLuint)gl
{
	if(!data.glSet)
	{
		if([self LoadGLTexture])
		{
			data.glSet = true;
		}
		else
		{
			NSString *error =  [NSString stringWithFormat:@"The IplImage in OpenImageHanlder:%@ is NULL, cannot get gl version.", self];
			NSAssert(false,error);
			[lock unlock];
			return nil;
		}
	}
	GLenum gl = data.gl;
	return gl;
}
- (bool)LoadGLTexture
{
	//Ref: http://www.gamedev.net/page/resources/_/technical/opengl/opengl-texture-mapping-an-introduction-r947
    if (null) return false;
    glGenTextures(1, data.glAddress);
    glBindTexture( GL_TEXTURE_2D, data.gl );
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
//	if(format==GL_LUMINANCE)
//	{
//		glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, size.width, size.height,0, GL_ALPHA, GL_UNSIGNED_BYTE, cv->imageData);
//	}
//	else
//	{
//		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, size.width, size.height,0, format, GL_UNSIGNED_BYTE, cv->imageData);
//	}
	GLenum type = CVtoGLtype[Cv.depth()];
	if(binary)
	{
		glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, size.width, size.height,0, GL_ALPHA, type, cv->imageData);
	}
	else
	{
		switch(Cv.channels())
		{
			case 1:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, size.width, size.height,0, GL_LUMINANCE, type, cv->imageData);
				break;
			case 2:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, size.width, size.height,0, GL_LUMINANCE_ALPHA, type, cv->imageData);
				break;
			case 3:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, size.width, size.height,0, GL_BGR, type, cv->imageData);
				break;
			case 4:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height,0, GL_BGRA, type, cv->imageData);
				break;
			default:
				NSAssert(false, @"You must have 1 to 4 channels in the CV::Mat to glTexture convershion function!");
				break;
		}
	}
    return true;
}
- (Vector3)MouseOverPointForScreenPoint:(Vector2)screenPoint UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	Vector2 imagePoint = spaceConverter.ScreenToImageVector(screenPoint);
	return Vector3(floor(imagePoint.x)+0.5,floor(imagePoint.y)+0.5,0);
}
- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
//	if([self BeginGraphingUsingSpaceConverter:spaceConverter])
	{
		glColor4f(color.r/255.0, color.g/255.0, color.b/255.0, 1);
		
		[lock lock];
		if(data.ObjectChanged)
		{
			[data deallocImage];
			data.ObjectChanged = false;
		}
		
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, self.gl);
		glBegin(GL_TRIANGLE_STRIP);
		{
			Vector2 LL_temp = spaceConverter.ImageToCameraVector(LL);
			Vector2 UL_temp = spaceConverter.ImageToCameraVector(UL);
			Vector2 UR_temp = spaceConverter.ImageToCameraVector(UR);
			Vector2 LR_temp = spaceConverter.ImageToCameraVector(LR);
			
			glTexCoord2f(0.0, 0.0);
			glVertex3f(LL_temp.x, LL_temp.y, minZ);
			
			glTexCoord2f(0.0, -1.0);
			glVertex3f(UL_temp.x, UL_temp.y, minZ);
			
			glTexCoord2f(1.0, 0.0);
			glVertex3f(LR_temp.x, LR_temp.y, minZ);
			
			glTexCoord2f(1.0, -1.0);
			glVertex3f(UR_temp.x,  UR_temp.y, minZ);
		}
		glEnd();
		glDisable(GL_TEXTURE_2D);
		[lock unlock];
	}
//	[self EndGraphing];
}
- (void)CalculateCorners
{
	LL = Vector3(Vector2(0,imageRect.size.height)						+imageRect.origin-startCenter).RotatedBy(rotation).AsVector2() + endCenter;
	UL = Vector3(Vector2(0, 0)											+imageRect.origin-startCenter).RotatedBy(rotation).AsVector2() + endCenter;
	UR = Vector3(Vector2(imageRect.size.width, 0)						+imageRect.origin-startCenter).RotatedBy(rotation).AsVector2() + endCenter;
	LR = Vector3(Vector2(imageRect.size.width,imageRect.size.height)	+imageRect.origin-startCenter).RotatedBy(rotation).AsVector2() + endCenter;
}
- (void)SaveAtPath:(NSString*)path
{
	[lock lock];
	cvSaveImage(path.UTF8String, cv);
	[lock unlock];
}


- (NSDictionary*)MetaData
{
	return nil;
	[lock lock];
	if(currentPath)
	{
		CGImageSourceRef source = CGImageSourceCreateWithURL( (CFURLRef)[NSURL fileURLWithPath:currentPath], NULL);
		NSDictionary* metadata = (NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
		
		//Upload Part Meta Data
		NSDictionary*ExpandedImageMetaData = [self ExpandedMetaDateDictionaryForMetaData:metadata];
		CFRelease(source);
		[metadata release];
		[lock unlock];
		return ExpandedImageMetaData;
	}
	[lock unlock];
	return nil;
}
- (NSDictionary*)ExpandedMetaDateDictionaryForMetaData:(NSDictionary*)metaData
{
	[lock lock];
	NSMutableArray*Keys = [[NSMutableArray alloc] initWithCapacity:50];
	NSMutableArray*Values = [[NSMutableArray alloc] initWithCapacity:50];
	
	for(NSString*Key in metaData.allKeys)
	{
		if([Key hasPrefix:@"{"])
		{
			NSString*rootKey = [[Key stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""];
			
			NSDictionary*ValuesOfKey = [metaData objectForKey:Key];
			for(int i=0; i<ValuesOfKey.count; i++)
			{
				id value = [[ValuesOfKey allValues] objectAtIndex:i];
				
				[Keys addObject:[NSString stringWithFormat:@"%@.%@",rootKey,[[ValuesOfKey allKeys] objectAtIndex:i]]];
				[Values addObject:[self stringForPartMetaDateQueryByAppendingValue:value]];
			}
		}
		else
		{
			[Keys addObject:Key];
			[Values addObject:[self stringForPartMetaDateQueryByAppendingValue:[metaData objectForKey:Key]]];
		}
	}
	NSDictionary*dict = [NSDictionary dictionaryWithObjects:Values forKeys:Keys];
	[Values release];
	[Keys release];
	[lock unlock];
	return dict;
}
- (NSString*)stringForPartMetaDateQueryByAppendingValue:(id)value
{
	[lock lock];
	NSString*OUT = @"";
	NSString*className = [[value class] description];
	if([className isEqualToString:@"__NSCFNumber"] || [className isEqualToString:@"__NSCFConstantString"] || [className isEqualToString:@"__NSCFString"])
	{
		OUT = [value description];
	}
	else if([className isEqualToString:@"__NSArrayM"])
	{
		OUT = [[((NSArray*)value) valueForKey:@"description"] componentsJoinedByString:@"."];
	}
	else
	{
		NSLog(@"Class %@ Not supported!",className);
	}
	[lock unlock];
	return OUT;
}

+ (OpenImageHandler*)ZerosWithSize:(CGSize)s
{
	return [[[OpenImageHandler alloc] initWithCVMat:cv::Mat::zeros(s.height, s.width, CV_8UC1) Color:White BinaryImage:YES] autorelease];
}
+ (OpenImageHandler*)WhiteWithSize:(CGSize)s
{
	return [[[OpenImageHandler alloc] initWithCVMat:cv::Mat(s.height, s.width, CV_8UC1, 255) Color:White BinaryImage:YES] autorelease];
}
- (OpenImageHandler*)GreyScaled
{
	[lock lock];
	cv::Mat grey;
	if(Cv.channels()>1)
	{
		cv::cvtColor(Cv, grey, CV_BGR2GRAY);
	}
	else
	{
		grey = Cv.clone();
	}
	[lock unlock];
	return [[[OpenImageHandler alloc] initWithCVMat:grey Color:color BinaryImage:binary NamePrefix:namePrefix] autorelease];
}
- (OpenImageHandler*)BGR_2_HSV
{
	[lock lock];
	cv::Mat thisImage = self.Cv;
//	NSAssert(thisImage.channels()==3, @"BGR_2_HSV only supports three channel images!");
	
	cv::Mat hsv;
	cv::cvtColor(thisImage, hsv, cv::COLOR_BGR2HSV);
	[lock unlock];
	OpenImageHandler*HSV = [[OpenImageHandler alloc] initWithCVMat:hsv Color:Color(255,255,255) BinaryImage:NO];
	return [HSV autorelease];
}
- (OpenImageHandler*)BGR_2_YCrCb
{
	cv::Mat thisImage = self.Cv;
//	NSAssert(thisImage.channels()==3, @"BGR_2_YCbCr only supports three channel images!");
	
	cv::Mat hsv;
	cv::cvtColor(thisImage, hsv, cv::COLOR_BGR2YCrCb);
	[lock unlock];
	OpenImageHandler*HSV = [[OpenImageHandler alloc] initWithCVMat:hsv Color:Color(255,255,255) BinaryImage:NO];
	return [HSV autorelease];
}
- (OpenImageHandler*)HSV_2_BGR
{
	[lock lock];
	cv::Mat thisImage = self.Cv;
//	NSAssert(thisImage.channels()==3, @"HSV_2_BGR only supports three channel images!");
	
	cv::Mat bgr;
	cv::cvtColor(thisImage, bgr, cv::COLOR_HSV2BGR);
	[lock unlock];
	OpenImageHandler*HSV = [[OpenImageHandler alloc] initWithCVMat:bgr Color:Color(255,255,255) BinaryImage:NO];
	return [HSV autorelease];
}
- (OpenImageHandler*)GREY_2_FalseColor
{
	[lock lock];
	cv::Mat thisImage = self.Cv;
//	NSAssert(thisImage.channels()==1, @"GREY_2_FalseColor only supports single channel images!");
	
	cv::Mat ones = cv::Mat(thisImage.rows, thisImage.cols, thisImage.type(), 255);
	std::vector<cv::Mat> channels;
    channels.push_back(thisImage);
    channels.push_back(ones);
    channels.push_back(ones);
	cv::Mat H11;
	cv::merge(channels, H11);
	[lock unlock];
	
	cv::Mat falseColor;
	cv::cvtColor(H11, falseColor, cv::COLOR_HSV2BGR);
	
	OpenImageHandler*FALSE_COLOR = [[OpenImageHandler alloc] initWithCVMat:falseColor Color:Color(255,255,255) BinaryImage:NO];
	return [FALSE_COLOR autorelease];
}
- (OpenImageHandler*)BGR_2_H_FalseColor
{
	//	NSAssert(self.Cv.channels()==3, @"BGR_2_H_FalseColor only supports three channel images!");
	return [[[[self BGR_2_HSV] Channels] objectAtIndex:0] GREY_2_FalseColor];
}
- (OpenImageHandler*)HSV_2_H_FalseColor
{
	//	NSAssert(self.Cv.channels()==3, @"BGR_2_H_FalseColor only supports three channel images!");
	return [[[self Channels] objectAtIndex:0] GREY_2_FalseColor];
}
- (OpenImageHandler*)SobelOfOrder:(Vector2)order
{
	cv::Mat output;
	cv::Sobel(Cv, output, Cv.depth(), order.x, order.y, 7);
	
	OpenImageHandler*Sobel = [[OpenImageHandler alloc] initWithCVMat:output Color:Color(255,255,255) BinaryImage:NO];
	return [Sobel autorelease];
}

- (NSArray*)Channels
{
	[lock lock];
	cv::Mat thisImage = self.Cv;
	
	std::vector<cv::Mat> channels;
	
	cv::split(thisImage, channels);
	[lock lock];
	
	NSMutableArray*Channels = [[NSMutableArray alloc] initWithCapacity:thisImage.channels()];
	for(int i=0; i<thisImage.channels(); i++)
	{
		OpenImageHandler*channel = [[OpenImageHandler alloc] initWithCVMat:channels[i] Color:Color(255,255,255) BinaryImage:NO];
		[Channels addObject:channel];
		[channel release];
	}
	return [NSArray arrayWithArray:[Channels autorelease]];
}
- (OpenImageHandler*)ThreeChannel
{
	NSArray*Chans = [self Channels];
	std::vector<cv::Mat> channels;
	if(Chans.count>=3)
	{
		channels.push_back(((OpenImageHandler*)[Chans objectAtIndex:0]).Cv);
		channels.push_back(((OpenImageHandler*)[Chans objectAtIndex:1]).Cv);
		channels.push_back(((OpenImageHandler*)[Chans objectAtIndex:2]).Cv);
	}
	else
	{
		channels.push_back(((OpenImageHandler*)[Chans objectAtIndex:0]).Cv);
		channels.push_back(((OpenImageHandler*)[Chans objectAtIndex:0]).Cv);
		channels.push_back(((OpenImageHandler*)[Chans objectAtIndex:0]).Cv);
	}
	
	cv::Mat threeChan;
	cv::merge(channels, threeChan);
	
	return [[[OpenImageHandler alloc] initWithCVMat:threeChan Color:color BinaryImage:binary] autorelease];
}
- (OpenImageHandler*)Normalized
{
	NSArray*channels = [self Channels];
	for(int i=0; i<channels.count; i++)
	{
		cv::Mat chan = ((OpenImageHandler*)[channels objectAtIndex:i]).Cv;
		cv::normalize(chan, chan, 0, 255, cv::NORM_MINMAX, CV_8UC1);
	}
	
	return [[[OpenImageHandler alloc] initWithChannels:channels Color:Color(255,255,255) BinaryImage:NO] autorelease];
}
- (OpenImageHandler*)EqualizeHistograms
{
	NSArray*channels = [self Channels];
	for(int i=0; i<channels.count; i++)
	{
		cv::Mat chan = ((OpenImageHandler*)[channels objectAtIndex:i]).Cv;
		cv::equalizeHist(chan, chan);
		
		//		cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE(2.0, cv::Size(8,8));
		//		clahe->apply(chan, chan);
	}
	
	return [[[OpenImageHandler alloc] initWithChannels:channels Color:Color(255,255,255) BinaryImage:NO] autorelease];
}
- (OpenImageHandler*)FloodFillResultFromPoint:(Vector2)seed WithChangeInColorFromSeedLower:(Color)lowerDif Upper:(Color)upperDif
{
	uchar fillValue = 255;
	cv::Mat floodFilled_Boardered = cv::Mat::zeros(imageRect.size.height+2, imageRect.size.width+2, CV_8UC1);
	
	[lock lockForWriting];
	int fillResult = cv::floodFill(Cv, floodFilled_Boardered, seed.AsCvPoint(), cv::Scalar(255,255,255), NULL, lowerDif.AsCVScaler(), upperDif.AsCVScaler(), cv::FLOODFILL_FIXED_RANGE | cv::FLOODFILL_MASK_ONLY | (fillValue << 8));
	[lock unlock];
	
	NSLog(@"Fill Result:%i",fillResult);
	cv::Mat floodFilledMat = floodFilled_Boardered(cv::Rect(1,1,imageRect.size.width,imageRect.size.height));
	OpenImageHandler*floodFilled = [[OpenImageHandler alloc] initWithCVMat:floodFilledMat Color:Color(255,255,255) BinaryImage:NO];
	
	return floodFilled;
}
float absf(float val)
{
	return val < 0 ? -val : val;
}
- (OpenImageHandler*)Demosiaced
{
	NSLog(@"DEMO");
	//See: http://tx.technion.ac.il/~rc/Demosaicing_algorithms.pdf Algorythm 8 "Directionally Weighted Gradient Based Interpolation" or http://www.arl.army.mil/arlreports/2010/ARL-TR-5061.pdf
	
	cv::Mat image = Cv; if(Cv.channels()>1) image = [self GreyScaled].Cv;
	cv::Mat demosiaced = cv::Mat::zeros(imageRect.size.height,imageRect.size.width,CV_8UC3);
	
	int imageStep = image.step[1];
	int demosiacedStep = demosiaced.step[1];
	
	
	//Iterate Rs and Bs and Interpolate Gs while gathering knowns:
	uchar*imageRowY_minus2;
	uchar*imageRowY_minus1 = image.ptr(1-1);
	uchar*imageRowY_center = image.ptr(1);
	uchar*imageRowY_added1 = image.ptr(1+1);
	uchar*imageRowY_added2 = image.ptr(1+2);
	
	for(int y=2; y<image.rows-2; y++)
	{
		imageRowY_minus2 = imageRowY_minus1;
		imageRowY_minus1 = imageRowY_center;
		imageRowY_center = imageRowY_added1;
		imageRowY_added1 = imageRowY_added2;
		imageRowY_added2 = image.ptr(y+2);
		
		uchar*demosiacedRowY = demosiaced.ptr(y);
		
		for(int x=2 + y%2; x<image.cols-2; x+=2)
		{
			int xIndex = x*demosiacedStep;
			
			int xIndex_m2 = (x-2)*imageStep;
			int xIndex_m1 = xIndex_m2+imageStep;
			int xIndex_c0 = xIndex_m1+imageStep;
			int xIndex_p1 = xIndex_c0+imageStep;
			int xIndex_p2 = xIndex_p1+imageStep;
			
			//*******************************************************************************************************************************************************************************************************************************
																										float C1 = imageRowY_minus2[ xIndex_c0 ];
																										float G2 = imageRowY_minus1[ xIndex_c0 ];
			
			float C3 = imageRowY_center[ xIndex_m2 ];	float G4 = imageRowY_center[ xIndex_m1 ];		float C5 = imageRowY_center[ xIndex_c0 ];		float G6 = imageRowY_center[ xIndex_p1 ];	float C7 = imageRowY_center[ xIndex_p2 ];
			
																										float G8 = imageRowY_added1[ xIndex_c0 ];
																										float C9 = imageRowY_added2[ xIndex_c0 ];
			//*******************************************************************************************************************************************************************************************************************************
			
			float Gn = absf( G8 - G2 ) + absf( C5 - C1 );
			float Ge = absf( G4 - G6 ) + absf( C5 - C7 );
			float Gs = absf( G2 - G8 ) + absf( C5 - C9 );
			float Gw = absf( G6 - G4 ) + absf( C5 - C3 );
			
			float Wn = 1.0/(1.0+Gn);
			float We = 1.0/(1.0+Ge);
			float Ws = 1.0/(1.0+Gs);
			float Ww = 1.0/(1.0+Gw);
			
			float Gn_norm = G2 + absf( C5 - C1 )/2.0;
			float Ge_norm = G6 + absf( C5 - C7 )/2.0;
			float Gs_norm = G8 + absf( C5 - C9 )/2.0;
			float Gw_norm = G4 + absf( C5 - C3 )/2.0;
			
			float green = (Wn * Gn_norm + We * Ge_norm + Ws * Gs_norm + Ww * Gw_norm) / (Wn + We + Ws + Ww);
			demosiacedRowY[xIndex+1] = green;
			
			if(x%2) //Curent x,y is a Bayer Red pixel
			{
				demosiacedRowY[xIndex  ] = C5;
			}
			else//Curent x,y is a Bayer Blue pixel
			{
				demosiacedRowY[xIndex+2] = C5;
			}
		}
	}
	
	//Re-Iterate Rs and Bs and Interpolate Bs and Rs while gathering knowns:
	imageRowY_minus1;
	imageRowY_center = image.ptr(1);
	imageRowY_added1 = image.ptr(1+1);
	
	uchar*demosiacedRowY_minus1;
	uchar*demosiacedRowY_center = demosiaced.ptr(1);
	uchar*demosiacedRowY_added1 = demosiaced.ptr(1+1);
	
	for(int y=2; y<image.rows-2; y++)
	{
		imageRowY_minus1 = imageRowY_center;
		imageRowY_center = imageRowY_added1;
		imageRowY_added1 = image.ptr(y+1);
		
		demosiacedRowY_minus1 = demosiacedRowY_center;
		demosiacedRowY_center = demosiacedRowY_added1;
		demosiacedRowY_added1 = demosiaced.ptr(y+1);
		
		for(int x=2 + y%2; x<image.cols-2; x+=2)
		{
			int image_xIndex_m1 = (x-1)*imageStep;
			int image_xIndex_c0 = image_xIndex_m1+imageStep;
			int image_xIndex_p1 = image_xIndex_c0+imageStep;
			
			int demosiaced_xIndex_m1 = (x-1)*demosiacedStep;
			int demosiaced_xIndex_c0 = demosiaced_xIndex_m1+demosiacedStep;
			int demosiaced_xIndex_p1 = demosiaced_xIndex_c0+demosiacedStep;
			
			//*****************************************************************************************************************************************************
			float C1 = imageRowY_minus1[ image_xIndex_m1 ];		float G2 = imageRowY_minus1[ image_xIndex_c0 ];		float C3 = imageRowY_minus1[ image_xIndex_p1 ];
			
			float G4 = imageRowY_center[ image_xIndex_m1 ];		float C5 = imageRowY_center[ image_xIndex_c0 ];		float G6 = imageRowY_center[ image_xIndex_p1 ];
			
			float C7 = imageRowY_added1[ image_xIndex_m1 ];		float G8 = imageRowY_added1[ image_xIndex_c0 ];		float C9 = imageRowY_added1[ image_xIndex_p1 ];
			//*****************************************************************************************************************************************************
			//*****************************************************************************************************************************************************
			float G1 = demosiacedRowY_minus1[ demosiaced_xIndex_m1+1 ];									float G3 = demosiacedRowY_minus1[ demosiaced_xIndex_p1+1 ];
			
															float G5 = demosiacedRowY_center[ demosiaced_xIndex_c0+1 ];
			
			float G7 = demosiacedRowY_added1[ demosiaced_xIndex_m1+1 ];									float G9 = demosiacedRowY_added1[ demosiaced_xIndex_p1+1 ];
			//*****************************************************************************************************************************************************
			
			float C_NE = absf( C7-C3 ) + absf( G5-G3 );
			float C_SE = absf( C1-C9 ) + absf( G5-G9 );
			float C_SW = absf( C3-C7 ) + absf( G5-G7 );
			float C_NW = absf( C9-C1 ) + absf( G5-G1 );
			
			float W_NE = 1/(1+C_NE);
			float W_SE = 1/(1+C_SE);
			float W_SW = 1/(1+C_SW);
			float W_NW = 1/(1+C_NW);
			
			float C_NE_norm = C3 + absf( G5-G3 )/2;
			float C_SE_norm = C9 + absf( G5-G9 )/2;
			float C_SW_norm = C7 + absf( G5-G7 )/2;
			float C_NW_norm = C1 + absf( G5-G1 )/2;
			
			float Color = (W_NE * C_NE_norm + W_SE * C_SE_norm + W_SW * C_SW_norm + W_NW * C_NW_norm) / (W_NE + W_SE + W_SW + W_NW);
			
			if(x%2) //Curent x,y is a Bayer Red pixel, set Blue
			{
				demosiacedRowY_center[demosiaced_xIndex_c0+2] = Color;
			}
			else //Curent x,y is a Bayer Blue pixel, set Red
			{
				demosiacedRowY_center[demosiaced_xIndex_c0  ] = Color;
			}
		}
	}

	
	demosiacedRowY_minus1;
	demosiacedRowY_center = demosiaced.ptr(1);
	demosiacedRowY_added1 = demosiaced.ptr(1+1);
	
	for(int y=2; y<image.rows-2; y++)
	{
		uchar*imageRowY = image.ptr(y);
		
		demosiacedRowY_minus1 = demosiacedRowY_center;
		demosiacedRowY_center = demosiacedRowY_added1;
		demosiacedRowY_added1 = demosiaced.ptr(y+1);
		
		for(int x=2 + !(y%2); x<image.cols-2; x+=2)
		{
			int image_xIndex = x*imageStep;
			
			int demosiaced_xIndex_m1 = (x-1)*demosiacedStep;
			int demosiaced_xIndex_c0 = demosiaced_xIndex_m1+demosiacedStep;
			int demosiaced_xIndex_p1 = demosiaced_xIndex_c0+demosiacedStep;
			
//			//**************************************************************************************************************************************************************************************************************************************************
//			float m2_m2 = imageRowY_minus2[ xIndex_m2 ];	float m1_m2 = imageRowY_minus2[ xIndex_m1 ];		float c0_m2 = imageRowY_minus2[ xIndex_c0 ];		float p1_m2 = imageRowY_minus2[ xIndex_p1 ];	float p2_m2 = imageRowY_minus2[ xIndex_p2 ];
//			float m2_m1 = imageRowY_minus1[ xIndex_m2 ];	float m1_m1 = imageRowY_minus1[ xIndex_m1 ];		float c0_m1 = imageRowY_minus1[ xIndex_c0 ];		float p1_m1 = imageRowY_minus1[ xIndex_p1 ];	float p2_m1 = imageRowY_minus1[ xIndex_p2 ];
//			
//			float m2_c0 = imageRowY_center[ xIndex_m2 ];	float m1_c0 = imageRowY_center[ xIndex_m1 ];		float c0_c0 = imageRowY_center[ xIndex_c0 ];		float p1_c0 = imageRowY_center[ xIndex_p1 ];	float p2_c0 = imageRowY_center[ xIndex_p2 ];
//			
//			float m2_p1 = imageRowY_added1[ xIndex_m2 ];	float m1_p1 = imageRowY_added1[ xIndex_m1 ];		float c0_p1 = imageRowY_added1[ xIndex_c0 ];		float p1_p1 = imageRowY_added1[ xIndex_p1 ];	float p2_p1 = imageRowY_added1[ xIndex_p2 ];
//			float m2_p2 = imageRowY_added2[ xIndex_m2 ];	float m1_p2 = imageRowY_added2[ xIndex_m1 ];		float c0_p2 = imageRowY_added2[ xIndex_c0 ];		float p1_p2 = imageRowY_added2[ xIndex_p1 ];	float p2_p2 = imageRowY_added2[ xIndex_p2 ];
//			//**************************************************************************************************************************************************************************************************************************************************
			
			float c0_c0 = imageRowY[ image_xIndex ];
			if(x%2)
			{
				//**************************************************************************************************************************************************
																			float c0_m1 = demosiacedRowY_minus1[ demosiaced_xIndex_c0 ];
				
				float m1_c0 = demosiacedRowY_center[ demosiaced_xIndex_m1+2 ];															float p1_c0 = demosiacedRowY_center[ demosiaced_xIndex_p1+2 ];
				
																			float c0_p1 = demosiacedRowY_added1[ demosiaced_xIndex_c0 ];
				//**************************************************************************************************************************************************
				
				demosiacedRowY_center[demosiaced_xIndex_c0  ] = (c0_m1+c0_p1)/2;
				demosiacedRowY_center[demosiaced_xIndex_c0+2] = (m1_c0+p1_c0)/2;
			}
			else
			{
				//**************************************************************************************************************************************************
																			float c0_m1 = demosiacedRowY_minus1[ demosiaced_xIndex_c0+2 ];
				
				float m1_c0 = demosiacedRowY_center[ demosiaced_xIndex_m1 ];															float p1_c0 = demosiacedRowY_center[ demosiaced_xIndex_p1 ];
				
																			float c0_p1 = demosiacedRowY_added1[ demosiaced_xIndex_c0+2 ];
				//**************************************************************************************************************************************************
				demosiacedRowY_center[demosiaced_xIndex_c0+2] = (c0_m1+c0_p1)/2;
				demosiacedRowY_center[demosiaced_xIndex_c0  ] = (m1_c0+p1_c0)/2;
			}
			
			demosiacedRowY_center[demosiaced_xIndex_c0+1] = c0_c0;
		}
	}
	NSLog(@"DEMO");
	return [[[OpenImageHandler alloc] initWithCVMat:demosiaced Color:White BinaryImage:NO] autorelease];
}
- (OpenImageHandler*)OpenedBy:(float)radius
{
	cv::Mat output;
	cv::Mat element = cv::getStructuringElement( cv::MORPH_ELLIPSE, cv::Size( 2*radius + 1, 2*radius+1 ), cv::Point( radius, radius ) );
	morphologyEx( Cv, output, cv::MORPH_OPEN, element );
	
	return [[[OpenImageHandler alloc] initWithCVMat:output Color:color BinaryImage:binary] autorelease];
}
- (OpenImageHandler*)ClosedBy:(float)radius
{
	cv::Mat output;
	cv::Mat element = cv::getStructuringElement( cv::MORPH_ELLIPSE, cv::Size( 2*radius + 1, 2*radius+1 ), cv::Point( radius, radius ) );
	morphologyEx( Cv, output, cv::MORPH_CLOSE, element );
	
	return [[[OpenImageHandler alloc] initWithCVMat:output Color:color BinaryImage:binary] autorelease];
}
- (OpenImageHandler*)DilatedBy:(float)radius
{
	cv::Mat output;
	cv::Mat element = cv::getStructuringElement( cv::MORPH_ELLIPSE, cv::Size( 2*radius + 1, 2*radius+1 ), cv::Point( radius, radius ) );
	morphologyEx( Cv, output, cv::MORPH_DILATE, element );
	
	return [[[OpenImageHandler alloc] initWithCVMat:output Color:color BinaryImage:binary] autorelease];
}
- (OpenImageHandler*)ErodedBy:(float)radius
{
	cv::Mat output;
	cv::Mat element = cv::getStructuringElement( cv::MORPH_ELLIPSE, cv::Size( 2*radius + 1, 2*radius+1 ), cv::Point( radius, radius ) );
	morphologyEx( Cv, output, cv::MORPH_ERODE, element );
	
	return [[[OpenImageHandler alloc] initWithCVMat:output Color:color BinaryImage:binary] autorelease];
}
- (OpenImageHandler*)internalMultiplyBy:(OpenImageHandler*)factor
{
	cv::Mat bla;
	factor.Cv.convertTo(bla, CV_64FC1);
	bla = bla/255;
	cv::Mat bla2;
	Cv.convertTo(bla2, CV_64FC1);
	cv::Mat result;
	result = bla2.mul(bla);
	result.convertTo(result, CV_8UC1);
	return [[[OpenImageHandler alloc] initWithCVMat:result Color:White BinaryImage:NO] autorelease];
}
- (OpenImageHandler*)MultiplyBy:(OpenImageHandler*)factor
{
	NSAssert((Cv.channels()>factor.Cv.channels() && factor.Cv.channels()==1) || (Cv.channels()==factor.Cv.channels()), @"Cannot multiply images for assertion: (selfChans.count>factorChans.count && factorChans.count==1) || (selfChans.count==factorChans.count) false");
	
	if(Cv.channels()==factor.Cv.channels())
	{
		return [self internalMultiplyBy:factor];
	}
	
	NSArray*selfChans = self.Channels;
	NSMutableArray*resultingChans = [[NSMutableArray alloc] initWithCapacity:selfChans.count];
	for(int i=0; i<selfChans.count; i++)
	{
		[resultingChans addObject:[[selfChans objectAtIndex:i] internalMultiplyBy:factor]];
	}
	OpenImageHandler*result = [[OpenImageHandler alloc] initWithChannels:resultingChans Color:White BinaryImage:NO];
	[resultingChans release];
	return [result autorelease];
}
- (OpenImageHandler*)GausianBlurUsingKernalSize:(Vector2)kSize Sigma:(double)sigma
{
	cv::Mat output;
	cv::GaussianBlur(Cv, output, kSize.AsCVSize(), sigma);
	return [[[OpenImageHandler alloc] initWithCVMat:output Color:color BinaryImage:binary] autorelease];
}
- (OpenImageHandler*)Subtract:(OpenImageHandler*)sub
{
	cv::Mat result;
	cv::subtract(Cv, sub.Cv, result);
	return [[[OpenImageHandler alloc] initWithCVMat:result Color:color BinaryImage:binary] autorelease];
}
- (void)MakeGreyScale
{
	[lock lockForWriting];
	cv::cvtColor(Cv, Cv, CV_BGR2GRAY);
	[lock unlock];
}

//Thread Safe Setters and Getters
- (cv::Mat)Cv
{
	[lock lock];
	cv::Mat toReturn = Cv;
	[lock unlock];
	return toReturn;
}

- (IplImage*)cv
{
	[lock lock];
	IplImage *toReturn = cv;
	[lock unlock];
	return toReturn;
}

- (OpenImageHandler *)Displayable
{
	cv::Mat returnable = Cv;
	if (Cv.type() == CV_32S || Cv.type() == CV_16S) {
		returnable = Cv/256;
		returnable.convertTo(returnable, CV_8UC(Cv.channels()));
	}
	else if(Cv.type() == CV_32F || Cv.type() == CV_64F)
	{
		returnable = Cv*255;
		returnable.convertTo(returnable, CV_8UC(Cv.channels()));
	}
	else{
		return self;
	}
	return [[OpenImageHandler alloc] initWithCVMat:returnable Color:White BinaryImage:binary];
}

- (void)setCvMat:(cv::Mat)cvMat
{
	[lock lockForWriting];
	
	if(ownsAnIPL)
	{
		cvReleaseImage(&cv);
	}
	else
	{
		Cv.release();
	}
	ownsAnIPL = false;
	
	Cv = cvMat;
	cv = new IplImage(Cv);
	
	if(cv!=NULL)
	{
		null = false;
		size.width = cv->width;
		size.height = cv->height;
		aspectRatio = size.width/size.height;
	}
	else
	{
		null = true;
		size.width = 0;
		size.height = 0;
		aspectRatio = 1;
	}
	imageRect.size = size;
	
	[self CalculateCorners];
	
	[self ObjectChanged];
	[lock unlock];
}

- (void)setCvIPL:(IplImage*)cvIPL
{
	[lock lock];
	
	if(ownsAnIPL)
	{
		cvReleaseImage(&cv);
	}
	else
	{
		Cv.release();
	}
	ownsAnIPL = true;
	
	cv = cvIPL;
	Cv = cv::cvarrToMat(cvIPL);
	
	if(cv!=NULL)
	{
		null = false;
		size.width = cv->width;
		size.height = cv->height;
		aspectRatio = size.width/size.height;
	}
	else
	{
		null = true;
		size.width = 0;
		size.height = 0;
		aspectRatio = 1;
	}
	imageRect.size = size;
	
	[self CalculateCorners];
	
	[self ObjectChanged];
	[lock unlock];
}

-(CGSize)size
{
	[lock lock];
	CGSize toReturn = size;
	[lock unlock];
	return toReturn;
}
-(CGRect)imageRect
{
	[lock lock];
	CGRect toReturn = imageRect;
	[lock unlock];
	return toReturn;
}

-(float)aspectRatio
{
	[lock lock];
	float toReturn = aspectRatio;
	[lock unlock];
	return toReturn;
}

-(GLint)format
{
	[lock lock];
	GLint toReturn = format;
	[lock unlock];
	return toReturn;
}

-(bool)null
{
	[lock lock];
	bool toReturn = null;
	[lock unlock];
	return toReturn;
}

+ (BOOL)ImageIsReadableAtPath:(NSString*)path
{
	NSString*ext = [[path pathExtension] uppercaseString];
	if([ext isEqualToString:@"JPG"]) return YES;
	if([ext isEqualToString:@"CR2"]) return YES;
	if([ext isEqualToString:@"PNG"]) return YES;
	if([ext isEqualToString:@"TIF"]) return YES;
	if([ext isEqualToString:@"TIFF"]) return YES;
	return NO;
}

- (void)dealloc
{
	if(!null)
	{
		if(ownsAnIPL)
		{
			cvReleaseImage(&cv);
		}
		else
		{
			Cv.release();
		}
	}
	[super dealloc];
}

@end