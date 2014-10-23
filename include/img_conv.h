/*-
 * Copyright (c) 1997-2000 The Protein Laboratory, University of Copenhagen
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
 * $Id: img_conv.h,v 1.17 2001/07/25 14:21:29 dk Exp $
 */

#include "Image.h"
#include <sys/types.h>
#include <limits.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#else
#include <io.h>
#include <fcntl.h>
#endif


#ifdef __cplusplus
extern "C" {
#endif


/* initializer routine */
extern void init_image_support(void);

/* image basic routines */
extern void ic_stretch( int type, Byte * srcData, int srcW, int srcH, Byte * dstData, int w, int h, Bool xStretch, Bool yStretch);
extern void ic_type_convert( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern int  image_guess_type( int fd);
extern Bool itype_supported( int type);
extern Bool itype_importable( int type, int *newtype, void **from_proc, void **to_proc);

/* palette routines */
extern void cm_init_colormap( void);
extern void cm_reverse_palette( PRGBColor source, PRGBColor dest, int colors);
extern void cm_squeeze_palette( PRGBColor source, int srcColors, PRGBColor dest, int destColors);
extern Byte cm_nearest_color( RGBColor color, int palSize, PRGBColor palette);
extern void cm_fill_colorref( PRGBColor fromPalette, int fromColorCount, PRGBColor toPalette, int toColorCount, Byte * colorref);

/* bitstroke conversion routines */
extern void bc_mono_nibble( register Byte * source, register Byte * dest, register int count);
extern void bc_mono_nibble_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref);
extern void bc_mono_byte( register Byte * source, register Byte * dest, register int count);
extern void bc_mono_byte_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref);
extern void bc_mono_graybyte( register Byte * source, register Byte * dest, register int count, register PRGBColor palette);
extern void bc_mono_rgb( register Byte * source, Byte * dest, register int count, register PRGBColor palette);
extern void bc_nibble_mono_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref);
extern void bc_nibble_mono_ht( register Byte * source, register Byte * dest, register int count, register PRGBColor palette, int lineSeqNo);
extern void bc_nibble_mono_ed( register Byte * source, register Byte * dest, register int count, register PRGBColor palette);
extern void bc_nibble_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref);
extern void bc_nibble_byte( register Byte * source, register Byte * dest, register int count);
extern void bc_nibble_graybyte( register Byte * source, register Byte * dest, register int count, register PRGBColor palette);
extern void bc_nibble_byte_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref);
extern void bc_nibble_rgb( register Byte * source, Byte * dest, register int count, register PRGBColor palette);
extern void bc_byte_mono_cr( register Byte * source, Byte * dest, register int count, register Byte * colorref);
extern void bc_byte_mono_ht( register Byte * source, register Byte * dest, register int count, PRGBColor palette, int lineSeqNo);
extern void bc_byte_mono_ed( register Byte * source, register Byte * dest, register int count, PRGBColor palette);
extern void bc_byte_nibble_cr( register Byte * source, Byte * dest, register int count, register Byte * colorref);
extern void bc_byte_nibble_ht( register Byte * source, Byte * dest, register int count, register PRGBColor palette, int lineSeqNo);
extern void bc_byte_nibble_ed( register Byte * source, Byte * dest, register int count, register PRGBColor palette);
extern void bc_byte_cr( register Byte * source, register Byte * dest, register int count, register Byte * colorref);
extern void bc_byte_graybyte( register Byte * source, register Byte * dest, register int count, register PRGBColor palette);
extern void bc_byte_rgb( register Byte * source, Byte * dest, register int count, register PRGBColor palette);
extern void bc_graybyte_mono_ht( register Byte * source, register Byte * dest, register int count, int lineSeqNo);
extern void bc_graybyte_mono_ed( register Byte * source, register Byte * dest, register int count);
extern void bc_graybyte_nibble_ht( register Byte * source, Byte * dest, register int count, int lineSeqNo);
extern void bc_graybyte_nibble_ed( register Byte * source, Byte * dest, register int count);
extern void bc_graybyte_rgb( register Byte * source, Byte * dest, register int count);
extern void bc_rgb_graybyte( Byte * source, register Byte * dest, register int count);
extern void bc_rgb_mono_ht( register Byte * source, register Byte * dest, register int count, int lineSeqNo);
extern void bc_rgb_mono_ed( register Byte * source, register Byte * dest, register int count);
extern Byte rgb_color_to_16( register Byte b, register Byte g, register Byte r);
extern void bc_rgb_nibble( register Byte *source, Byte *dest, int count);
extern void bc_rgb_nibble_ht( register Byte * source, Byte * dest, register int count, int lineSeqNo);
extern void bc_rgb_nibble_ed( register Byte * source, Byte * dest, register int count);
extern void bc_rgb_byte( Byte * source, register Byte * dest, register int count);
extern void bc_rgb_byte_ht( Byte * source, register Byte * dest, register int count, int lineSeqNo);
extern void bc_rgb_byte_ed( Byte * source, register Byte * dest, register int count);

