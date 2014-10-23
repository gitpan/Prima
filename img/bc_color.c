/*-
 * Copyright (c) 1997-2002 The Protein Laboratory, University of Copenhagen
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * $Id$
 */
/* Created by Dmitry Karasik <dk@plab.ku.dk> */

#include "img_conv.h"

#ifdef __cplusplus
extern "C" {
#endif

#define EDIFF_OP_RGB \
if ( b > 255) { eb -= ( b - 255); b = 255; } else { eb = 0; } \
if ( g > 255) { eg -= ( g - 255); g = 255; } else { eg = 0; } \
if ( r > 255) { er -= ( r - 255); r = 255; } else { er = 0; }

#define dEDIFF_ARGS \
   int er, eg, eb, nextR, nextG, nextB, *perr = err_buf;\
   register int r, g, b

#define EDIFF_INIT \
   nextR = perr[0], nextG = perr[1], nextB = perr[2];\
   perr[0] = perr[1] = perr[2] = er = eg = eb = 0

#define EDIFF_BEGIN_PIXEL(red,gre,blu) \
      b = (blu) + eb + nextB;\
      g = (gre) + eg + nextG;\
      r = (red) + er + nextR;\
      nextR = perr[3];\
      nextG = perr[4];\
      nextB = perr[5];\
      if ( r > 255) r = 255; else if ( r < 0) r = 0;\
      if ( g > 255) g = 255; else if ( g < 0) g = 0;\
      if ( b > 255) b = 255; else if ( b < 0) b = 0;\
      er = eb = eg = 0

#define EDIFF_END_PIXEL_EX(red_err,gre_err,blu_err) \
      perr[0] += er = (perr[3] = (red_err) / 5) * 2;\
      perr[1] += eg = (perr[4] = (gre_err) / 5) * 2;\
      perr[2] += eb = (perr[5] = (blu_err) / 5) * 2;\
      perr += 3

#define EDIFF_END_PIXEL(red_err,gre_err,blu_err) \
      EDIFF_END_PIXEL_EX(r-(red_err),g-(gre_err),b-(blu_err))

/* Bitstroke convertors */
/* Mono */
/* 1-> 16 */
void
bc_mono_nibble( register Byte * source, register Byte * dest, register int count)
{
   register Byte tailsize = count & 7;
   dest    += (count - 1) >> 1;
   count    = count >> 3;
   source  += count;

   if ( tailsize)
   {
      register Byte tail = (*source) >> ( 8 - tailsize);
      if ( tailsize & 1)
      {
         tailsize++;
         tail <<= 1;
      }
      while( tailsize)
      {
         *dest-- = ( tail & 1) | (( tail & 2) << 3);
         tail >>= 2;
         tailsize -= 2;
      }
   }
   source--;
   while( count--)
   {
      register Byte c = *source--;
      *dest-- = ( c & 1) | (( c & 2) << 3);  c >>= 2;
      *dest-- = ( c & 1) | (( c & 2) << 3);  c >>= 2;
      *dest-- = ( c & 1) | (( c & 2) << 3);  c >>= 2;
      *dest-- = ( c & 1) | (( c & 2) << 3);
   }
}

/* 1-> mapped 16 */
void
bc_mono_nibble_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref)
{
   register Byte tailsize = count & 7;
   dest    += (count - 1) >> 1;
   count    = count >> 3;
   source  += count;

   if ( tailsize)
   {
      register Byte tail = (*source) >> ( 8 - tailsize);
      if ( tailsize & 1)
      {
         tailsize++;
         tail <<= 1;
      }
      while( tailsize)
      {
         *dest-- = colorref[ tail & 1] | ( colorref[( tail & 2) >> 1] << 4);
         tail >>= 2;
         tailsize -= 2;
      }
   }
   source--;
   while( count--)
   {
      register Byte c = *source--;
      *dest-- = colorref[ c & 1] | ( colorref[( c & 2) >> 1] << 4); c >>= 2;
      *dest-- = colorref[ c & 1] | ( colorref[( c & 2) >> 1] << 4); c >>= 2;
      *dest-- = colorref[ c & 1] | ( colorref[( c & 2) >> 1] << 4); c >>= 2;
      *dest-- = colorref[ c & 1] | ( colorref[( c & 2) >> 1] << 4);
   }
}

