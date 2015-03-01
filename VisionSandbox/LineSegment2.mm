//  SimpleAnnotate
//
//  Created by Joel Brogan on 22/8/15.
//  Copyright (c) 2015 Joel Brogan. All rights reserved.
//

#import "LineSegment2.h"

//Constructors
LineSegment2::LineSegment2()
{
	origin = Vector2();
	termintation = Vector2();
}
LineSegment2::LineSegment2(Line2 line)
{
	origin = line.point1;
	termintation = line.point2;
}
LineSegment2::LineSegment2(Ray2 ray)
{
	origin = ray.origin;
	termintation = origin + ray.direction;
}
LineSegment2::LineSegment2(Ray2 ray, double length)
{
	origin = ray.origin;
	termintation = origin + ray.direction*length;
}
LineSegment2::LineSegment2(Vector2 ORIGIN, Vector2 TERMINATION)
{
	origin = ORIGIN;
	termintation = TERMINATION;
}
LineSegment2::LineSegment2(Vector2 ORIGIN, double radAngle, double length)
{
	origin = ORIGIN;
	termintation = Vector2(length*cos(radAngle)+origin.x, length*sin(radAngle)+origin.y);
}

//Functions
bool LineSegment2::isNull()
{
	return origin.isNull() || termintation.isNull();
}
double LineSegment2::AngleToTermination()
{
	return atan2(termintation.y-origin.y, termintation.x-origin.x);
}
Vector2 LineSegment2::DirectionUnNormalized()
{
	return termintation-origin;
}
Vector2 LineSegment2::DirectionNormalized()
{
	return (termintation-origin).Normalized();
}
/*BRESENHAAM ALGORITHM FOR LINE DRAWING*/
//http://www.etechplanet.com/codesnippets/computer-graphics-draw-a-line-using-bresenham-algorithm.aspx
Vector2Arr LineSegment2::RasterizedPoints()
{
	if(!isNull())
	{
		Vector2 delta = termintation-origin;
		
		Vector2Arr points = Vector2Arr(delta.Magnitude());
		int x,y,dx1,dy1,px,py,xe,ye,i;
		dx1=fabs((int)delta.x);
		dy1=fabs((int)delta.y);
		px=2*dy1-dx1;
		py=2*dx1-dy1;
		if(dy1<=dx1)
		{
			if((int)delta.x>=0)
			{
				x=origin.x;
				y=origin.y;
				xe=termintation.x;
			}
			else
			{
				x=termintation.x;
				y=termintation.y;
				xe=origin.x;
			}
			points.AddItemToEnd(Vector2(x,y));
			for(i=0;x<xe;i++)
			{
				x=x+1;
				if(px<0)
				{
					px=px+2*dy1;
				}
				else
				{
					if((delta.x<0 && delta.y<0) || (delta.x>0 && delta.y>0))
					{
						y=y+1;
					}
					else
					{
						y=y-1;
					}
					px=px+2*(dy1-dx1);
				}
				points.AddItemToEnd(Vector2(x,y));
			}
		}
		else
		{
			if(delta.y>=0)
			{
				x=origin.x;
				y=origin.y;
				ye=termintation.y;
			}
			else
			{
				x=termintation.x;
				y=termintation.y;
				ye=origin.y;
			}
			points.AddItemToEnd(Vector2(x,y));
			for(i=0;y<ye;i++)
			{
				y=y+1;
				if(py<=0)
				{
					py=py+2*dx1;
				}
				else
				{
					if((delta.x<0 && delta.y<0) || (delta.x>0 && delta.y>0))
					{
						x=x+1;
					}
					else
					{
						x=x-1;
					}
					py=py+2*(dx1-dy1);
				}
				points.AddItemToEnd(Vector2(x,y));
			}
		}
		return points;
	}
	return Vector2Arr();
}

LineSegment2 LineSegment2::Perpendicular()
{
	return LineSegment2(origin,(termintation-origin).Perpendicular() + origin);
}
Vector2 LineSegment2::ProjectionOfPoint(Vector2 point)
{
	Vector2 u = termintation - origin;
	Vector2 pq = point - origin;
	Vector2 w2 = pq - u*pq.Dot(u)/u.SqMagnitude();
	
	return point - w2;
}
bool LineSegment2::IntersectionWith(Vector2* intersection, LineSegment2 seg)
{
	//stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
	Vector2 r = termintation-origin;
	Vector2 s = seg.DirectionUnNormalized();
	if(r.Cross(s)!=0)
	{
		double t = (seg.origin-origin).Cross(s/r.Cross(s));
		double u = (seg.origin-origin).Cross(r/r.Cross(s));
		
		*intersection = origin + r*t;
		if(t>=0 && t<=1 && u>=0 && u<=1)
		{
			return true;
		}
		return false;
	}
	*intersection = Vector2(NAN,NAN);
	return false;
}
bool LineSegment2::IntersectionWith(Vector2* intersection, Line2 line)
{
	//stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
	Vector2 r = termintation-origin;
	Vector2 s = line.DirectionNormalized();
	if(r.Cross(s)!=0)
	{
		double t = (line.point1-origin).Cross(s/r.Cross(s));
		double u = (line.point1-origin).Cross(r/r.Cross(s));
		
		*intersection = origin + r*t;
		if(t>=0 && t<=1)
		{
			return true;
		}
		return false;
	}
	*intersection = Vector2(NAN,NAN);
	return false;
}
bool LineSegment2::IntersectionWith(Vector2* intersection, Ray2 ray)
{
	//stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
	Vector2 r = termintation-origin;
	Vector2 s = ray.direction;
	if(r.Cross(s)!=0)
	{
		double t = (ray.origin-origin).Cross(s/r.Cross(s));
		double u = (ray.origin-origin).Cross(r/r.Cross(s));
		
		*intersection = origin + r*t;
		if(t>=0 && t<=1 && u>=0)
		{
			return true;
		}
		return false;
	}
	*intersection = Vector2(NAN,NAN);
	return false;
}
bool LineSegment2::ContainsProjectionOfPoint(Vector2 point)
{
	return ((point-origin).Normalized()).Dot((termintation-origin).Normalized())>=0 && ((point-termintation).Normalized()).Dot((origin-termintation).Normalized())>=0;
}

//Operators
LineSegment2 LineSegment2::operator+ (Vector2 vect)
{
	return LineSegment2(origin+vect,termintation+vect);
}
void LineSegment2::operator+= (Vector2 vect)
{
	origin += vect;
	termintation += vect;
}
LineSegment2 LineSegment2::operator- (Vector2 vect)
{
	return LineSegment2(origin-vect,termintation-vect);
}
LineSegment2 LineSegment2::operator-()
{
	return LineSegment2(termintation,origin);
}
void LineSegment2::operator-= (Vector2 vect)
{
	origin -= vect;
	termintation -= vect;
}
LineSegment2 LineSegment2::operator* (float parm)
{
	Vector2 vectParm = (termintation-origin)*(parm/2);
	return LineSegment2(origin-vectParm,termintation+vectParm);
}
bool LineSegment2::operator== (LineSegment2 seg)
{
	return origin==seg.origin && termintation==seg.termintation;
}
bool LineSegment2::operator!= (LineSegment2 seg)
{
	return origin!=seg.origin || termintation!=seg.termintation;
}