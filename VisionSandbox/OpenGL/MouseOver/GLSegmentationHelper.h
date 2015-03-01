//
//  GLSegmentationHelper.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 06/19/14.
//
//

#import "GLViewTool.h"
#import "OpenImageHandler.h"
#import "GLViewListCommand.h"
#import "OpenContourHandler.h"
#import "ImageThresholdMask.h"
#import "SegmentationOperationCell.h"
#import "HistogramDisplay.h"
#import "LineSegment2.h"

typedef enum
{
	None,
	Include,
	Exclude,
	Erase
} SegmentationHelperPaintToolType;
@interface GLSegmentationHelper : GLViewTool
{
	OpenImageHandler*Image;
	SegmentationOperationCell*segmentationOperationCell;
	
	SegmentationHelperPaintToolType brushType;
	
	OpenImageHandler*Included;
	OpenImageHandler*Excluded;
	
	Vector2 previousImagePoint;
	Vector2 currentImagePoint;
	Vector2Arr draggedPoints;
	
	float safety;
	
	Vector2 shiftHeldMajorDirection;
	
	
	
	IBOutlet HistogramDisplay*ImageHistR;
	IBOutlet HistogramDisplay*ImageHistG;
	IBOutlet HistogramDisplay*ImageHistB;
	
	IBOutlet HistogramDisplay*IncludedHistR;
	IBOutlet HistogramDisplay*IncludedHistG;
	IBOutlet HistogramDisplay*IncludedHistB;
	
	IBOutlet HistogramDisplay*ExcludedHistR;
	IBOutlet HistogramDisplay*ExcludedHistG;
	IBOutlet HistogramDisplay*ExcludedHistB;
	
	IBOutlet HistogramDisplay*DeltaHistR;
	IBOutlet HistogramDisplay*DeltaHistG;
	IBOutlet HistogramDisplay*DeltaHistB;
}

- (void)Redraw;
- (void)ClearScreen;
@end