/*  1 -> 256 */
void
bc_mono_byte( register Byte * source, register Byte * dest, register int count)
{
   register Byte tailsize = count & 7;
   dest    += count - 1;
   count    = count >> 3;
   source  += count;
   if ( tailsize)
   {
      register Byte tail = (*source) >> ( 8 - tailsize);
      while( tailsize--)
      {
         *dest-- = tail & 1;
         tail >>= 1;
      }
   }
   source--;
   while( count--)
   {
      register Byte c = *source--;
      *dest-- = c & 1;      c >>= 1;
      *dest-- = c & 1;      c >>= 1;
      *dest-- = c & 1;      c >>= 1;
      *dest-- = c & 1;      c >>= 1;
      *dest-- = c & 1;      c >>= 1;
      *dest-- = c & 1;      c >>= 1;
      *dest-- = c & 1;
      *dest-- = c >> 1;
   }
}

/*  1 -> mapped 256 */
void
bc_mono_byte_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref)
{
   register Byte tailsize = count & 7;
   dest    += count - 1;
   count    = count >> 3;
   source  += count;
   if ( tailsize)
   {
      register Byte tail = (*source) >> ( 8 - tailsize);
      while( tailsize--)
      {
         *dest-- = colorref[ tail & 1];
         tail >>= 1;
      }
   }
   source--;
   while( count--)
   {
      register Byte c = *source--;
      *dest-- = colorref[ c & 1];      c >>= 1;
      *dest-- = colorref[ c & 1];      c >>= 1;
      *dest-- = colorref[ c & 1];      c >>= 1;
      *dest-- = colorref[ c & 1];      c >>= 1;
      *dest-- = colorref[ c & 1];      c >>= 1;
      *dest-- = colorref[ c & 1];      c >>= 1;
      *dest-- = colorref[ c & 1];
      *dest-- = colorref[ c >> 1];
   }
}


/*  1 -> gray */
void
bc_mono_graybyte( register Byte * source, register Byte * dest, register int count, register PRGBColor palette)
{
   register Byte tailsize = count & 7;
   dest    += count - 1;
   count    = count >> 3;
   source  += count;
   if ( tailsize)
   {
      register Byte tail = (*source) >> ( 8 - tailsize);
      while( tailsize--)
      {
         register RGBColor r = palette[ tail & 1];
         *dest-- = map_RGB_gray[ r.r + r.g + r.b];
         tail >>= 1;
      }
   }
   source--;
   while( count--)
   {
      register Byte c = *source--;
      register RGBColor r;
      r = palette[ c & 1]; *dest-- = map_RGB_gray[ r.r + r.g + r.b]; c >>= 1;
      r = palette[ c & 1]; *dest-- = map_RGB_gray[ r.r + r.g + r.b]; c >>= 1;
      r = palette[ c & 1]; *dest-- = map_RGB_gray[ r.r + r.g + r.b]; c >>= 1;
      r = palette[ c & 1]; *dest-- = map_RGB_gray[ r.r + r.g + r.b]; c >>= 1;
      r = palette[ c & 1]; *dest-- = map_RGB_gray[ r.r + r.g + r.b]; c >>= 1;
      r = palette[ c & 1]; *dest-- = map_RGB_gray[ r.r + r.g + r.b]; c >>= 1;
      r = palette[ c & 1]; *dest-- = map_RGB_gray[ r.r + r.g + r.b]; c >>= 1;
      r = palette[ c];     *dest-- = map_RGB_gray[ r.r + r.g + r.b];
   }
}


/*  1 -> rgb */
void
bc_mono_rgb( register Byte * source, Byte * dest, register int count, register PRGBColor palette)
{
   register Byte tailsize   = count & 7;
   register PRGBColor rdest = ( PRGBColor) dest;
   rdest   += count - 1;
   count    = count >> 3;
   source  += count;
   if ( tailsize)
   {
      register Byte tail = (*source) >> ( 8 - tailsize);
      while( tailsize--)
      {
         *rdest-- = palette[ tail & 1];
         tail >>= 1;
      }
   }
   source--;
   while( count--)
   {
      register Byte c = *source--;
      *rdest-- = palette[ c & 1];      c >>= 1;
      *rdest-- = palette[ c & 1];      c >>= 1;
      *rdest-- = palette[ c & 1];      c >>= 1;
      *rdest-- = palette[ c & 1];      c >>= 1;
      *rdest-- = palette[ c & 1];      c >>= 1;
      *rdest-- = palette[ c & 1];      c >>= 1;
      *rdest-- = palette[ c & 1];
      *rdest-- = palette[ c >> 1];
   }
}


