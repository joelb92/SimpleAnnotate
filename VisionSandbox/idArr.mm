//
//  idArr.mm
//  DIF Map Decoder
//
//  Created by Charlie Mehlenbeck on 2/7/13.
//
//

#import "idArr.h"

@implementation idArr
// Make sure this is a .mm file, not a .m file!
const int AddObjectLengthIncrament = 10000;
- (id)init
{
	self = [super init];
	if(self)
	{
		arr = [[NSMutableArray alloc] init];
		Length=0;
		VisibleLength=0;
		lock = [[ReadWriteLock alloc] init];
	}
	return self;
}
- (id)initWithCapacity:(int)length
{
	self = [super init];
	if(self)
	{
		arr = [[NSMutableArray alloc] initWithCapacity:length];
		VisibleLength=arr.count;
		lock = [[ReadWriteLock alloc] init];
	}
	return self;
}
- (id)initWithLength:(int)length
{
	self = [super init];
	if(self)
	{
		arr = [[NSMutableArray alloc] initWithCapacity:length];
		VisibleLength=arr.count;
		lock = [[ReadWriteLock alloc] init];
	}
	return self;
}

- (void)addElement:(id)element
{
	[element retain];
	[lock lockForWriting];
	[arr addObject:element];
	VisibleLength++;
	[element release];
	[lock unlock];
}
- (void)removeLastElement
{
	[lock lockForWriting];
	if(VisibleLength>0)
	{
		VisibleLength--;
		[arr removeLastObject];
	}
	[lock unlock];
}

- (int)Length
{
	[lock lock];
	int vl = VisibleLength;
	[lock unlock];
	return vl;
}

- (int)numberOfElements
{
	[lock lock];
	int elts = VisibleLength;
	[lock unlock];
	return elts;
}
- (id)elementAtIndex:(int)index
{
	[lock lock];
	id element = [[[arr objectAtIndex:index] retain] autorelease];
	[lock unlock];
	return element;
}
- (void)removeElementAtIndex:(int)index
{
	[lock lockForWriting];
	if(index>=0 && index<VisibleLength)
	{
		[arr removeObjectAtIndex:index];
	}
	[lock unlock];
}
- (void)replaceElementAtIndex:(int)index With:(id)element
{
	[element retain];
	[lock lockForWriting];
	[arr replaceObjectAtIndex:index withObject:element];
	[lock unlock];
}
- (void)reset
{
	[lock lockForWriting];
	[arr removeAllObjects];
	VisibleLength = 0;
	[lock unlock];
}
- (void)dealloc
{
	[arr release];
	[lock release];
	[super dealloc];
}
@end