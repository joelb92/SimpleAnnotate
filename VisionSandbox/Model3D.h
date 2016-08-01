/*
 * Model3D.h
 *
 *  Created on: Feb 29, 2016
 *      Author: joel
 */

#ifndef SRC_MODEL3D_H_
#define SRC_MODEL3D_H_

#include <opencv2/opencv.hpp>
#include <stdio.h>
#include <iostream>
#include <fstream>




class Model3D {
public:
	cv::Mat refU,outA,render_dims,threedee;
	std::vector<cv::Point> ref_XY;
	int sizeUwidth;
	int sizeUheight;
	Model3D(std::string modelFolder);
	bool isloaded;
private:
	bool load3dModel(std::string filepath);
};
#endif /* SRC_MODEL3D_H_ */