/*  Nibble */
/* 16-> 1 */
void
bc_nibble_mono_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref)
{
   register int count8 = count >> 3;
   while ( count8--)
   {
      register Byte c;
      register Byte d;
      c = *source++;  d  = ( colorref[ c & 0xF] << 6) | ( colorref[ c >> 4] << 7);
      c = *source++;  d |= ( colorref[ c & 0xF] << 4) | ( colorref[ c >> 4] << 5);
      c = *source++;  d |= ( colorref[ c & 0xF] << 2) | ( colorref[ c >> 4] << 3);
      c = *source++;  *dest++ = d | colorref[ c & 0xF] |( colorref[ c >> 4] << 1);
   }
   count &= 7;
   if ( count)
   {
      register Byte d = 0;
      register Byte s = 7;
      count = ( count >> 1) + ( count & 1);
      while ( count--)
      {
         register Byte c = *source++;
         d |= colorref[ c >> 4 ] << s--;
         d |= colorref[ c & 0xF] << s--;
      }
      *dest = d;
   }
}

/* 16-> 1, halftone */
void
bc_nibble_mono_ht( register Byte * source, register Byte * dest, register int count, register PRGBColor palette, int lineSeqNo)
{
#define n64cmp1 (( r = palette[ c >> 4], (( map_RGB_gray[r.r+r.g+r.b] >> 2) > map_halftone8x8_64[ index++]))?1:0)
#define n64cmp2 (( r = palette[ c & 15], (( map_RGB_gray[r.r+r.g+r.b] >> 2) > map_halftone8x8_64[ index++]))?1:0)
   register int count8 = count >> 3;
   lineSeqNo = ( lineSeqNo & 7) << 3;
   while ( count8--)
   {
      register Byte  index = lineSeqNo;
      register Byte  c;
      register Byte  dst;
      register RGBColor r;
      c = *source++; dst   = n64cmp1 << 7; dst |= n64cmp2 << 6;
      c = *source++; dst  |= n64cmp1 << 5; dst |= n64cmp2 << 4;
      c = *source++; dst  |= n64cmp1 << 3; dst |= n64cmp2 << 2;
      c = *source++; dst  |= n64cmp1 << 1; *dest++ = dst | n64cmp2;
   }
   count &= 7;
   if ( count)
   {
      Byte index = lineSeqNo;
      register Byte d = 0;
      register Byte s = 7;
      count = ( count >> 1) + ( count & 1);
      while ( count--)
      {
         register Byte c = *source++;
         register RGBColor r;
         d |= n64cmp1 << s--;
         d |= n64cmp2 << s--;
      }
      *dest = d;
   }
}

/* 16-> 1, error diffusion */
void
bc_nibble_mono_ed( Byte * source, Byte * dest, int count, PRGBColor palette, int * err_buf)
{
   dEDIFF_ARGS;
   int count8 = count >> 3;
   EDIFF_INIT;

   while ( count8--) {
      Byte c, dst = 0, i, shift = 8;
      for ( i = 0; i < 4; i++) {
         c = (*source) >> 4;
         c = map_RGB_gray[ palette[c].r + palette[c].g + palette[c].b];
         EDIFF_BEGIN_PIXEL(c,c,c);
         dst |= (( r + g + b ) > 383) << (--shift);
         EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
         c = *(source++) & 0xf;
         c = map_RGB_gray[ palette[c].r + palette[c].g + palette[c].b];
         EDIFF_BEGIN_PIXEL(c,c,c);
         dst |= (( r + g + b ) > 383) << (--shift);
         EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
      }
      *(dest++) = dst;
   }   
   count &= 7;
   if ( count) {
      Byte c, dst = 0, shift = 8;
      count = ( count >> 1) + ( count & 1);
      while ( count--) {
         c = *source >> 4;
         c = map_RGB_gray[ palette[c].r + palette[c].g + palette[c].b];
         EDIFF_BEGIN_PIXEL(c,c,c);
         dst |= (( r + g + b ) > 383) << (--shift);
         EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
         c = *(source++) & 0xf;
         c = map_RGB_gray[ palette[c].r + palette[c].g + palette[c].b];
         EDIFF_BEGIN_PIXEL(c,c,c);
         dst |= (( r + g + b ) > 383) << (--shift);
         EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
      }
      *(dest++) = dst;
   }
}   

/* map 16 */
void
bc_nibble_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref)
{
   count  =  ( count >> 1) + ( count & 1);
   source += count - 1;
   dest   += count - 1;
   while ( count--)
   {
      register Byte c = *source--;
      *dest-- = colorref[ c & 0xF] | ( colorref[ c >> 4] << 4);
   }
}

/*  16 -> 256 */
void
bc_nibble_byte( register Byte * source, register Byte * dest, register int count)
{
   register Byte tail = count & 1;
   dest   += count - 1;
   count  =  count >> 1;
   source += count;

   if ( tail) *dest-- = (*source) >> 4;
   source--;
   while( count--)
   {
      register Byte c = *source--;
      *dest-- = c & 0xF;
      *dest-- = c >> 4;
   }
}

