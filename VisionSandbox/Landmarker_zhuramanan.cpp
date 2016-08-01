/*
 * Landmarker_zhuramanan.cpp
 *
 *  Created on: Feb 22, 2016
 *      Author: joel
 */
#include "Landmarker_zhuramanan.h"

Landmarker_zhuramanan::Landmarker_zhuramanan()
{
	std::string facemodelpath = "src/external_libs/dpm-face-master/face_p146.xml";
	std::string posemodelpath  = "src/external_libs/dpm-face-master/pose_BUFFY.xml";

	facemodel = facemodel_readFromFile(facemodelpath.c_str());
	posemodel = posemodel_readFromFile(posemodelpath.c_str());

}

std::vector<cv::Point> Landmarker_zhuramanan::findLandmarks(cv::Mat im)
{
	std::vector<cv::Point> landmarks;
    image_t* img = image_CVtoZR(im);

    if(im.empty()) {
    	std::cout << "face image is empty!";
        return landmarks;
    }
    //detect faces and show results
    std::vector<bbox_t> faces;

    faces = facemodel_detect(facemodel,posemodel,img);
    if(faces.size() > 0)
    {
    	bbox_t face = faces[0];
		for(int i=0; i < face.boxes.size(); i++)
		{
			int x = face.boxes[i].x1;
			int y = face.boxes[i].y1;
			int w = face.boxes[i].x2-x;
			int h = face.boxes[i].y2-y;
			cv::Point p(x+.5*w,y+.5*h);
			landmarks.push_back(p);
		}
    }
//    if(shouldDisplay)
//    {
//    	int s = 400.0/im.cols;
//		cv::Mat test; cv::resize(im,test,cv::Size(im.cols*s,im.rows*s));
//    	for(int i = 0; i < landmarks.size(); i++)
//    	{
//    		cv::Scalar color(0,255,0);
//    		cv::circle(test,cv::Point2f(landmarks[i].x,landmarks[i].y)*s,4,color,-1);
//    //		cv::putText(test, std::to_string(i),landmarks[i]*s, FONT_HERSHEY_PLAIN, 1, CV_RGB(0,255,0), 2.0);
//    	}
//    	cv::imshow("landmarks",test);
//    //destruct image and models
////    image_delete(img);
//    }

    return landmarks;
}