/* bitstroke stretching types */

typedef void StretchProc( void * srcData, void * dstData, int w, int x, int absx, long step);
typedef StretchProc *PStretchProc;

#if !defined(sgi) || defined(__GNUC__)
#pragma pack(1)
#endif
typedef union _Fixed {
   int32_t l;
#if (BYTEORDER==0x4321) || (BYTEORDER==0x87654321)
   struct {
     int16_t  i;
     uint16_t f;
   } i;
#else   
   struct {
     uint16_t f;
     int16_t  i;
   } i;
#endif
} Fixed;
#if !defined(sgi) || defined(__GNUC__)
#pragma pack()
#endif

#define UINT16_PRECISION (1L<<(8*sizeof(uint16_t)))

/* bitstroke stretching routines */
extern void bs_mono_in( uint8_t * srcData, uint8_t * dstData, int w, int x, int absx, long step);
extern void bs_nibble_in( uint8_t * srcData, uint8_t * dstData, int w, int x, int absx, long step);
extern void bs_uint8_t_in( uint8_t * srcData, uint8_t * dstData, int w, int x, int absx, long step);
extern void bs_int16_t_in( int16_t * srcData, int16_t * dstData, int w, int x, int absx, long step);
extern void bs_RGBColor_in( RGBColor * srcData, RGBColor * dstData, int w, int x, int absx, long step);
extern void bs_int32_t_in( int32_t * srcData, int32_t * dstData, int w, int x, int absx, long step);
extern void bs_float_in( float * srcData, float * dstData, int w, int x, int absx, long step);
extern void bs_double_in( double * srcData, double * dstData, int w, int x, int absx, long step);
extern void bs_Complex_in( Complex * srcData, Complex * dstData, int w, int x, int absx, long step);
extern void bs_DComplex_in( DComplex * srcData, DComplex * dstData, int w, int x, int absx, long step);
extern void bs_mono_out( uint8_t * srcData, uint8_t * dstData, int w, int x, int absx, long step);
extern void bs_nibble_out( uint8_t * srcData, uint8_t * dstData, int w, int x, int absx, long step);
extern void bs_uint8_t_out( uint8_t * srcData, uint8_t * dstData, int w, int x, int absx, long step);
extern void bs_int16_t_out( int16_t * srcData, int16_t * dstData, int w, int x, int absx, long step);
extern void bs_RGBColor_out( RGBColor * srcData, RGBColor * dstData, int w, int x, int absx, long step);
extern void bs_int32_t_out( int32_t * srcData, int32_t * dstData, int w, int x, int absx, long step);
extern void bs_float_out( float * srcData, float * dstData, int w, int x, int absx, long step);
extern void bs_double_out( double * srcData, double * dstData, int w, int x, int absx, long step);
extern void bs_Complex_out( Complex * srcData, Complex * dstData, int w, int x, int absx, long step);
extern void bs_DComplex_out( DComplex * srcData, DComplex * dstData, int w, int x, int absx, long step);

/* bitstroke copy routines */
extern void bc_nibble_copy( Byte * source, Byte * dest, unsigned int from, unsigned int width);
extern void bc_mono_copy( Byte * source, Byte * dest, unsigned int from, unsigned int width);

