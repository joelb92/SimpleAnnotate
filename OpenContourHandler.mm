//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "OpenContourHandler.h"

@implementation OpenContourHandler
@synthesize contours;

- (id)initWithImage:(OpenImageHandler*)im
{
	self = [super init];
	if(self)
	{
		Image = [im retain];
		
		storage = cvCreateMemStorage();
		
		IplImage*imTemp = cvCreateImage(cvSize(im.imageRect.size.width, im.imageRect.size.height), IPL_DEPTH_8U, 1);
		cvCopy(im.cv, imTemp);
		cvFindContours(imTemp, storage, &contours, sizeof(CvContour), CV_RETR_TREE);
		cvReleaseImage(&imTemp);
	}
	return self;
}
- (id)initWithContourPoints:(Vector2Arr)contourPoints
{
	self = [super init];
	if(self)
	{
		storage = cvCreateMemStorage(0);
		contours = cvCreateSeq(CV_32SC2 | CV_SEQ_KIND_CURVE, sizeof(CvSeq), sizeof(CvPoint), storage);
		
		for(int i=0; i<contourPoints.Length; i++)
		{
			CvPoint point = contourPoints[i].AsCvPoint();
			cvSeqPush(contours,&point);
		}
	}
	return self;
}
- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	if([self BeginGraphingUsingSpaceConverter:spaceConverter])
	{
		CvSeq*contour = NULL;
		for(contour = contours; contour!=0; contour=contour->h_next)
		{
			CvPoint p;
			CvSeqReader reader;
			int N = contour->total;
			cvStartReadSeq(contour, &reader);
			
			glBegin(GL_LINE_LOOP);
			{
				for(int i=0; i<N; i++)
				{
					CV_READ_SEQ_ELEM(p, reader);
					Vector2 point = spaceConverter.ImageToCameraVector(Vector2(p));
					glVertex3f(point.x, point.y, minZ);
				}
			}
			glEnd();
		}
	}
	[self EndGraphing];
}

+ (Vector2)CentroidOfContour:(CvSeq*)contour
{
	Vector2 centroid = Vector2(NAN,NAN);
	if(contour)
	{
		CvMoments moments;
		double M00, M01, M10;
		cvMoments(contour,&moments);
		M00 = cvGetSpatialMoment(&moments,0,0);
		M10 = cvGetSpatialMoment(&moments,1,0);
		M01 = cvGetSpatialMoment(&moments,0,1);
		centroid.x = M10/M00;
		centroid.y = M01/M00;
	}
	return centroid;
}
+ (Vector2Arr)CentroidsOfContours:(CvSeqArr)conts
{
	Vector2Arr centroids = Vector2Arr(conts.Length);
	for(int i=0; i<conts.Length; i++)
	{
		centroids.AddItemToEnd([self CentroidOfContour:conts[i]]);
	}
	return centroids;
}
+ (double)AreaOfControur:(CvSeq*)contour
{
	return cvContourArea(contour);
}

+ (Vector2)FurthestPointOnContour:(CvSeq*)contour AlongDirection:(Vector2)direction FromLine:(Line2)line
{
	float maxSqDistance = 0;
	Vector2 furthestPoint = Vector2(NAN,NAN);
	
	Vector2 perpendicularDirection = line.Perpendicular().DirectionNormalized();
	if(direction.Dot(-perpendicularDirection) > direction.Dot(perpendicularDirection))
	{
		perpendicularDirection = -perpendicularDirection;
	}
	
	CvPoint p;
	CvSeqReader reader;
	int N = contour->total;
	cvStartReadSeq(contour, &reader);
	for(int i=0; i<N; i++)
	{
		CV_READ_SEQ_ELEM(p, reader);
		Vector2 vert = Vector2(p);
		if((vert-line.point1).Dot(perpendicularDirection)>0)
		{
			Vector2 projection = line.ProjectionOfPoint(vert);
			float sqDist = (vert-projection).SqMagnitude();
			if(sqDist>maxSqDistance)
			{
				maxSqDistance = sqDist;
				furthestPoint = vert;
			}
		}
	}
	return furthestPoint;
}
+ (Vector2Arr)LineCastContour:(CvSeq*)contour WithLine:(Line2)line
{
	CvPoint p;
	CvSeqReader reader;
	int N = contour->total;
	cvStartReadSeq(contour, &reader);
	
	Vector2Arr returnCollishions = Vector2Arr(N);
	
	Vector2 vert1;
	CV_READ_SEQ_ELEM(p, reader);
	Vector2 vert2 = Vector2(p);
	for(int i=0; i<N-1; i++)
	{
		vert1 = vert2;
		CV_READ_SEQ_ELEM(p, reader);
		vert2 = Vector2(p);
		
		LineSegment2 segment = LineSegment2(vert1,vert2);
		
		Vector2 intersect;
		if(segment.IntersectionWith(&intersect, line))
		{
			returnCollishions.AddItemToEnd(intersect);
		}
	}
	
	return returnCollishions;
}
+ (void)FillContour:(CvSeq*)contour OnImage:(OpenImageHandler*)image With:(cv::Scalar)color
{
	cvDrawContours(image.cv, contour, color, color, 0, CV_FILLED);
}
+ (void)FillContours:(CvSeqArr)contours OnImage:(OpenImageHandler*)image With:(cv::Scalar)color
{
	IplImage*im = image.cv;
	for(int i=0; i<contours.Length; i++)
	{
		cvDrawContours(im, contours[i], color, color, 0, CV_FILLED);
	}
}

