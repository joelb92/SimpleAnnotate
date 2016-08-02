/*
 * Landmarker_zhuramanan.h
 *
 *  Created on: Feb 22, 2016
 *      Author: joel
 */

#ifndef LANDMARKER_ZHURAMANAN_H_
#define LANDMARKER_ZHURAMANAN_H_

#include "Landmarker.h"
#include <opencv2/opencv.hpp>
#include "dpm-face-master/eHimage.h"
#include "dpm-face-master/eHfacemodel.h"
#include "dpm-face-master/eHposemodel.h"
#include "dpm-face-master/eHbbox.h"

using namespace cv;
using namespace std;

class Landmarker_zhuramanan: public Landmarker {
private:
	facemodel_t* facemodel;// = facemodel_readFromFile(facemodelPath);
	posemodel_t* posemodel;// = posemodel_readFromFile(posemodelPath);

public:
	Landmarker_zhuramanan();
    std::vector<std::vector<cv::Point> > findLandmarks(cv::Mat);
    std::vector<std::vector<cv::Point> > findLandmarks(cv::Mat im,std::vector<bbox_t> &boxes);
};

#endif /* LANDMARKER_ZHURAMANAN_H_ */