/* image conversion routines */
extern void ic_mono_nibble_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_mono_byte_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_mono_graybyte_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_mono_rgb_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_nibble_mono_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_nibble_mono_ictHalftone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_nibble_mono_ictErrorDiffusion( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_nibble_byte_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_nibble_graybyte_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_nibble_rgb_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_byte_mono_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_byte_mono_ictHalftone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_byte_mono_ictErrorDiffusion( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_byte_nibble_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_byte_nibble_ictHalftone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_byte_nibble_ictErrorDiffusion( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_byte_graybyte_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_byte_rgb_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_graybyte_mono_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_graybyte_mono_ictHalftone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_graybyte_mono_ictErrorDiffusion( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_graybyte_nibble_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_graybyte_nibble_ictHalftone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_graybyte_nibble_ictErrorDiffusion( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_graybyte_byte_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_graybyte_rgb_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_rgb_mono_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_rgb_mono_ictHalftone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_rgb_mono_ictErrorDiffusion( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_rgb_nibble_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_rgb_nibble_ictHalftone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_rgb_nibble_ictErrorDiffusion( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_rgb_byte_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_rgb_byte_ictHalftone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_rgb_byte_ictErrorDiffusion( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);
extern void ic_rgb_graybyte_ictNone( Handle self, Byte * dstData, PRGBColor dstPal, int dstType);

extern void ic_Byte_Short( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Byte_Long( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Byte_float( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Byte_double( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Short_Byte( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Short_Long( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Short_float( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Short_double( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Long_Byte( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Long_Short( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Long_float( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Long_double( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_float_Byte( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_float_Short( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_float_Long( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_float_double( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_double_Byte( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_double_Short( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_double_Long( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_double_float( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);

extern void ic_Byte_float_complex( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Byte_double_complex( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Short_float_complex( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Short_double_complex( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Long_float_complex( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_Long_double_complex( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_float_float_complex( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_float_double_complex( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_double_float_complex( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_double_double_complex( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);

extern void ic_double_complex_double( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_double_complex_float( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_double_complex_Long( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_double_complex_Short( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_double_complex_Byte( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_float_complex_double( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_float_complex_float( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_float_complex_Long( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_float_complex_Short( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);
extern void ic_float_complex_Byte( Handle self, Byte *dstData, PRGBColor dstPal, int dstType);


/* image resampling routines */
extern void rs_Byte_Byte( Handle self, Byte * dstData, int dstType, double srcLo, double srcHi, double dstLo, double dstHi);
extern void rs_Short_Short( Handle self, Byte * dstData, int dstType, double srcLo, double srcHi, double dstLo, double dstHi);
extern void rs_Long_Long( Handle self, Byte * dstData, int dstType, double srcLo, double srcHi, double dstLo, double dstHi);
extern void rs_float_float( Handle self, Byte * dstData, int dstType, double srcLo, double srcHi, double dstLo, double dstHi);
extern void rs_double_double( Handle self, Byte * dstData, int dstType, double srcLo, double srcHi, double dstLo, double dstHi);
extern void rs_Short_Byte( Handle self, Byte * dstData, int dstType, double srcLo, double srcHi, double dstLo, double dstHi);
extern void rs_Long_Byte( Handle self, Byte * dstData, int dstType, double srcLo, double srcHi, double dstLo, double dstHi);
extern void rs_float_Byte( Handle self, Byte * dstData, int dstType, double srcLo, double srcHi, double dstLo, double dstHi);
extern void rs_double_Byte( Handle self, Byte * dstData, int dstType, double srcLo, double srcHi, double dstLo, double dstHi);

/* extra convertors */
extern void bc_irgb_rgb( Byte * source, Byte * dest, int count);
extern void bc_ibgr_rgb( Byte * source, Byte * dest, int count);
extern void bc_bgri_rgb( Byte * source, Byte * dest, int count);
extern void bc_rgbi_rgb( Byte * source, Byte * dest, int count);
extern void bc_rgb_irgb( Byte * source, Byte * dest, int count);
extern void bc_rgb_rgbi( Byte * source, Byte * dest, int count);
extern void bc_rgb_ibgr( Byte * source, Byte * dest, int count);
extern void bc_rgb_bgri( Byte * source, Byte * dest, int count);


/* misc */
typedef void SimpleConvProc( Byte * srcData, Byte * dstData, int count);
typedef SimpleConvProc *PSimpleConvProc;

extern void ibc_repad( Byte * source, Byte * dest, int srcLineSize, int dstLineSize, int srcDataSize, int dstDataSize, int srcBPP, int dstBPP, void * bit_conv_proc);

/* internal maps */
extern Byte     map_stdcolorref    [ 256];
extern Byte     div51              [ 256];
extern Byte     div17              [ 256];
extern Byte     mod51              [ 256];
extern Byte     mod17mul3          [ 256];
extern RGBColor cubic_palette      [ 256];
extern RGBColor cubic_palette8     [   8];
extern RGBColor cubic_palette16    [  16];
extern RGBColor stdmono_palette    [   2];
extern RGBColor std16gray_palette  [  16];
extern RGBColor std256gray_palette [ 256];
extern Byte     map_halftone8x8_51 [  64];
extern Byte     map_halftone8x8_64 [  64];


/* internal macros */

#define dBCARGS                                                   \
   int i;                                                         \
   int width = var->w, height = var->h;                           \
   int srcType = var->type;                                       \
   int srcLine = (( width * ( srcType & imBPP) + 31) / 32) * 4;   \
   int dstLine = (( width * ( dstType & imBPP) + 31) / 32) * 4;   \
   int dstColors  = ( 1 << ( dstType & imBPP)) & 0x1ff;           \
   int srcColors  = ( 1 << ( srcType & imBPP)) & 0x1ff;           \
   Byte * srcData = var->data;                                    \
   Byte colorref[ 256]

#if defined (__BORLANDC__) || ( defined (sgi) && !defined (__GNUC__))
#define BCWARN
#else
#define BCWARN                                                   \
   (void)srcType; (void)srcLine; (void)dstLine; (void)srcColors; \
   (void)dstColors; (void)srcData; (void)colorref; (void)i;
#endif

#define BC(from,to,conv) void ic_##from##_##to##_ict##conv( Handle self, Byte * dstData, PRGBColor dstPal, int dstType)
#define BCCONV srcData, dstData, width


#define map_RGB_gray ((Byte*)std256gray_palette)



#ifdef __cplusplus
}
#endif