/*  16 -> gray */
void
bc_nibble_graybyte( register Byte * source, register Byte * dest, register int count, register PRGBColor palette)
{
   register Byte tail = count & 1;
   dest   += count - 1;
   count  =  count >> 1;
   source += count;

   if ( tail)
   {
      register RGBColor r = palette[ (*source) >> 4];
      *dest-- = map_RGB_gray[ r.r + r.g + r.b];
   }
   source--;
   while( count--)
   {
      register Byte c = *source--;
      register RGBColor r = palette[ c & 0xF];
      *dest-- = map_RGB_gray[ r.r + r.g + r.b];
      r = palette[ c >> 4];
      *dest-- = map_RGB_gray[ r.r + r.g + r.b];
   }
}


/* 16 -> mapped 256 */
void
bc_nibble_byte_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref)
{
   register Byte tail = count & 1;
   dest   += count - 1;
   count  =  count >> 1;
   source += count;

   if ( tail) *dest-- = colorref[ (*source) >> 4];
   source--;
   while( count--)
   {
      register Byte c = *source--;
      *dest-- = colorref[ c & 0xF];
      *dest-- = colorref[ c >> 4];
   }
}


/* 16-> rgb */
void
bc_nibble_rgb( register Byte * source, Byte * dest, register int count, register PRGBColor palette)
{
   register Byte tail = count & 1;
   register PRGBColor rdest = ( PRGBColor) dest;
   rdest  += count - 1;
   count  =  count >> 1;
   source += count;

   if ( tail) *rdest-- = palette[ (*source) >> 4];
   source--;
   while( count--)
   {
      register Byte c = *source--;
      *rdest-- = palette[ c & 0xF];
      *rdest-- = palette[ c >> 4];
   }
}

/* Byte */
/* 256-> 1 */
void
bc_byte_mono_cr( register Byte * source, Byte * dest, register int count, register Byte * colorref)
{
   register int count8 = count >> 3;
   while ( count8--)
   {
      register Byte c = colorref[ *source++] << 7;
      c |= colorref[ *source++] << 6;
      c |= colorref[ *source++] << 5;
      c |= colorref[ *source++] << 4;
      c |= colorref[ *source++] << 3;
      c |= colorref[ *source++] << 2;
      c |= colorref[ *source++] << 1;
      *dest++ = c | colorref[ *source++];
   }
   count &= 7;
   if ( count)
   {
      register Byte c = 0;
      register Byte s = 7;
      while ( count--) c |= colorref[ *source++] << s--;
      *dest = c;
   }
}

/* byte-> mono, halftoned */
void
bc_byte_mono_ht( register Byte * source, register Byte * dest, register int count, PRGBColor palette, int lineSeqNo)
{
#define b64cmp  (( r = palette[ *source++], (( map_RGB_gray[r.r+r.g+r.b] >> 2) > map_halftone8x8_64[ index++]))?1:0)
   int count8 = count & 7;
   lineSeqNo = ( lineSeqNo & 7) << 3;
   count >>= 3;
   while ( count--)
   {
      register Byte  index = lineSeqNo;
      register Byte  dst;
      register RGBColor r;
      dst  = b64cmp << 7;
      dst |= b64cmp << 6;
      dst |= b64cmp << 5;
      dst |= b64cmp << 4;
      dst |= b64cmp << 3;
      dst |= b64cmp << 2;
      dst |= b64cmp << 1;
      *dest++ = dst | b64cmp;
   }
   if ( count8)
   {
      register Byte     index = lineSeqNo;
      register Byte     dst = 0;
      register Byte     i = 7;
      register RGBColor r;
      count = count8;
      while( count--) dst |= b64cmp << i--;
      *dest = dst;
   }
}

/* byte-> mono, halftoned */
void
bc_byte_mono_ed( Byte * source, Byte * dest, int count, PRGBColor palette, int * err_buf)
{
   dEDIFF_ARGS;
   int count8 = count & 7;
   EDIFF_INIT;
   count >>= 3;
   while ( count--)
   {
      Byte dst = 0, c, i = 8;
      while ( i--) {
         c = *source++;
         c = map_RGB_gray[ palette[c].r + palette[c].g + palette[c].b];
         EDIFF_BEGIN_PIXEL(c,c,c);
         dst |= (( r + g + b ) > 383) << i;
         EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
      }
      *dest++ = dst;
   }
   if ( count8) {
      Byte dst = 0, c, i = 8;
      while ( count8--) {
         c = *source++;
         c = map_RGB_gray[ palette[c].r + palette[c].g + palette[c].b];
         EDIFF_BEGIN_PIXEL(c,c,c);
         dst |= (( r + g + b ) > 383) << --i;
         EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
      }
      *dest = dst;
   }
}   

