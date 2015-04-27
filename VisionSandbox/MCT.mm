//
//  MCT.m
//  EBOLO
//
//  Created by Joel Brogan on 2/10/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "MCT.h"

@implementation MCT
using namespace std;
using namespace cv;

-(cv::Mat) CensusTransform:(cv::Mat)imgIn
{
    cv::Size imgSize = imgIn.size();
    Mat imgTemp = Mat::zeros(imgSize, CV_8U);
    
    unsigned int census = 0;
    unsigned int bit = 0;
    int m = 3;
    int n = 3;//window size
    int i,j,x,y;
    int shiftCount = 0;
    for (x = m/2; x < imgSize.height - m/2; x++)
    {
        for(y = n/2; y < imgSize.width - n/2; y++)
        {
            census = 0;
            shiftCount = 0;
            for (i = x - m/2; i <= x + m/2; i++)
            {
                for (j = y - n/2; j <= y + n/2; j++)
                {
                    
                    if( shiftCount != m*n/2 )//skip the center pixel
                    {
                        census <<= 1;
                        if( imgIn.at<uchar>(i,j) < imgIn.at<uchar>(x,y) )//compare pixel values in the neighborhood
                            bit = 1;
                        else
                            bit = 0;
                        census = census + bit;
                        //cout<<census<<" ";*/
                        
                    }
                    shiftCount ++;
                }
            }
            //cout<<endl;
            
            imgTemp.ptr<uchar>(x)[y] = census;
        }
    }
    return imgTemp;
}

-(cv::Mat) ModifiedCensusTransform:(cv::Mat)imgIn
{
    cv::Size imgSize = imgIn.size();
    Mat imgTemp = Mat::zeros(imgSize, CV_8U);
    
    unsigned int census = 0;
    unsigned int bit = 0;
    int m = 3;
    int n = 3;//window size
    int i,j,x,y;
    int shiftCount = 0;
    //outer loop (per pixel)
    for (x = m/2; x < imgSize.height - m/2; x++)
    {
        for(y = n/2; y < imgSize.width - n/2; y++)
        {
            census = 0;
            shiftCount = 0;
            //inner loop (neighborhood/block loop)
            float blockAvg = 0;
            for (i = x - m/2; i <= x + m/2; i++)
            {
                for (j = y - n/2; j <= y + n/2; j++)
                {
                    blockAvg+=imgIn.at<uchar>(i,j);
                }
            }
            blockAvg /= m*n;
            
            for (i = x - m/2; i <= x + m/2; i++)
            {
                for (j = y - n/2; j <= y + n/2; j++)
                {
                        census <<= 1;
                        if( imgIn.at<uchar>(i,j) < blockAvg )//compare pixel values in the neighborhood to the average
                            bit = 1;
                        else
                            bit = 0;
                        census = census + bit;
                    shiftCount ++;
                }
            }
            //cout<<endl;
            
            imgTemp.ptr<uchar>(x)[y] = census;
        }
    }
    return imgTemp;
}

//can only take color images
-(cv::Mat) ModifiedColorCensusTransform:(cv::Mat)img
{
    cv::Mat imgIn;
    cv::copyMakeBorder(img, imgIn, 1, 1, 1, 1, cv::BORDER_REFLECT);
    if (imgIn.channels() == 1) {
        NSLog(@"WARNING: 1 channel image. switching to grascale MCT");
        return [self ModifiedCensusTransform:imgIn];
    }
    else if (imgIn.channels() != 3){
        NSLog(@"WARNING: wrong number of channels. MCT not calculated.");
        return cv::Mat();
    }
    cv::Mat color = imgIn;
    cv::cvtColor(color, imgIn, CV_BGR2GRAY);
    cv::Size imgSize = imgIn.size();
    Mat imgTemp = Mat::zeros(imgSize, CV_16UC1);
    
    unsigned int census = 0;
    unsigned int bit = 0;
    int m = 3;
    int n = 3;//window size
    int i,j,x,y;
    int shiftCount = 0;
    //outer loop (per pixel)
    for (x = m/2; x < imgSize.height - m/2; x++)
    {
        for(y = n/2; y < imgSize.width - n/2; y++)
        {
            census = 0;
            shiftCount = 0;
            //inner loop (neighborhood/block loop)
            float blockAvg = 0;
            float redAvg = 0;
            float greenAvg = 0;
            float blueAvg = 0;
            for (i = x - m/2; i <= x + m/2; i++)
            {
                for (j = y - n/2; j <= y + n/2; j++)
                {
                    blockAvg+=imgIn.at<uchar>(i,j);
                    cv::Vec3b colors = color.at<cv::Vec3b>(i,j);
                    redAvg+=colors[0];
                    greenAvg+=colors[1];
                    blueAvg+=colors[2];
                }
            }
            blockAvg /= m*n;
            redAvg/=m*n;
            greenAvg/=m*n;
            blueAvg/=m*n;
            for (i = x - m/2; i <= x + m/2; i++)
            {
                for (j = y - n/2; j <= y + n/2; j++)
                {
                    census <<= 1;
                    if( imgIn.at<uchar>(i,j) < blockAvg )//compare pixel values in the neighborhood to the average
                        bit = 1;
                    else
                        bit = 0;
                    census = census + bit;
                    shiftCount ++;
                }
            }
            
            //extra 3 bits to account for color
            cv::Vec3b colors = color.at<cv::Vec3b>(x,y);
            float u = (colors[0]+colors[1]+colors[2])/3;
            int br = redAvg < u;
            int bg = greenAvg < u;
            int bb = blueAvg < u;
			census <<= 1;
            census = census+br;
			census <<= 1;
			census = census+bg;
			census <<= 1;
			census = census+bb;
            //cout<<endl;
            if(census > 4095) NSLog(@"bad!");
            imgTemp.at<unsigned short>(x,y) = census;
                   }
    }
    cv::Mat returnMat = imgTemp(cv::Rect(1,1,imgTemp.cols-2,imgTemp.rows-2)).clone();
    return returnMat;
}

@end