- (CvSeqArr)OuterContoursWithAnAreaInRange:(Vector2)range
{
	CvSeqArr outputContours = CvSeqArr(1);
	for(CvSeq*contour = contours; contour!=0; contour=contour->h_next)
	{
		float area = cvContourArea(contour);
		if(area>=range.x && area<=range.y)
		{
			outputContours.AddItemToEnd(contour);
		}
	}
	return outputContours;
}
- (CvSeqArr)SolidOuterContoursWithAnAreaInRange:(Vector2)range
{
	CvSeqArr outputContours = CvSeqArr(1);
	for(CvSeq*contour = contours; contour!=0; contour=contour->h_next)
	{
		if(contour->v_next==0)
		{
			float area = cvContourArea(contour);
			if(area>=range.x && area<=range.y)
			{
				outputContours.AddItemToEnd(contour);
			}
		}
	}
	return outputContours;
}
- (CvSeqArr)HollowedOuterContoursWithAnAreaInRange:(Vector2)range
{
	CvSeqArr outputContours = CvSeqArr(1);
	for(CvSeq*contour = contours; contour!=0; contour=contour->h_next)
	{
		if(contour->v_next!=0)
		{
			float area = cvContourArea(contour);
			if(area>=range.x && area<=range.y)
			{
				outputContours.AddItemToEnd(contour);
			}
		}
	}
	return outputContours;
}

- (CvSeqArr)ContoursInsideContour:(CvSeq*)outerContour WithAnAreaInRange:(Vector2)range
{
	CvSeqArr outputContours = CvSeqArr(1);
	for(CvSeq*contour = outerContour->v_next; contour!=0; contour=contour->h_next)
	{
		float area = cvContourArea(contour);
		if(area>=range.x && area<=range.y)
		{
			outputContours.AddItemToEnd(contour);
		}
	}
	return outputContours;
}
- (CvSeqArr)SolidContoursInsideContour:(CvSeq*)outerContour WithAnAreaInRange:(Vector2)range
{
	CvSeqArr outputContours = CvSeqArr(1);
	for(CvSeq*contour = outerContour->v_next; contour!=0; contour=contour->h_next)
	{
		if(contour->v_next==0)
		{
			float area = cvContourArea(contour);
			if(area>=range.x && area<=range.y)
			{
				outputContours.AddItemToEnd(contour);
			}
		}
	}
	return outputContours;
}
- (CvSeqArr)HollowedContoursInsideContour:(CvSeq*)outerContour WithAnAreaInRange:(Vector2)range
{
	CvSeqArr outputContours = CvSeqArr(1);
	for(CvSeq*contour = outerContour->v_next; contour!=0; contour=contour->h_next)
	{
		if(contour->v_next!=0)
		{
			float area = cvContourArea(contour);
			if(area>=range.x && area<=range.y)
			{
				outputContours.AddItemToEnd(contour);
			}
		}
	}
	return outputContours;
}

- (void)dealloc
{
	[Image release];
	cvClearMemStorage(storage);
	cvReleaseMemStorage(&storage);
	[super dealloc];
}
@end
