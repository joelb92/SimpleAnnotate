//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "SpaceConverter.h"

//Constructors:
SpaceConverter::SpaceConverter()
{
	FlasherValue = 0;
	ImageRect = vector2Rect(Vector2(NAN,NAN),Vector2(NAN,NAN));
}

//Functions:
//Camera To ___ Convershions:
Vector2 SpaceConverter::CameraToImageVector(Vector2 point)
{
	point.x = (point.x/ImageRect.AspectRatio()+1)/2*ImageRect.size.x + ImageRect.origin.x;
	point.y = (-point.y+1)/2*ImageRect.size.y + ImageRect.origin.y;
	
	return point;
}
Vector2 SpaceConverter::CameraToPercentVector(Vector2 point)
{
	point.x = (point.x/ImageRect.AspectRatio()+1)/2;
	point.y = (-point.y+1)/2;
	
	return point;
}
Vector2 SpaceConverter::CameraToScreenVector(Vector2 point)
{	
	point.x = (point.x/screenAspectRatio*frustrumScale+1)*screenSize.width/2;
	point.y = (point.y*frustrumScale+1)*screenSize.height/2;
	
	return point;
}

//Image To ___ Convershions:
Vector2 SpaceConverter::ImageToCameraVector(Vector2 point)
{
	point.x = ((point.x+ImageRect.origin.x)/ImageRect.size.x*2-1)*ImageRect.AspectRatio();
	point.y = -((point.y+ImageRect.origin.y)/ImageRect.size.y*2-1);
	
	return point;
}
Vector2 SpaceConverter::ImageToPercentVector(Vector2 point)
{
	return (point+ImageRect.origin).DevideComponentsByComponentsOf(ImageRect.size);
}
Vector2 SpaceConverter::ImageToScreenVector(Vector2 point)
{
	point.x = ((((point.x - ImageRect.origin.x)*2/ImageRect.size.x-1)*ImageRect.AspectRatio()+imagePos.x)*frustrumScale/screenAspectRatio+1)*screenSize.width/2;
	point.y = ((-((point.y-ImageRect.origin.y)*2/ImageRect.size.y-1)+imagePos.y)*frustrumScale+1)*screenSize.height/2;
	
	return point;
}

//Percent To ___ Convershions:
Vector2 SpaceConverter::PercentToCameraVector(Vector2 point)
{
	point.x = (point.x*2-1)*ImageRect.AspectRatio();
	point.y = -(point.y*2-1);
	
	return point;
}
Vector2 SpaceConverter::PercentToImageVector(Vector2 point)
{
	return point.MultiplyComponentsByComponentsOf(ImageRect.size) + ImageRect.origin;
}
Vector2 SpaceConverter::PercentToScreenVector(Vector2 point)
{
	point.x = ((point.x*2-1)*ImageRect.AspectRatio()/screenAspectRatio*frustrumScale+1)*screenSize.width/2;
	point.y = (-(point.y*2-1)*frustrumScale+1)*screenSize.height/2;
	
	return point;
}

//Screen To ___ Convershions:
Vector2 SpaceConverter::ScreenToCameraVector(Vector2 point)
{
	point.x = (point.x*2/screenSize.width-1)*screenAspectRatio/frustrumScale;
	point.y = (point.y*2/screenSize.height-1)/frustrumScale;
	
	return point;
}
Vector2 SpaceConverter::ScreenToImageVector(Vector2 point)
{
	point.x = (((point.x*2/screenSize.width-1)*screenAspectRatio/frustrumScale-imagePos.x)/ImageRect.AspectRatio()+1)/2*ImageRect.size.x + ImageRect.origin.x;
	point.y = (-((point.y*2/screenSize.height-1)/frustrumScale-imagePos.y)+1)/2*ImageRect.size.y + ImageRect.origin.y;
	
	return point;
}
Vector2 SpaceConverter::ScreenToPercentVector(Vector2 point)
{
	point.x = ((point.x*2/screenSize.width-1)*screenAspectRatio/frustrumScale/ImageRect.AspectRatio()+1)/2;
	point.y = (-(point.y*2/screenSize.height-1)/frustrumScale+1)/2;
	
	return point;
}

void SpaceConverter::GetMatrixes()
{
	glGetIntegerv(GL_VIEWPORT, viewport);
	glGetDoublev(GL_MODELVIEW_MATRIX, modelview);
	glGetDoublev(GL_PROJECTION_MATRIX, projection);
}

Ray3 SpaceConverter::RayFromScreenPoint(Vector2 screenPoint)
{
	switch(type)
	{
		case _2d:
		{
			Vector2 imagePoint = ScreenToImageVector(screenPoint);
			return Ray3(Vector3(imagePoint,0), Vector3(0,0,-1));
		} break;
			
		case _3d:
		{
			GLdouble x, y, z;
			
			gluUnProject(screenPoint.x, screenPoint.y, 0, modelview, projection, viewport, &x, &y, &z);
			Vector3 origin = Vector3(x,y,z);
			
			gluUnProject(screenPoint.x, screenPoint.y, 1, modelview, projection, viewport, &x, &y, &z);
			Vector3 termination = Vector3(x,y,z);
			
			return Ray3(origin, (termination-origin).Normalized());
		} break;
	}
}