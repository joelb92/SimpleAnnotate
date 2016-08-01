/*
 * Model3D.cpp
 *
 *  Created on: Feb 29, 2016
 *      Author: joel
 */
#include "Model3D.h"
using namespace std;
Model3D::Model3D(std::string modelFolder){
	isloaded = Model3D::load3dModel(modelFolder);

}

bool exists_test(const std::string& name) {
    ifstream f(name.c_str());
    if (f.good()) {
        f.close();
        return true;
    } else {
        f.close();
        return false;
    }
}
cv::Mat readCSVAsFloatMatrix(std::string filepath)
{
	std::ifstream inputfle(filepath);
	string current_line;
	// vector allows you to add data without knowing the exact size beforehand
	vector< vector<float> > all_data;
	// Start reading lines as long as there are lines in the file
	while(getline(inputfle, current_line)){
	   // Now inside each line we need to seperate the cols
	   vector<float> values;
	   stringstream temp(current_line);
	   string single_value;
	   while(getline(temp,single_value,',')){
	        // convert the string element to a integer value
	        values.push_back(atof(single_value.c_str()));
	   }
	   // add the row to the complete data vector
	   all_data.push_back(values);
	}

	// Now add all the data into a Mat element
	cv::Mat vect = cv::Mat::zeros((int)all_data.size(), (int)all_data[0].size(), CV_32FC1);
	// Loop over vectors and add the data
	for(int rows = 0; rows < (int)all_data.size(); rows++){
	   for(int cols= 0; cols< (int)all_data[0].size(); cols++){
	      vect.at<float>(rows,cols) = all_data[rows][cols];
	   }
	}
	return vect;
}

bool Model3D::load3dModel(std::string filepath)
{
	std::string refu1Name = filepath+"/refU/refUdim1.csv";
	std::string refu2Name = filepath+"/refU/refUdim2.csv";
	std::string refu3Name = filepath+"/refU/refUdim3.csv";
	std::string outAName = filepath+"/outA.csv";
	std::string ref_XYName = filepath+"/ref_XY.csv";
	std::string render_dimsName = filepath+"/render_dims.csv";
	std::string threedeeName = filepath+"/threedee.csv";
	if(exists_test(refu1Name) && exists_test(refu2Name) && exists_test(refu3Name) && exists_test(outAName) && exists_test(ref_XYName) && exists_test(render_dimsName) && exists_test(threedeeName))
	{
		cv::Mat refuc1 = readCSVAsFloatMatrix(refu1Name);
		cv::Mat refuc2 = readCSVAsFloatMatrix(refu2Name);
		cv::Mat refuc3 = readCSVAsFloatMatrix(refu3Name);
		std::vector<cv::Mat> refuChans;
		refuChans.push_back(refuc1);
		refuChans.push_back(refuc2);
		refuChans.push_back(refuc3);

		cv::merge(refuChans,refU);

		outA = readCSVAsFloatMatrix(outAName);
		cv::Mat ref_XY_temp = readCSVAsFloatMatrix(ref_XYName);
		for(int i = 0; i < ref_XY_temp.rows; i++)
		{
			ref_XY.push_back(cv::Point(ref_XY_temp.at<float>(i,0),ref_XY_temp.at<float>(i,1)));
		}
		render_dims = readCSVAsFloatMatrix(render_dimsName);
		threedee = readCSVAsFloatMatrix(threedeeName);
		sizeUwidth = refU.cols;
		sizeUheight = refU.rows;
		return true;
	}
	else
	{
		std::cout << "Error, missing model files!" << std::endl;
		return false;
	}
}

