//
//  DisplayListArr.h
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 2/5/13.
//
//

#import <Foundation/Foundation.h>

typedef struct
{
	bool created = false;
	bool Constructed = false;
	GLuint list;
	void release()
	{
		if(created)
		{
			glDeleteLists(list, 1);
			created = false;
			Constructed = false;
		}
	}
	void BeginCreatingList()
	{
		if(created) release();
		created = true;
		list = glGenLists(1);
		glNewList(list, GL_COMPILE);
	}
	void EndCreatingList()
	{
		if(UnderConstruction())
		{
			Constructed = true;
			glEndList();
		}
	}
	bool CanDraw()
	{
		return Constructed;
	}
	bool UnderConstruction()
	{
		return created && !Constructed;
	}
	void DrawList()
	{
		if(Constructed)
		{
			glCallList(list);
		}
	}
}DisplayList;

@interface DisplayListArr : NSObject
{
    DisplayList**arr;
	int Length;
	int elements;
	int VisableLength;
}
- (id)init;
- (id)initWithCapacity:(int)length;
- (id)initWithLength:(int)length;
- (void)addCapacity:(int)capacityIncrease;
- (void)addElement:(DisplayList*)element;
- (void)removeLastElement;
- (void)Reset;
- (int)Length;
- (int)numberOfElements;
- (DisplayList*)elementAtIndex:(int)index;
- (void)replaceElementAtIndex:(int)index With:(DisplayList*)element;
@end
