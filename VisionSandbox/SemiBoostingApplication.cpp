#include "SemiBoostingApplication.h"



void SemiBoostingApplication::initTracker(int nBC, float overlp, float searchFctr, cv::Rect intBB,cv::Mat initialImage)
{
    numBaseClassifier = nBC;
    overlap = overlp;
    searchFactor = searchFctr;
    initBB = Rect2(intBB.x,intBB.y,intBB.width,intBB.height);
    curFrame=NULL;
    int key;
    //choose the image source

            imageSequenceSource = (ImageSource *)(new ImageSource());
    
    imageSequence = new ImageHandler (imageSequenceSource);
    imageSequenceSource->injectImage(initialImage);
    imageSequence->getImage();

    
    trackingRect.upper = -1;
    trackingRect.left = -1;
    trackingRect.width = -1;
    trackingRect.height = -1;
    

        trackingRect=initBB;
    
    curFrame = imageSequence->getGrayImage ();
    curFrameRep = new ImageRepresentation(curFrame, imageSequence->getImageSize2());
    
    wholeImage = imageSequence->getImageSize2();
    
    printf ("init tracker...");
    tracker = new SemiBoostingTracker (curFrameRep, trackingRect, wholeImage, numBaseClassifier);
    printf (" done.\n");
    
    trackingRectSize2 = trackingRect;
    
    
    counter = 0;
}

cv::Rect SemiBoostingApplication::RunTrackIteration(cv::Mat newImage)
{
    //tracking loop
    
        //do tracking
        counter++;
        imageSequence->injectImage(newImage);
        if (curFrame!=NULL)
            delete[] curFrame;

        curFrame = imageSequence->getGrayImage ();
        if (curFrame == NULL)
            return cv::Rect();
    
        //calculate the patches within the search region
        Patches *trackingPatches;
        Rect2 searchRegion;
        if (!trackerLost)
        {
            searchRegion = tracker->getTrackingROI(searchFactor);
            trackingPatches = new PatchesRegularScan(searchRegion, wholeImage, trackingRectSize2, overlap);
        }
        else
        {
            //extend the search region (double size or full window)
            searchRegion = tracker->getTrackingROI(searchFactor*2.0f);
            //searchRegion = wholeImage;
            trackingPatches = new PatchesRegularScan(searchRegion, wholeImage, trackingRectSize2, overlap);
        }
        curFrameRep->setNewImageAndROI(curFrame, searchRegion);
        
        if (!tracker->track(curFrameRep, trackingPatches))
        {
            trackerLost = true;
        }
        else {
            trackerLost = false;
        }
        
        delete trackingPatches;
    
        //display results
        if (!trackerLost)
//            imageSequence->paintRectangle (tracker->getTrackedPatch(), Color2(255,255,0), 2);
    
        //write images and results (debug)
        
    
    
        if (!trackerLost)
            //printf("TRACKING: confidence: %5.3f  fps: %5.2f   \r", tracker->getConfidence(), framesPerSecond);
            printf("TRACKING: confidence: %5.3f (prior: %6.3f)   \n", tracker->getConfidence(), tracker->getPriorConfidence());
        else
            printf("TRACKER LOST, waiting...                                \n");
    Rect2 trackedPatch = tracker->getTrackedPatch();
    return trackedPatch.getCvRect();
}

void SemiBoostingApplication::release()
{
    delete tracker;
    delete imageSequenceSource;
    delete imageSequence;
    if (curFrame == NULL)
        delete[] curFrame;
    delete curFrameRep;
}


//int main2(int argc, char* argv[])
//{
//	srand( (unsigned)time( NULL ) );
//
//	printf ("-------------------------------------------------------\n");
//	printf ("            Semi-Supervised Boosting Tracker           \n");
//	printf ("-------------------------------------------------------\n\n");
//
//	ImageSource::InputDevice input;
//	input=ImageSource::USB;
//
//	int numBaseClassifier;
//	char* source;
//	char* resultDir;
//	float overlap, searchFactor;
//    cv::Rect initBB;
//
//	resultDir=new char[100];
//	memset( resultDir, '\0', 100 );
//	source=new char[100];
//	memset( source, '\0', 100 );
//	initBB=cv::Rect(0,0,0,0);
//
//	//read parameters from config file
//	int ret;
//	if (argc >= 2)
//		ret = readConfigFile(argv[1], input, numBaseClassifier, overlap, searchFactor, resultDir, source, initBB);
//	else
//		ret = readConfigFile("./config.txt", input, numBaseClassifier, overlap, searchFactor, resultDir, source, initBB);
//
//	if (ret < 0)
//	{
//		printf ("ERROR: config file damaged\n");
//		return -1;
//	}
//
//	//start tracking
//	track(input, numBaseClassifier, overlap, searchFactor, resultDir, initBB, source);
//
//	return 0;
//}
