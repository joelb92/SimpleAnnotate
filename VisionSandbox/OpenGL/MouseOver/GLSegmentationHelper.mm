//
//  GLSegmentationHelper.mm
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 06/19/14.
//
//

#import "GLSegmentationHelper.h"

@implementation GLSegmentationHelper
- (id)init
{
	self = [super init];
	if(self)
	{
		brushType = None;
		
		draggedPoints = Vector2Arr();
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetInputImage:) name:@"Input Image Return" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OpenSegmentationAssistant:) name:@"Open Segmentation Assistant!" object:nil];
		
		safety = 0.5;
	}
	return self;
}
- (void)awakeFromNib
{
	ImageHistR.color = [NSColor redColor];
	ImageHistG.color = [NSColor greenColor];
	ImageHistB.color = [NSColor blueColor];
	
	IncludedHistR.color = [NSColor redColor];
	IncludedHistG.color = [NSColor greenColor];
	IncludedHistB.color = [NSColor blueColor];
	
	ExcludedHistR.color = [NSColor redColor];
	ExcludedHistG.color = [NSColor greenColor];
	ExcludedHistB.color = [NSColor blueColor];
	
	DeltaHistR.color = [NSColor redColor];
	DeltaHistG.color = [NSColor greenColor];
	DeltaHistB.color = [NSColor blueColor];
}
- (void)OpenSegmentationAssistant:(NSNotification*)note
{
	if(segmentationOperationCell)
	{
		[segmentationOperationCell release];
		segmentationOperationCell = nil;
	}
	segmentationOperationCell = [note.object retain];
}
- (void)GraphUsingSpaceConverter:(SpaceConverter)spaceConverter
{
	if(!mousePos.isNull())
	{
		glLineWidth(3);
		glColor3f(1, 1, 1);
		glBegin(GL_LINE_LOOP);
		{
			Vector2 mP = spaceConverter.ScreenToImageVector(mousePos).Floored();
			Vector2 p1 = spaceConverter.ImageToCameraVector( (mP+Vector2( 1.0, 1.0)) );
			Vector2 p2 = spaceConverter.ImageToCameraVector( (mP+Vector2( 0.0, 1.0)) );
			Vector2 p3 = spaceConverter.ImageToCameraVector( (mP+Vector2( 0.0, 0.0)) );
			Vector2 p4 = spaceConverter.ImageToCameraVector( (mP+Vector2( 1.0, 0.0)) );
			
			glVertex3f(p1.x, p1.y, minZ);
			glVertex3f(p2.x, p2.y, minZ);
			glVertex3f(p3.x, p3.y, minZ);
			glVertex3f(p4.x, p4.y, minZ);
		}
		glEnd();
	}
}
- (IBAction)SetSafety:(id)sender
{
	safety = ((NSSlider*)sender).doubleValue;
	[self CalculateThreshold:nil];
}
- (IBAction)SetInputImage:(id)obj
{
	if([obj isKindOfClass:NSNotification.class])
	{
		if(Image)
		{
			[Image release];
			Image = nil;
		}
		Image = [((NSNotification*)obj).object retain];
	}
	else [[NSNotificationCenter defaultCenter] postNotificationName:@"Input Image Requested" object:nil];
}
- (IBAction)PaintIncluded:(id)sender
{
	brushType = Include;
}
- (IBAction)PaintExcluded:(id)sender
{
	brushType = Exclude;
}
- (IBAction)ClearIncluded:(id)sender
{
	[Included release]; Included = nil;
	[self Redraw];
}
- (IBAction)ClearExcluded:(id)sender
{
	[Excluded release]; Excluded = nil;
	[self Redraw];
}
- (IBAction)CalculateThreshold:(id)sender
{
	if(Image && Included && Excluded)
	{
		Vector3Arr incHist = Vector3Arr(256,Vector3(0,0,0));
		Vector3Arr excHist = Vector3Arr(256,Vector3(0,0,0));
		Vector3Arr deltaHist = Vector3Arr(256,Vector3(0,0,0));
		
		cv::Mat im = Image.Cv;
		cv::Mat inc = Included.Cv;
		cv::Mat exc = Excluded.Cv;
		
		int imStep = im.step[1];
		int incStep = inc.step[1];
		int excStep = exc.step[1];
		
		DoubleArr imgR = DoubleArr(256,0);
		DoubleArr imgG = DoubleArr(256,0);
		DoubleArr imgB = DoubleArr(256,0);
		
		for(int y=0; y<im.rows; y++)
		{
			uchar*imRowY = im.ptr(y);
			uchar*incRowY = inc.ptr(y);
			uchar*excRowY = exc.ptr(y);
			
			for(int x=0; x<im.cols; x++)
			{
				int imageX = x*imStep;
				Color BGR = Color(imRowY[imageX], imRowY[imageX+1], imRowY[imageX+2]);
				
				imgR[BGR.b] = imgR[BGR.b]+1;
				imgG[BGR.g] = imgG[BGR.g]+1;
				imgB[BGR.r] = imgB[BGR.r]+1;
				
				if(incRowY[x*incStep])
				{
					incHist[BGR.r] = incHist[BGR.r]+Vector3(1,0,0);
					incHist[BGR.g] = incHist[BGR.g]+Vector3(0,1,0);
					incHist[BGR.b] = incHist[BGR.b]+Vector3(0,0,1);
					
					deltaHist[BGR.r] = deltaHist[BGR.r]+Vector3(1,0,0);
					deltaHist[BGR.g] = deltaHist[BGR.g]+Vector3(0,1,0);
					deltaHist[BGR.b] = deltaHist[BGR.b]+Vector3(0,0,1);
				}
				if(excRowY[x*excStep])
				{
					excHist[BGR.r] = excHist[BGR.r]+Vector3(1,0,0);
					excHist[BGR.g] = excHist[BGR.g]+Vector3(0,1,0);
					excHist[BGR.b] = excHist[BGR.b]+Vector3(0,0,1);
					
					deltaHist[BGR.r] = deltaHist[BGR.r]-Vector3(1,0,0);
					deltaHist[BGR.g] = deltaHist[BGR.g]-Vector3(0,1,0);
					deltaHist[BGR.b] = deltaHist[BGR.b]-Vector3(0,0,1);
				}
			}
		}
		
		Color safeMin = Color(255,255,255);
		Color safeMax = Color(0,0,0);
		for(int i=0; i<255; i++)
		{
			Vector3 deltaBGR = deltaHist[i];
			
			if(safeMin.b==255 && deltaBGR.x>0) safeMin.b=i;
			if(safeMin.g==255 && deltaBGR.y>0) safeMin.g=i;
			if(safeMin.r==255 && deltaBGR.z>0) safeMin.r=i;
		}
		for(int i=255; i>0; i--)
		{
			Vector3 deltaBGR = deltaHist[i];
			
			if(safeMax.b==0 && deltaBGR.x>0) safeMax.b=i;
			if(safeMax.g==0 && deltaBGR.y>0) safeMax.g=i;
			if(safeMax.r==0 && deltaBGR.z>0) safeMax.r=i;
		}
		
		if(safeMin.r>safeMax.r && safeMin.g>safeMax.g && safeMin.b>safeMax.b)
		{
			//Not Possible
			return;
		}
		
		Color greedyMin = safeMin;
		Color greedyMax = safeMax;
		for(int i=greedyMin.b; i>=0; i--)
		{
			Vector3 deltaBGR = deltaHist[i];
			if(deltaBGR.x<0) break;
			greedyMin.b = i;
		}
		for(int i=greedyMin.g; i>=0; i--)
		{
			Vector3 deltaBGR = deltaHist[i];
			if(deltaBGR.y<0) break;
			greedyMin.g = i;
		}
		for(int i=greedyMin.r; i>=0; i--)
		{
			Vector3 deltaBGR = deltaHist[i];
			if(deltaBGR.z<0) break;
			greedyMin.r = i;
		}
		
		for(int i=greedyMax.b; i<=255; i++)
		{
			Vector3 deltaBGR = deltaHist[i];
			if(deltaBGR.x<0) break;
			greedyMax.b = i;
		}
		for(int i=greedyMax.g; i<=255; i++)
		{
			Vector3 deltaBGR = deltaHist[i];
			if(deltaBGR.y<0) break;
			greedyMax.g = i;
		}
		for(int i=greedyMax.r; i<=255; i++)
		{
			Vector3 deltaBGR = deltaHist[i];
			if(deltaBGR.z<0) break;
			greedyMax.r = i;
		}
		
		Color min = greedyMin.LerpToColorBy(safeMin, safety);
		Color max = greedyMax.LerpToColorBy(safeMax, safety);
		
		ImageThresholdMask*mask = [[ImageThresholdMask alloc] initWithImage:Image Color:Color(0,175,0) MinColor:min MaxColor:max];
		[GLViewListCommand AddObject:mask.Mask ToViewKeyPath:@"MainView" ForKeyPath:@"Mouse Over/Segmentation/mask"];
		[mask release];
		
		[segmentationOperationCell setObjectValue:(id)[[[SegmentationOperation alloc] initWithMinColor:min MaxColor:max] autorelease]];
		[segmentationOperationCell UpdateParentData];
		
		//Set Up Histogram Displays:
		DoubleArr incR = DoubleArr(256);
		DoubleArr incG = DoubleArr(256);
		DoubleArr incB = DoubleArr(256);
		DoubleArr excR = DoubleArr(256);
		DoubleArr excG = DoubleArr(256);
		DoubleArr excB = DoubleArr(256);
		DoubleArr delR = DoubleArr(256);
		DoubleArr delG = DoubleArr(256);
		DoubleArr delB = DoubleArr(256);
		
		for(int i=0; i<=255; i++)
		{
			Vector3 inc = incHist[i];
			Vector3 exc = excHist[i];
			Vector3 del = deltaHist[i];
			
			incR.AddItemToEnd(inc.z);
			incG.AddItemToEnd(inc.y);
			incB.AddItemToEnd(inc.x);
			excR.AddItemToEnd(exc.z);
			excG.AddItemToEnd(exc.y);
			excB.AddItemToEnd(exc.x);
			delR.AddItemToEnd(del.z);
			delG.AddItemToEnd(del.y);
			delB.AddItemToEnd(del.x);
		}
		
		[ImageHistR setValues:imgR]; [ImageHistR setMinIndex:min.r]; [ImageHistR setMaxIndex:max.r];
		[ImageHistG setValues:imgG]; [ImageHistG setMinIndex:min.g]; [ImageHistG setMaxIndex:max.g];
		[ImageHistB setValues:imgB]; [ImageHistB setMinIndex:min.b]; [ImageHistB setMaxIndex:max.b];
		
		[IncludedHistR setValues:incR]; [IncludedHistR setMinIndex:min.r]; [IncludedHistR setMaxIndex:max.r];
		[IncludedHistG setValues:incG]; [IncludedHistG setMinIndex:min.g]; [IncludedHistG setMaxIndex:max.g];
		[IncludedHistB setValues:incB]; [IncludedHistB setMinIndex:min.b]; [IncludedHistB setMaxIndex:max.b];
		
		[ExcludedHistR setValues:excR]; [ExcludedHistR setMinIndex:min.r]; [ExcludedHistR setMaxIndex:max.r];
		[ExcludedHistG setValues:excG]; [ExcludedHistG setMinIndex:min.g]; [ExcludedHistG setMaxIndex:max.g];
		[ExcludedHistB setValues:excB]; [ExcludedHistB setMinIndex:min.b]; [ExcludedHistB setMaxIndex:max.b];
		
		[DeltaHistR setValues:delR]; [DeltaHistR setMinIndex:min.r]; [DeltaHistR setMaxIndex:max.r];
		[DeltaHistG setValues:delG]; [DeltaHistG setMinIndex:min.g]; [DeltaHistG setMaxIndex:max.g];
		[DeltaHistB setValues:delB]; [DeltaHistB setMinIndex:min.b]; [DeltaHistB setMaxIndex:max.b];
		
		incHist.Deallocate();
		excHist.Deallocate();
		deltaHist.Deallocate();
	}
}
- (IBAction)Eraser:(id)sender
{
	brushType = Erase;
}
- (IBAction)ClearAll:(id)sender
{
	[Included release]; Included = nil;
	[Excluded release]; Excluded = nil;
	[self ClearScreen];
}
- (void)FloodFillDraggedContourIfApplicable
{
	if(draggedPoints.Length<3) return;
	
	LineSegment2 newSeg = LineSegment2(currentImagePoint,previousImagePoint);
	
	Vector2 p1;
	Vector2 p2 = previousImagePoint;
	for(int i=draggedPoints.Length-2; i>=0; i--)
	{
		p1 = p2;
		p2 = draggedPoints[i];
		
		LineSegment2 seg = LineSegment2(p1,p2);
		
		Vector2 interset;
		if(seg.IntersectionWith(&interset, newSeg) && interset!=previousImagePoint)
		{
			Vector2Arr contourPoints = Vector2Arr(draggedPoints.Length+2-i);
			for(int j=i; j<draggedPoints.Length; j++)
			{
				contourPoints.AddItemToEnd(draggedPoints[j]);
			}
			contourPoints.AddItemToEnd(interset);
			
			OpenContourHandler*contour = [[OpenContourHandler alloc] initWithContourPoints:contourPoints];
			
			switch(brushType)
			{
				case Include:
				{
					[OpenContourHandler FillContour:contour.contours OnImage:Included With:cv::Scalar(255)];
					[OpenContourHandler FillContour:contour.contours OnImage:Excluded With:cv::Scalar(0)];
				} break;
					
				case Exclude:
				{
					[OpenContourHandler FillContour:contour.contours OnImage:Included With:cv::Scalar(0)];
					[OpenContourHandler FillContour:contour.contours OnImage:Excluded With:cv::Scalar(255)];
				} break;
					
				case Erase:
				{
					[OpenContourHandler FillContour:contour.contours OnImage:Included With:cv::Scalar(0)];
					[OpenContourHandler FillContour:contour.contours OnImage:Excluded With:cv::Scalar(0)];
				} break;
					
				default: break;
			}
		}
	}
}
- (void)SetMousePosition:(Vector2)mouseP UsingSpaceConverter:(SpaceConverter)spaceConverter
{
	if(spaceConverter.type==_2d)
	{
		[super SetMousePosition:mouseP UsingSpaceConverter:spaceConverter];
		
		if(dragging && brushType!=None)
		{
			if(!Included)
			{
				cv::Mat inc = cv::Mat::zeros(spaceConverter.ImageRect.size.y, spaceConverter.ImageRect.size.x, CV_8UC1);
				Included = [[OpenImageHandler alloc] initWithCVMat:inc Color:White BinaryImage:YES];
			}
			if(!Excluded)
			{
				cv::Mat exc = cv::Mat::zeros(spaceConverter.ImageRect.size.y, spaceConverter.ImageRect.size.x, CV_8UC1);
				Excluded = [[OpenImageHandler alloc] initWithCVMat:exc Color:White BinaryImage:YES];
			}
			
			previousImagePoint = spaceConverter.ScreenToImageVector(previousMousePos);
			currentImagePoint = spaceConverter.ScreenToImageVector(mousePos);
			
			if(spaceConverter.ImageRect.ContainsPoint(currentImagePoint) && spaceConverter.ImageRect.ContainsPoint(previousImagePoint))
			{
				if(shiftHeld)
				{
					Vector2 startMouseImagePos = spaceConverter.ScreenToImageVector(startMousePos);
					startMouseImagePos = startMouseImagePos.MultiplyComponentsByComponentsOf(shiftHeldMajorDirection.SwitchedComponents());
					if(draggedPoints.Length>1)
					{
						previousImagePoint = previousImagePoint.MultiplyComponentsByComponentsOf(shiftHeldMajorDirection) + startMouseImagePos;
						currentImagePoint = currentImagePoint.MultiplyComponentsByComponentsOf(shiftHeldMajorDirection) + startMouseImagePos;
					}
					else if(draggedPoints.Length==1)
					{
						Vector2 delta = currentImagePoint-draggedPoints[0];
						if(fabs(delta.x)>fabs(delta.y)) shiftHeldMajorDirection = Vector2(1,0);
						else shiftHeldMajorDirection = Vector2(0,1);
						
						previousImagePoint = previousImagePoint.MultiplyComponentsByComponentsOf(shiftHeldMajorDirection) + startMouseImagePos;
						currentImagePoint = currentImagePoint.MultiplyComponentsByComponentsOf(shiftHeldMajorDirection) + startMouseImagePos;
					}
				}
				else [self FloodFillDraggedContourIfApplicable];
				
				draggedPoints.AddItemToEnd(currentImagePoint);
				
				LineSegment2 seg = LineSegment2(previousImagePoint.Floored(),currentImagePoint.Floored());
				Vector2Arr points = seg.RasterizedPoints();
				
				switch(brushType)
				{
					case Include:
					{
						for(int i=0; i<points.Length; i++)
						{
							Vector2 point = points[i];
							Included.Cv.at<unsigned char>(point.y,point.x) = 255;
							Excluded.Cv.at<unsigned char>(point.y,point.x) = 0;
						}
						[self Redraw];
					} break;
						
					case Exclude:
					{
						for(int i=0; i<points.Length; i++)
						{
							Vector2 point = points[i];
							Included.Cv.at<unsigned char>(point.y,point.x) = 0;
							Excluded.Cv.at<unsigned char>(point.y,point.x) = 255;
						}
						[self Redraw];
					} break;
						
					case Erase:
					{
						for(int i=0; i<points.Length; i++)
						{
							Vector2 point = points[i];
							Included.Cv.at<unsigned char>(point.y,point.x) = 0;
							Excluded.Cv.at<unsigned char>(point.y,point.x) = 0;
						}
						[self Redraw];
					} break;
						
					default: break;
				}
				points.Deallocate();
			}
		}
	}
}