/* 256-> 16 */
void
bc_byte_nibble_cr( register Byte * source, Byte * dest, register int count, register Byte * colorref)
{
   Byte tail = count & 1;
   count = count >> 1;
   while ( count--)
   {
      register Byte c = colorref[ *source++] << 4;
      *dest++     = c | colorref[ *source++];
   }
   if ( tail) *dest = colorref[ *source] << 4;
}

/* 256-> 16 cubic halftoned */
void
bc_byte_nibble_ht( register Byte * source, Byte * dest, register int count, register PRGBColor palette, int lineSeqNo)
{
#define b8cmp (                                      \
                (((( r. b+1) >> 2) > cmp))      +  \
                (((( r. g+1) >> 2) > cmp) << 1) +  \
                (((( r. r+1) >> 2) > cmp) << 2)    \
               )
   Byte tail = count & 1;
   lineSeqNo = ( lineSeqNo & 7) << 3;
   count = count >> 1;
   while ( count--)
   {
      register Byte index = lineSeqNo + (( count & 3) << 1);
      register Byte dst;
      register RGBColor r;
      register Byte cmp;

      r = palette[ *source++];
      cmp = map_halftone8x8_64[ index++];
      dst = b8cmp << 4;
      r = palette[ *source++];
      cmp = map_halftone8x8_64[ index];
      *dest++ = dst + b8cmp;
   }
   if ( tail)
   {
      register RGBColor r = palette[ *source];
      register Byte cmp   = map_halftone8x8_64[ lineSeqNo + 1];
      *dest = b8cmp << 4;
   }
}

/* 256-> 16 cubic, error diffusion */
void
bc_byte_nibble_ed( Byte * source, Byte * dest, int count, PRGBColor palette, int * err_buf)
{
   dEDIFF_ARGS;
   Byte tail = count & 1;
   count = count >> 1;
   EDIFF_INIT;
   while ( count--)
   {
      Byte dst, c;
      c = *source++;
      EDIFF_BEGIN_PIXEL(palette[c].r, palette[c].g, palette[c].b);
      dst = (( r > 127) * 4 + (g > 127) * 2 + (b > 127)) << 4;
      EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
      c = *source++;
      EDIFF_BEGIN_PIXEL(palette[c].r, palette[c].g, palette[c].b);
      *dest++ = dst | (( r > 127) * 4 + (g > 127) * 2 + (b > 127));
      EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
   }
   if ( tail)
   {
      Byte c = *source++; 
      EDIFF_BEGIN_PIXEL(palette[c].r, palette[c].g, palette[c].b);
      *dest = (( r > 127) * 4 + (g > 127) * 2 + (b > 127)) << 4;
      EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
   }
}

/* map 256 */
void
bc_byte_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref)
{
   dest   += count - 1;
   source += count - 1;
   while ( count--) *dest-- = colorref[ *source--];
}
     
/* 256, remap one palette to another */
void
bc_byte_op( Byte * source, Byte * dest, int count, U16 * tree, 
            PRGBColor src_palette, PRGBColor dst_palette, int * err_buf)
{
   dEDIFF_ARGS;
   EDIFF_INIT;
   while ( count--) {
      int table = 0, shift = 6, index;
      PRGBColor src_pal = src_palette + *(source++);
      EDIFF_BEGIN_PIXEL(src_pal->r,src_pal->g,src_pal->b);
      while ( 1) {
         index = (((r >> shift) & 3) << 4) + 
                 (((g >> shift) & 3) << 2) +
                  ((b >> shift) & 3);
         if ( tree[ table + index] & PAL_REF) {
            table = (tree[ table + index] & ~PAL_REF) * CELL_SIZE;
            shift -= 2;
         } else {
            PRGBColor dst_pal = dst_palette + (*(dest++) = tree[ table + index]);
            EDIFF_END_PIXEL( dst_pal->r, dst_pal->g, dst_pal->b);
            break;
         }
      }
   } 
}

/* 256-> gray */
void
bc_byte_graybyte( register Byte * source, register Byte * dest, register int count, register PRGBColor palette)
{
   while ( count--)
   {
      register RGBColor r = palette[ *source++];
      *dest++ = map_RGB_gray[ r .r + r. g + r. b];
   }
}

