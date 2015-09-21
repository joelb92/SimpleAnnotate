#include "camshift.h"
/*
   Compute Local Contrast Pattern (VAR) for 8 bit image
   Pass in gray scale or value part of an HSV image
   (C) TJ Wilkason 2010
*/

/*
   From Texture Analysis with Local Binary Patterns
   Department of Electrical and Information Engineering,
   Infotech Oulu, University of Oulu
   P.O. Box 4500, 90014 University of Oulu, Finland

   Create a local contrast measure called VAR
*/

void VAR8(IplImage *input, IplImage *output)
{
   unsigned char *src = (unsigned char*)(input->imageData);
   unsigned char *dest = (unsigned char*)(output->imageData);
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
         int ci = ws*row+col;                    // center index
         unsigned char s=src[ci];                // pointer to center
         unsigned char d=0;                      // holder for shifted bits
         /* 
         Loop over each bit in the byte and shift in a one if the
         outside value > center value
         | 3 | 2 | 1 |
         | 4 | C | 0 |
         | 5 | 6 | 7 |
         Pn < C -> 1 at n position
         */
         unsigned int r=0;// init bit
         for ( int bit = 0; bit < 8; bit++ )
         {
            r+=src[ci + offset[bit]];   
         }
         int mu=r/8;
         r=0;
         for ( int bit = 0; bit < 8; bit++ )
         {
            int s=(src[ci + offset[bit]] - mu);
            s*=s; // square it
            r+=s;   
         }
         dest[ci]=r;
      }
   }
}