- (void)Redraw
{
	if(Included)
	{
		OpenImageHandler*incDrawer = [[OpenImageHandler alloc] initWithCVMat:Included.Cv Color:Green BinaryImage:YES];
		[GLViewListCommand AddObject:incDrawer ToViewKeyPath:@"MainView" ForKeyPath:@"Mouse Over/Segmentation/Included"];
		[incDrawer release];
	}
	else [GLViewListCommand AddObject:nil ToViewKeyPath:@"MainView" ForKeyPath:@"Mouse Over/Segmentation/Included"];
	
	if(Excluded)
	{
		OpenImageHandler*excDrawer = [[OpenImageHandler alloc] initWithCVMat:Excluded.Cv Color:Red BinaryImage:YES];
		[GLViewListCommand AddObject:excDrawer ToViewKeyPath:@"MainView" ForKeyPath:@"Mouse Over/Segmentation/Excluded"];
		[excDrawer release];
	}
	else [GLViewListCommand AddObject:nil ToViewKeyPath:@"MainView" ForKeyPath:@"Mouse Over/Segmentation/Excluded"];
}
- (IBAction)ToggleLogarithmicHistogramDisplay:(id)sender
{
	[ImageHistR ToggleLogarithmicDisplay];
	[ImageHistG ToggleLogarithmicDisplay];
	[ImageHistB ToggleLogarithmicDisplay];
	[IncludedHistR ToggleLogarithmicDisplay];
	[IncludedHistG ToggleLogarithmicDisplay];
	[IncludedHistB ToggleLogarithmicDisplay];
	[ExcludedHistR ToggleLogarithmicDisplay];
	[ExcludedHistG ToggleLogarithmicDisplay];
	[ExcludedHistB ToggleLogarithmicDisplay];
	[DeltaHistR ToggleLogarithmicDisplay];
	[DeltaHistG ToggleLogarithmicDisplay];
	[DeltaHistB ToggleLogarithmicDisplay];
}

- (void)ClearScreen
{
	[GLViewListCommand AddObject:nil ToViewKeyPath:@"MainView" ForKeyPath:@"Mouse Over/Segmentation/Included"];
	[GLViewListCommand AddObject:nil ToViewKeyPath:@"MainView" ForKeyPath:@"Mouse Over/Segmentation/Excluded"];
	[GLViewListCommand AddObject:nil ToViewKeyPath:@"MainView" ForKeyPath:@"Mouse Over/Segmentation/mask"];
}

- (bool)StartDragging:(bool)withShift
{
	draggedPoints.Reset();
	return [super StartDragging:withShift];
}
- (void)StopDragging
{
	[super StopDragging];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"Input Image Return"];
	[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"Open Segmentation Assistant!"];
	draggedPoints.Deallocate();
	[super dealloc];
}
@end