/* 256-> rgb */
void
bc_byte_rgb( register Byte * source, Byte * dest, register int count, register PRGBColor palette)
{
   register PRGBColor rdest = ( PRGBColor) dest;
   rdest  += count - 1;
   source += count - 1;
   while ( count--) *rdest-- = palette[ *source--];
}

/* Gray Byte */
/* gray-> mono, halftoned */
void
bc_graybyte_mono_ht( register Byte * source, register Byte * dest, register int count, int lineSeqNo)
{
#define gb64cmp  (((*source+++1) >> 2) > map_halftone8x8_64[ index++])
   int count8 = count & 7;
   lineSeqNo = ( lineSeqNo & 7) << 3;
   count >>= 3;
   while ( count--)
   {
      register Byte  index = lineSeqNo;
      register Byte  dst;
      dst  = gb64cmp << 7;
      dst |= gb64cmp << 6;
      dst |= gb64cmp << 5;
      dst |= gb64cmp << 4;
      dst |= gb64cmp << 3;
      dst |= gb64cmp << 2;
      dst |= gb64cmp << 1;
      *dest++ = dst | gb64cmp;
   }
   if ( count8)
   {
      register Byte  index = lineSeqNo;
      register Byte  dst = 0;
      register Byte  i = 7;
      count = count8;
      while( count--) dst |= gb64cmp << i--;
      *dest = dst;
   }
}

/* gray -> 16 gray */
void
bc_graybyte_nibble_ht( register Byte * source, Byte * dest, register int count, int lineSeqNo)
{
#define gb16cmp ( div17[c] + (( mod17mul3[c]) > cmp))
   Byte tail = count & 1;
   lineSeqNo = ( lineSeqNo & 7) << 3;
   count = count >> 1;
   while ( count--)
   {
      register short c;
      register Byte index = lineSeqNo + (( count & 3) << 1);
      register Byte dst;
      register Byte cmp;
      c = *source++;
      cmp = map_halftone8x8_51[ index++];
      dst = gb16cmp << 4;
      c = *source++;
      cmp = map_halftone8x8_51[ index];
      *dest++ = dst + gb16cmp;
   }
   if ( tail)
   {
      register short c = *source;
      register Byte cmp = map_halftone8x8_51[ lineSeqNo + 1];
      *dest = gb16cmp << 4;
   }
}

/* gray -> 16 gray, error diffusion */
void
bc_graybyte_nibble_ed( Byte * source, Byte * dest, int count, int * err_buf)
{
   dEDIFF_ARGS;
   Byte tail = count & 1;
   count = count >> 1;
   EDIFF_INIT;
   while ( count--)
   {
      Byte dst, c, rm;
      c = *source++;
      EDIFF_BEGIN_PIXEL(c,c,c);
      dst = div17[r] << 4;
      rm = r % 17;
      EDIFF_END_PIXEL_EX(rm,rm,rm);
      c = *source++;
      EDIFF_BEGIN_PIXEL(c,c,c);
      rm = r % 17;
      *dest++ = dst | div17[r];
      EDIFF_END_PIXEL_EX(rm,rm,rm);
   }
   if ( tail)
   {
      Byte c = *source++, rm; 
      EDIFF_BEGIN_PIXEL(c,c,c);
      rm = r % 17;
      *dest = div17[r] << 4;
      EDIFF_END_PIXEL_EX(rm,rm,rm);
   }
}   

/* gray-> rgb */
void
bc_graybyte_rgb( register Byte * source, Byte * dest, register int count)
{
   register PRGBColor rdest = ( PRGBColor) dest;
   rdest  += count - 1;
   source += count - 1;
   while ( count--)
   {
      register Byte  c = *source--;
      register RGBColor r;
      r. r = c;
      r. b = c;
      r. g = c;
      *rdest-- = r;
   }
}

/* RGB */

/* rgb -> gray */
void
bc_rgb_graybyte( Byte * source, register Byte * dest, register int count)
{
   register PRGBColor rsource = ( PRGBColor) source;
   while ( count--)
   {
      register RGBColor r = *rsource++;
      *dest++ = map_RGB_gray[ r .r + r. g + r. b];
   }
}

