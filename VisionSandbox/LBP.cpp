#include "camshift.h"
/*
   Compute Local Binary Pattern for 8 bit image
   Pass in gray scale or value part of an HSV image
   (C) TJ Wilkason 2010
*/
#define ROR(val,n) (val >> n) | (val << (8-n))
static unsigned char initLookup=0;
static unsigned char lbp3key[256];
static unsigned char lbp9key[256];
static unsigned char lbp36val[256];
static unsigned char lbp36key[256];
static unsigned char lbp256key[256];
unsigned char *map;

/*
From Gray Scale and Rotation Invariant Texture Classi?cation
with Local Binary Patterns
Timo Ojala, Matti Pietikäinen and Topi Mäenpää
Machine Vision and Media Processing Unit
Infotech Oulu, University of Oulu
P.O.Box 4500, FIN - 90014 University of Oulu, Finland
{skidi, mkp, topiolli}@ee.oulu.fi
http://www.ee.oulu.fi/research/imag/texture
*/
/*
   Create a lbp36val table that translates an LBP value
   into a rotational invariant value, that is one that
   is independent of rotation.
   To do so, each LBP value is rotated such that it rotating
   corresponds to rotating the neighbor set clockwise
   until a maximal number of the most significant bits, starting from 
   position 7 are 0;
*/
void initLBP(int size)
{
   if ( initLookup==0 )
   {
      // Initialize lookup table for LBP8-3
      int unique=0;
      for ( int lbpval=0;lbpval < 256; lbpval++ )
      {
         unsigned char trans=0;
         unsigned char ones=0;
         unsigned char last = lbpval>>7;   // MSB
         unsigned char max=0;
         unsigned int useRot=0;
         for ( int rot = 0; rot < 8; rot++ )
         {
            // start with LSB, for lbp3
            unsigned char b=(lbpval>>rot)&0x1;
            if ( b != last )
               trans++;
            ones+=b;
            last=b;
            // lbp36
            unsigned char rval = ROR(lbpval,rot);
            if ( rval > max )
            {
               max = rval;
            }
         }
         lbp36val[lbpval] = max;
         lbp36key[max]++;
         // Reduce to the lbp3 values (LBPriu2)
        // If transitions < 2 then check for structure
         if ( trans <= 2 )
         {
            // Good continuous block of 1's or 0's
            switch (ones)
            {
               case 4:
               case 5:
               case 6:
               case 3:
               case 2:
                  lbp3key[lbpval]=2; // next Most structure
                  break;
               default:
                  lbp3key[lbpval]=1; // Some structure (1/7)
            }
         }
         // Otherwise assume no structure
         else
         {
            lbp3key[lbpval]=0; // little to no structure
         }

      }
      // build the lbp36 value to key mapping
      // map the value into the 1-36 key index
      // Only the 36 unique values will be > 0
      int key=0;
      for ( int lbpval=0;lbpval < 256; lbpval++ )
      {
         if ( lbp36key[lbpval] > 0 )
         {
            lbp36key[lbpval]=key++;
            unique++;
         }
         lbp256key[lbpval]=lbpval;
      }
      // Replace the max value with the corresponding key
      for ( int lbpval=0;lbpval < 256; lbpval++ )
      {
         lbp36val[lbpval] = lbp36key[lbp36val[lbpval]];
      }
      // map the value into the 9 key index
      // ignores values with more than 2 transitions
      for ( int lbpval=0;lbpval < 256; lbpval++ )
      {
         // add check to count transitions
         // One of 36 values, keep the ones that 
         switch ( lbp36val[lbpval] )
         {
            case 255: //0b11111111
               lbp9key[lbpval]=9;
               break;
            case 254: //0b11111110
               lbp9key[lbpval]=1;
               break;
            case 252: //0b11111100 *
               lbp9key[lbpval]=2;
               break;
            case 248: //0b11111000 *
               lbp9key[lbpval]=3;
               break;
            case 240: //0b11110000 *
               lbp9key[lbpval]=4;
               break;
            case 224: //0b11100000 *
               lbp9key[lbpval]=5;
               break;
            case 192: //0b11000000 *
               lbp9key[lbpval]=6;
               break;
            case 128: //0b10000000
               lbp9key[lbpval]=7;
               break;
            case 0:   //0b00000000
               lbp9key[lbpval]=8;
               break;
            default:  // All Else
               lbp9key[lbpval]=0;
               break;
         }
      }
      initLookup=1;
      // Determine which table to use
      if (size == 3)
         map=lbp3key;
      else if (size == 36)
         map = lbp36val;
      else if (size == 10)
         map = lbp9key;
      else
         map = lbp256key;
   }
}


void LBP8(IplImage *input, IplImage *output, int size, int os)
{
   //int os=4;                               // offset in pixel values for comparison
   unsigned char *src = (unsigned char*)(input->imageData);
   unsigned char *dest = (unsigned char*)(output->imageData);
   initLBP(size);
   int offset[8];
   // Only single channel images
   if ( input->nChannels > 1 || output->nChannels > 1 )
      return;
   int ws = input->widthStep;
   // Offset to surronding pixels
   offset[0]=+1 - 0;                             //msb
   offset[1]=+1 - ws;
   offset[2]= 0 - ws;
   offset[3]=-1 - ws;
   offset[4]=-1 - 0;
   offset[5]=-1 + ws;
   offset[6]= 0 + ws;
   offset[7]=+1 + ws;

   for ( int row=1; row < input->height-1; row++ )
   {
      for ( int col=1; col< input->width-1; col++ )
      {
         /* 
         Loop over each bit in the byte and shift in a one if the
         outside value > center value, build up the LBP for it
         Use a lookup table to reduce the LBP to 1-3 value.
         | 3 | 2 | 1 |
         | 4 | C | 0 |
         | 5 | 6 | 7 |
         Pn < C -> 1 at n position
         */
         int ci = ws*row+col;                    // center index
         unsigned char c=src[ci];                // pointer to center
         unsigned char d=0;
         unsigned char r=src[ci + offset[7]];    // pointer to last adjacent
         for ( int bit = 0; bit < 8; bit++ )
         {
            r=src[ci + offset[bit]];             // pointer to adjacent
            unsigned char b=(r >= c+os ? 1 : 0);
            d|=(b<<bit);                         //build LBP
         }
         dest[ci] = map[d];                  //map LBP to 1/2/3 value
         if (dest[ci] == 0)
            ci=1;
      }
   }
}
