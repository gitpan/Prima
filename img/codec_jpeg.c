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
 * $Id: codec_jpeg.c,v 1.16 2007/09/13 14:53:08 dk Exp $
 *
 */

#include "img.h"
#include "img_conv.h"
#include "Image.h"
#undef LOCAL
#undef HAVE_STDDEF_H
#undef HAVE_STDLIB_H
#undef HAVE_BOOLEAN
#ifdef BROKEN_PERL_PLATFORM
#undef      FAR
#undef      setjmp
#undef      longjmp
#define     setjmp _setjmp
#endif
#include <sys/types.h>
#include <stdio.h>
#include <jpeglib.h>
#include <jerror.h>


#ifdef __cplusplus
extern "C" {
#endif

static char * jpgext[] = { "jpg", "jpe", "jpeg", nil };
static int    jpgbpp[] = { imbpp8 | imGrayScale, imbpp24, 0 };   

static ImgCodecInfo codec_info = {
   "JPEG",
   "Independent JPEG Group",
   6, 1,    /* version */
   jpgext,    /* extension */
   "JPEG File Interchange Format",     /* file type */
   "JPEG", /* short type */
   nil,    /* features  */
   "Prima::Image::jpeg",  /* module */
   "Prima::Image::jpeg",  /* package */
   IMG_LOAD_FROM_FILE | IMG_LOAD_FROM_STREAM | IMG_SAVE_TO_FILE | IMG_SAVE_TO_STREAM,
   jpgbpp, /* save types */
   nil
};

static void * 
init( PImgCodecInfo * info, void * param)
{
   *info = &codec_info;
   codec_info. versionMaj = JPEG_LIB_VERSION / 10;
   codec_info. versionMin = JPEG_LIB_VERSION % 10;
   return (void*)1;
}   

typedef struct _LoadRec {
   struct  jpeg_decompress_struct d;
   struct  jpeg_error_mgr         e;
   jmp_buf                        j;
   Bool                        init;
} LoadRec;

static void
load_output_message(j_common_ptr cinfo)
{
   char buffer[JMSG_LENGTH_MAX];
   PImgLoadFileInstance fi = ( PImgLoadFileInstance)( cinfo-> client_data); 
   LoadRec *l = (LoadRec*)( fi-> instance);
   if ( !l-> init) {
      (*cinfo->err->format_message) (cinfo, buffer);
      strncpy( fi-> errbuf, buffer, 256);
   }
}

static void 
load_error_exit(j_common_ptr cinfo)
{
   LoadRec *l = (LoadRec*)((( PImgLoadFileInstance)( cinfo-> client_data))-> instance);
   load_output_message( cinfo);
   longjmp( l-> j, 1);
}

/* begin ripoff from jdatasrc.c */
typedef struct {
  struct jpeg_source_mgr pub;	/* public fields */
  JOCTET * buffer;		/* start of buffer */
  boolean start_of_file;	/* have we gotten any data yet? */
  ImgIORequest  *req;
} my_source_mgr;

typedef my_source_mgr * my_src_ptr;

#define INPUT_BUF_SIZE  4096	/* choose an efficiently fread'able size */

void
init_source (j_decompress_ptr cinfo)
{
   ((my_src_ptr) cinfo->src)->start_of_file = true;
}

boolean
fill_input_buffer (j_decompress_ptr cinfo)
{
  unsigned long nbytes;
  my_src_ptr src = (my_src_ptr) cinfo->src;

  nbytes = req_read( src->req, INPUT_BUF_SIZE, src->buffer);
  if (nbytes <= 0) {
    if (src->start_of_file)	/* Treat empty input file as fatal error */
      ERREXIT(cinfo, JERR_INPUT_EMPTY);
    WARNMS(cinfo, JWRN_JPEG_EOF);
    /* Insert a fake EOI marker */
    src->buffer[0] = (JOCTET) 0xFF;
    src->buffer[1] = (JOCTET) JPEG_EOI;
    nbytes = 2;
  }

  src->pub.next_input_byte = src->buffer;
  src->pub.bytes_in_buffer = nbytes;
  src->start_of_file = false;

  return true;
}

void
skip_input_data (j_decompress_ptr cinfo, long num_bytes)
{
  my_src_ptr src = (my_src_ptr) cinfo->src;

  /* Just a dumb implementation for now.  Could use fseek() except
   * it doesn't work on pipes.  Not clear that being smart is worth
   * any trouble anyway --- large skips are infrequent.
   */
  if (num_bytes > 0) {
    while (num_bytes > (long) src->pub.bytes_in_buffer) {
      num_bytes -= (long) src->pub.bytes_in_buffer;
      (void) fill_input_buffer(cinfo);
      /* note we assume that fill_input_buffer will never return FALSE,
       * so suspension need not be handled.
       */
    }
    src->pub.next_input_byte += (size_t) num_bytes;
    src->pub.bytes_in_buffer -= (size_t) num_bytes;
  }
}

/*
 * Terminate source --- called by jpeg_finish_decompress
 * after all data has been read.  Often a no-op.
 * NB: *not* called by jpeg_abort or jpeg_destroy; surrounding
 * application must deal with any cleanup that should happen even
 * for error exit.
 */

void
term_source (j_decompress_ptr cinfo)
{
  /* no work necessary here */
}


static void
custom_src( j_decompress_ptr cinfo, PImgLoadFileInstance fi)
{
  my_src_ptr src;

  cinfo->src = (struct jpeg_source_mgr *) malloc(sizeof(my_source_mgr));
  src = (void*) cinfo-> src;			 
  src-> buffer = (JOCTET *) malloc( INPUT_BUF_SIZE * sizeof(JOCTET));
  src-> pub.init_source = init_source;
  src-> pub.fill_input_buffer = fill_input_buffer;
  src-> pub.skip_input_data = skip_input_data;
  src-> pub.resync_to_restart = jpeg_resync_to_restart; /* use default method */
  src-> pub.term_source = term_source;
  src-> pub.bytes_in_buffer = 0; /* forces fill_input_buffer on first read */
  src-> pub.next_input_byte = NULL; /* until buffer loaded */

  src-> req    = fi-> req;
}
/* end ripoff from jdatasrc.c */

static void * 
open_load( PImgCodec instance, PImgLoadFileInstance fi)
{
   LoadRec * l;
   Byte buf[2];

   if ( req_seek( fi-> req, 0, SEEK_SET) < 0) return false;
   if ( req_read( fi-> req, 2, buf) < 0) {
      req_seek( fi-> req, 0, SEEK_SET);
      return false;
   }
   if ( memcmp( "\xff\xd8", buf, 2) != 0) {
      req_seek( fi-> req, 0, SEEK_SET);
      return false;   
   }
   if ( req_seek( fi-> req, 0, SEEK_SET) < 0) return false;

   fi-> stop = true;
   fi-> frameCount = 1;
   
   l = malloc( sizeof( LoadRec));
   if ( !l) return nil;
   memset( l, 0, sizeof( LoadRec));
   l-> d. client_data = ( void*) fi;
   l-> d. err = jpeg_std_error( &l-> e);
   l-> d. err-> output_message = load_output_message;
   l-> d. err-> error_exit = load_error_exit;
   l-> init = true;
   fi-> instance = l;
   if ( setjmp( l-> j) != 0) {
      fi-> instance = nil;
      jpeg_destroy_decompress(&l-> d);
      free( l);
      return false;
   } 
   jpeg_create_decompress( &l-> d);
   if ( fi-> req_is_stdio)
      jpeg_stdio_src( &l-> d, fi-> req-> handle);
   else
      custom_src( &l-> d, fi);
   jpeg_read_header( &l-> d, true);
   l-> init = false;
   return l;
}

static Bool   
load( PImgCodec instance, PImgLoadFileInstance fi)
{
   LoadRec * l = ( LoadRec *) fi-> instance;
   PImage i = ( PImage) fi-> object;
   int bpp;
  
   if ( setjmp( l-> j) != 0) return false;
   jpeg_start_decompress( &l-> d);
   bpp = l-> d. output_components * 8;   
   if ( bpp != 8 && bpp != 24) {
      sprintf( fi-> errbuf, "Bit depth %d is not supported", bpp);
      return false;
   }   

   if ( bpp == 8) bpp |= imGrayScale;
   CImage( fi-> object)-> create_empty( fi-> object, 1, 1, bpp);
   if ( fi-> noImageData) {
      hv_store( fi-> frameProperties, "width",  5, newSViv( l-> d. output_width), 0);
      hv_store( fi-> frameProperties, "height", 6, newSViv( l-> d. output_height), 0);
      jpeg_abort_decompress( &l-> d);
      return true;
   }   
   
   CImage( fi-> object)-> create_empty( fi-> object, l-> d. output_width, l-> d. output_height, bpp);
   EVENT_HEADER_READY(fi);
   {
      Byte * dest = i-> data + ( i-> h - 1) * i-> lineSize;
      while ( l-> d.output_scanline < l-> d.output_height ) {
	 JSAMPROW sarray[1];
	 int scanlines;
         sarray[0] = dest;
         scanlines = jpeg_read_scanlines(&l-> d, sarray, 1);
         if ( bpp == 24) 
            cm_reverse_palette(( PRGBColor) dest, ( PRGBColor) dest, i-> w);
         dest -= scanlines * i-> lineSize;
         EVENT_TOPDOWN_SCANLINES_READY(fi,scanlines);
      }   
   }   
   jpeg_finish_decompress(&l-> d);
   return true;
}   


static void
close_load( PImgCodec instance, PImgLoadFileInstance fi)
{
   LoadRec * l = ( LoadRec *) fi-> instance;
   if ( !fi-> req_is_stdio) {
       my_src_ptr src = (my_src_ptr) l->d.src;
       free( src-> buffer);
       free( src);
       l->d.src = NULL;
   }
   jpeg_destroy_decompress(&l-> d);
   free( l);
}

typedef struct _SaveRec {
   struct  jpeg_compress_struct   c;
   struct  jpeg_error_mgr         e;
   jmp_buf                        j;
   Byte                       * buf;
   Bool                        init;
} SaveRec;


static void
save_output_message(j_common_ptr cinfo)
{
   char buffer[JMSG_LENGTH_MAX];
   PImgSaveFileInstance fi = ( PImgSaveFileInstance)( cinfo-> client_data); 
   SaveRec *l = (SaveRec*)( fi-> instance);
   if ( !l-> init) {
      (*cinfo->err->format_message) (cinfo, buffer);
      strncpy( fi-> errbuf, buffer, 256);
   }
}

static void 
save_error_exit(j_common_ptr cinfo)
{
   SaveRec *l = (SaveRec*)((( PImgSaveFileInstance)( cinfo-> client_data))-> instance);
   save_output_message( cinfo);
   longjmp( l-> j, 1);
}

static HV *
save_defaults( PImgCodec c)
{
   HV * profile = newHV();
   pset_i( quality, 75);
   pset_i( progressive, 0);
   return profile;
}

/* begin ripoff from jdatadst.c */

#define OUTPUT_BUF_SIZE  4096	/* choose an efficiently fwrite'able size */

/* Expanded data destination object for stdio output */

typedef struct {
  struct jpeg_destination_mgr pub; /* public fields */
  PImgIORequest req;
  JOCTET * buffer;		/* start of buffer */
} my_destination_mgr;

typedef my_destination_mgr * my_dest_ptr;

void
init_destination (j_compress_ptr cinfo)
{
  my_dest_ptr dest = (my_dest_ptr) cinfo->dest;

  /* Allocate the output buffer --- it will be released when done with image */
  dest->buffer = (JOCTET *) malloc( OUTPUT_BUF_SIZE * sizeof(JOCTET));
  dest->pub.next_output_byte = dest->buffer;
  dest->pub.free_in_buffer = OUTPUT_BUF_SIZE;
}


/* Empty the output buffer --- called whenever buffer fills up.  */

boolean
empty_output_buffer (j_compress_ptr cinfo)
{
  my_dest_ptr dest = (my_dest_ptr) cinfo->dest;

  if ( req_write(dest->req, OUTPUT_BUF_SIZE, dest->buffer) !=
      (size_t) OUTPUT_BUF_SIZE)
    ERREXIT(cinfo, JERR_FILE_WRITE);

  dest->pub.next_output_byte = dest->buffer;
  dest->pub.free_in_buffer = OUTPUT_BUF_SIZE;

  return true;
}


/*
 * Terminate destination --- called by jpeg_finish_compress
 * after all data has been written.  Usually needs to flush buffer.
 *
 * NB: *not* called by jpeg_abort or jpeg_destroy; surrounding
 * application must deal with any cleanup that should happen even
 * for error exit.
 */

void
term_destination (j_compress_ptr cinfo)
{
  my_dest_ptr dest = (my_dest_ptr) cinfo->dest;
  size_t datacount = OUTPUT_BUF_SIZE - dest->pub.free_in_buffer;

  /* Write any data remaining in the buffer */
  if (datacount > 0) {
    if (req_write(dest->req, datacount, dest->buffer) != datacount)
      ERREXIT(cinfo, JERR_FILE_WRITE);
  }
  req_flush(dest->req);
  /* Make sure we wrote the output file OK */
  if (req_error(dest->req))
    ERREXIT(cinfo, JERR_FILE_WRITE);
}

void
custom_dest(j_compress_ptr cinfo, PImgIORequest req)
{
  my_dest_ptr dest;

  cinfo->dest = (struct jpeg_destination_mgr *) malloc( sizeof(my_destination_mgr));
  dest = (my_dest_ptr) cinfo->dest;
  dest->pub.init_destination = init_destination;
  dest->pub.empty_output_buffer = empty_output_buffer;
  dest->pub.term_destination = term_destination;
  dest->req = req;
}

/* end ripoff from jdatadst.c */


static void *
open_save( PImgCodec instance, PImgSaveFileInstance fi)
{
   SaveRec * l;
   
   l = malloc( sizeof( SaveRec));
   if ( !l) return nil;
   
   memset( l, 0, sizeof( SaveRec));
   l-> c. client_data = ( void*) fi;
   l-> c. err = jpeg_std_error( &l-> e);
   l-> c. err-> output_message = save_output_message;
   l-> c. err-> error_exit = save_error_exit;
   l-> init = true;
   fi-> instance = l;
   if ( setjmp( l-> j) != 0) {
      fi-> instance = nil;
      jpeg_destroy_compress(&l-> c);
      free( l);
      return false;
   } 
   jpeg_create_compress( &l-> c);
   if ( fi-> req_is_stdio)
      jpeg_stdio_dest( &l-> c, fi-> req-> handle);
   else
      custom_dest( &l-> c, fi-> req);
   l-> init = false;
   return l;
}

static Bool   
save( PImgCodec instance, PImgSaveFileInstance fi)
{
   dPROFILE;
   PImage i = ( PImage) fi-> object;
   SaveRec * l = ( SaveRec *) fi-> instance;
   HV * profile = fi-> objectExtras;
   
   if ( setjmp( l-> j) != 0) return false;

   l-> c. image_width  = i-> w;
   l-> c. image_height = i-> h;
   l-> c. input_components = ((( i-> type & imBPP) == 24) ? 3 : 1);
   l-> c. in_color_space   = ((( i-> type & imBPP) == 24) ? JCS_RGB : JCS_GRAYSCALE);
   jpeg_set_defaults( &l-> c);
   
   if ( pexist( quality)) {
      int q = pget_i( quality);
      if ( q < 0 || q > 100) {
         strcpy( fi-> errbuf, "quality must be in 0..100");
         return false;
      }   
      jpeg_set_quality(&l-> c, q, true /* limit to baseline-JPEG values */);      
   }   

   /* Optionally allow simple progressive output. */
   if ( pexist( progressive) && pget_B( progressive)) 
      jpeg_simple_progression(&l-> c);

   if ( l-> c. input_components == 3) { /* RGB */
      l-> buf = malloc( i-> lineSize);
      if ( !l-> buf) {
         strcpy( fi-> errbuf, "not enough memory");
         return false;
      }   
   }                    

   jpeg_start_compress( &l-> c, true);
   
   {
      Byte * src = i-> data + ( i-> h - 1) * i-> lineSize;
      while ( l-> c.next_scanline < i-> h ) {
	 JSAMPROW sarray[1];
         if ( l-> buf) {
            cm_reverse_palette(( PRGBColor) src, (PRGBColor) l-> buf, i-> w);
            sarray[0] = l-> buf;
         } else 
            sarray[0] = src;
	 jpeg_write_scanlines(&l-> c, sarray, 1);
         src -= i-> lineSize;
      }   
   } 
   jpeg_finish_compress( &l-> c);
   return true;
}   

static void 
close_save( PImgCodec instance, PImgSaveFileInstance fi)
{
   SaveRec * l = ( SaveRec *) fi-> instance;
   free( l-> buf);
   if ( !fi-> req_is_stdio) {
       my_dest_ptr dest = (my_dest_ptr) l->c.dest;
       free( dest-> buffer);
       free( dest);
       l->c.dest = NULL;
   }
   jpeg_destroy_compress(&l-> c);
   free( l);
}

void 
apc_img_codec_jpeg( void )
{
   struct ImgCodecVMT vmt;
   memcpy( &vmt, &CNullImgCodecVMT, sizeof( CNullImgCodecVMT));
   vmt. init          = init;
   vmt. open_load     = open_load;
   vmt. load          = load; 
   vmt. close_load    = close_load; 
   vmt. save_defaults = save_defaults;
   vmt. open_save     = open_save;
   vmt. save          = save; 
   vmt. close_save    = close_save;
   apc_img_register( &vmt, nil);
}

#ifdef __cplusplus
}
#endif