/* rgb-> mono, halftoned */
void
bc_rgb_mono_ht( register Byte * source, register Byte * dest, register int count, int lineSeqNo)
{
#define tc64cmp  (( source+=3, ( map_RGB_gray[ source[-1] + source[-2] + source[-3]] >> 2) > map_halftone8x8_64[ index++])?1:0)
   int count8 = count & 7;
   lineSeqNo = ( lineSeqNo & 7) << 3;
   count >>= 3;
   while ( count--)
   {
      register Byte  index = lineSeqNo;
      register Byte  dst;
      dst  = tc64cmp << 7;
      dst |= tc64cmp << 6;
      dst |= tc64cmp << 5;
      dst |= tc64cmp << 4;
      dst |= tc64cmp << 3;
      dst |= tc64cmp << 2;
      dst |= tc64cmp << 1;
      *dest++  = dst | tc64cmp;
   }
   if ( count8)
   {
      register Byte  index = lineSeqNo;
      register Byte  dst = 0;
      register Byte  i = 7;
      count = count8;
      while( count--) dst |=  tc64cmp << i--;
      *dest = dst;
   }
}

/* rgb-> mono, error diffusion */
void
bc_rgb_mono_ed( Byte * source, Byte * dest, int count, int * err_buf)
{
   int count8 = count & 7;
   dEDIFF_ARGS;
   EDIFF_INIT;
   count >>= 3;
   while ( count--) {
      Byte i = 8, dst = 0;
      while(i--) {
         int c = map_RGB_gray[source[0]+source[1]+source[2]];
         source += 3;
         EDIFF_BEGIN_PIXEL(c,c,c);
         dst |= (( r + g + b) > 383) << i;
         EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
      }
      *dest++ = dst;
   }
   if ( count8) {
      Byte i = 8, dst = 0;
      while ( count8--) {
         int c = map_RGB_gray[source[0]+source[1]+source[2]];
         source += 3;
         EDIFF_BEGIN_PIXEL(c,c,c);
         dst |= (((r + g + b) > 383) << --i);
         EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
      }
      *dest = dst;
   }
}   

/* rgb -> nibble, no halftoning */
Byte
rgb_color_to_16( register Byte b, register Byte g, register Byte r)
{
   /* 1 == 255 */
   /* 2/3 == 170 */
   /* 1/2 == 128 */
   /* 1/3 == 85 */
   /* 0 == 0 */
   int rg, dist = 384;
   Byte code = 0;
   Byte mask = 8;

   rg = r+g;
   if ( rg-b > 128 ) code |= 1;
   if ((int)r - (int)g + (int)b > 128 ) code |= 2;
   if ((int)g + (int)b - (int)r > 128 ) code |= 4;
   if ( code == 0)
   {
      dist = 128;
      mask = 7;
   }
   else if ( code == 7)
   {
      code = 8;
      dist = 640;
      mask = 7;
   }
   if ( rg+b > dist) code |= mask;
   return code;
}

void
bc_rgb_nibble( register Byte *source, Byte *dest, int count)
{
   Byte tail = count & 1;
   register Byte *stop = source + (count >> 1)*6;
   while ( source != stop)
   {
      *dest++ = (rgb_color_to_16(source[0],source[1],source[2]) << 4) |
                 rgb_color_to_16(source[3],source[4],source[5]);
      source += 6;
   }
   if ( tail)
      *dest = rgb_color_to_16(source[0],source[1],source[2]) << 4;
}

/* rgb-> 8 halftoned */
void
bc_rgb_nibble_ht( register Byte * source, Byte * dest, register int count, int lineSeqNo)
{
#define tc8cmp  ( source+=3,                          \
                 (((( source[-3]+1) >>2) > cmp))      +  \
                 (((( source[-2]+1) >>2) > cmp) << 1) +  \
                 (((( source[-1]+1) >>2) > cmp) << 2)    \
                )
   Byte tail = count & 1;
   lineSeqNo = ( lineSeqNo & 7) << 3;
   count = count >> 1;
   while ( count--)
   {
      register Byte index = lineSeqNo + (( count & 3) << 1);
      register Byte dst;
      register Byte cmp;
      cmp = map_halftone8x8_64[ index++];
      dst = tc8cmp << 4;
      cmp = map_halftone8x8_64[ index];
      *dest++ = dst + tc8cmp;
   }
   if ( tail)
   {
      register Byte cmp  = map_halftone8x8_64[ lineSeqNo + 1];
      *dest = tc8cmp << 4;
   }
}

/* rgb-> 8 cubic, error diffusion */
void
bc_rgb_nibble_ed( Byte * source, Byte * dest, int count, int * err_buf)
{
   dEDIFF_ARGS;
   Byte tail = count & 1;
   count = count >> 1;
   EDIFF_INIT;
   while ( count--) {
      Byte dst;
      EDIFF_BEGIN_PIXEL(*(source++), *(source++), *(source++));
      dst = (( r > 127) * 4 + (g > 127) * 2 + (b > 127)) << 4;
      EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
      EDIFF_BEGIN_PIXEL(*(source++), *(source++), *(source++));
      *dest++ = dst + (( r > 127) * 4 + (g > 127) * 2 + (b > 127));
      EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
   }   
   if ( tail) {
      EDIFF_BEGIN_PIXEL(*(source++), *(source++), *(source++));
      *dest++ = (( r > 127) * 4 + (g > 127) * 2 + (b > 127)) << 4;
      EDIFF_END_PIXEL(( r > 127) ? 255 : 0, ( g > 127) ? 255 : 0, ( b > 127) ? 255 : 0);
   }
}   

/* rgb-> 256 cubic */
void
bc_rgb_byte( Byte * source, register Byte * dest, register int count)
{
   while ( count--)
   {
      register Byte dst = ( div51 [ *source++]);
      dst += ( div51[ *source++]) * 6;
      *dest++ = dst + div51[ *source++] * 36;
   }
}


/* rgb-> 256 cubic, halftoned */
void
bc_rgb_byte_ht( Byte * source, register Byte * dest, register int count, int lineSeqNo)
{
   lineSeqNo = ( lineSeqNo & 7) << 3;
   while ( count--)
   {
      register Byte cmp = map_halftone8x8_51[( count & 7) + lineSeqNo];
      register Byte src;
      register Byte dst;
      src = *source++;
      dst =  ( div51[ src] + ( mod51[ src] > cmp));
      src = *source++;
      dst += ( div51[ src] + ( mod51[ src] > cmp)) * 6;
      src = *source++;
      dst += ( div51[ src] + ( mod51[ src] > cmp)) * 36;
      *dest++ = dst;
   }
}

/* rgb-> 256 cubic, error diffusion */
void
bc_rgb_byte_ed( Byte * source, Byte * dest, int count, int * err_buf)
{
   dEDIFF_ARGS;
   EDIFF_INIT;
   while ( count--) {
      EDIFF_BEGIN_PIXEL(*(source++), *(source++), *(source++));
      *(dest++) = div51[r] * 36 + div51[g] * 6 + div51[b];
      EDIFF_END_PIXEL_EX( mod51[r], mod51[g], mod51[b]);
   }   
}   

/* rgb -> 8bit optimized */
void
bc_rgb_byte_op( RGBColor * src, Byte * dest, int count, U16 * tree, RGBColor * palette, int * err_buf)
{
   dEDIFF_ARGS;
   EDIFF_INIT;
   while ( count--) {
      int table = 0, shift = 6, index;
      EDIFF_BEGIN_PIXEL(src->r,src->g,src->b);
      src++;
      while ( 1) {
         index = (((r >> shift) & 3) << 4) + 
                 (((g >> shift) & 3) << 2) +
                  ((b >> shift) & 3);
         if ( tree[ table + index] & PAL_REF) {
            table = (tree[ table + index] & ~PAL_REF) * CELL_SIZE;
            shift -= 2;
         } else {
            *dest = tree[ table + index];
            EDIFF_END_PIXEL( palette[*dest].r, palette[*dest].g, palette[*dest].b);
            dest++;
            break;
         }
      }
   } 
}
   
/* bitstroke copiers */
void
bc_nibble_copy( Byte * source, Byte * dest, unsigned int from, unsigned int width)
{
   if ( from & 1) {
      register Byte a;
      register int byteLim = (( width - 1) >> 1) + (( width - 1) & 1);
      source += from >> 1;
      a = *source++;
      while ( byteLim--) {
         register Byte b = *source++;
         *dest++ = ( a << 4) | ( b >> 4);
         a = b;
      }
      if ( width & 1) *dest++ = a << 4;
   } else
      memcpy( dest, source + ( from >> 1), ( width >> 1) + ( width & 1));
}

void
bc_mono_copy( Byte * source, Byte * dest, unsigned int from, unsigned int width)
{
   if (( from & 7) != 0) {
      register Byte a;
      short    lShift = from & 7;
      short    rShift = 8 - lShift;
      register int toLim  = ( width >> 3) + ((( width & 7) > 0) ? 1 : 0);
      Byte * froLim = source + (( from + width) >> 3) + (((( from + width) & 7) > 0) ? 1 : 0);
      source += from >> 3;
      a = *source++;
      while( toLim--) {
         register Byte b = ( source == froLim) ? 0 : *source++;
         *dest++ = ( a << lShift) | ( b >> rShift);
         a = b;
      }
   } else
      memcpy( dest, source + ( from >> 3), ( width >> 3) + (( width & 7) > 0 ? 1 : 0));
}

#ifdef __cplusplus
}
#endif
