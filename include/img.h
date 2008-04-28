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
 * $Id: img.h,v 1.13 2008/04/26 11:19:58 dk Exp $
 */
/* Created by Dmitry Karasik <dk@plab.ku.dk> */

#ifndef _IMG_IMG_H_
#define _IMG_IMG_H_

#ifndef _APRICOT_H_
#include <apricot.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _ImgIORequest {
  size_t (*read)       ( void * handle, size_t busize, void * buffer);
  size_t (*write)      ( void * handle, size_t busize, void * buffer);
  int    (*seek)       ( void * handle, long offset, int whence);
  long   (*tell)       ( void * handle);
  int    (*flush)      ( void * handle);
  int    (*error)      ( void * handle);
  void   * handle;
} ImgIORequest, *PImgIORequest;

#define req_read(req,size,buf)       ((req)->read(((req)->handle),(size),(buf)))
#define req_write(req,size,buf)      ((req)->write(((req)->handle),(size),(buf)))
#define req_seek(req,offset,whence)  ((req)->seek(((req)->handle),(offset),(whence)))
#define req_tell(req)                ((req)->tell((req)->handle))
#define req_flush(req)               ((req)->flush((req)->handle))
#define req_error(req)               ((req)->error((req)->handle))

/* common data, request for a whole file load */

#define IMG_EVENTS_HEADER_READY 1
#define IMG_EVENTS_DATA_READY   2

typedef struct _ImgLoadFileInstance {
  /* instance data, filled by core */
  char          * fileName;
  PImgIORequest   req; 
  Bool            req_is_stdio;
  int             eventMask;      /* IMG_EVENTS_XXX / if set, Image:: events are issued */

  /* instance data, filled by open_load */
  int             frameCount;     /* total frames in the file; can return -1 if unknown */
  HV            * fileProperties; /* specific file data */
  void          * instance;       /* user instance */

  /* user-specified data - applied to whole file */
  Bool            loadExtras; 
  Bool            loadAll;
  Bool            noImageData;
  Bool            iconUnmask;
  HV            * extras;         /* profile applied to all frames */

  /* user-specified data - applied to every frame */
  HV            * profile;         /* frame-specific profile, in */
  HV            * frameProperties; /* frame-specific properties, out */
  
  int             frame;          /* request frame index */
  Bool            jointFrame;     /* true, if last frame was a previous one */
  Handle          object;         /* to be used by load */

  /* internal variables */
  int             frameMapSize;   
  int           * frameMap;
  Bool            stop;
  char          * errbuf;         /* $! value */
  
  /* scanline event progress */
  unsigned int    eventDelay;     /* in milliseconds */
  struct timeval  lastEventTime;
  int             lastEventScanline;
  int             lastCachedScanline;
} ImgLoadFileInstance, *PImgLoadFileInstance;

/* common data, request for a whole file save */

typedef struct _ImgSaveFileInstance {
  /* instance data, filled by core */
  char          * fileName;
  PImgIORequest   req; 
  Bool            req_is_stdio;
  Bool            append;         /* true if append, false if rewrite */

  /* instance data, filled by open_save */
  void          * instance;       /* result of open, user data for save session */
  HV            * extras;         /* profile applied to whole save session */

  /* user-specified data - applied to every frame */
  int             frame;
  Handle          object;         /* to be used by save */
  HV            * objectExtras;   /* extras supplied to image object */
  
  /* internal variables */
  int             frameMapSize;   
  Handle        * frameMap;
  char          * errbuf;         /* $! value */
} ImgSaveFileInstance, *PImgSaveFileInstance;

#define IMG_LOAD_FROM_FILE           0x0000001
#define IMG_LOAD_FROM_STREAM         0x0000002
#define IMG_LOAD_MULTIFRAME          0x0000004
#define IMG_SAVE_TO_FILE             0x0000010
#define IMG_SAVE_TO_STREAM           0x0000020
#define IMG_SAVE_MULTIFRAME          0x0000040

/* codec info */
typedef struct _ImgCodecInfo {
   char  * name;              /* DUFF codec */
   char  * vendor;            /* Duff & Co. */ 
   int     versionMaj;        /* 1 */
   int     versionMin;        /* 0 */
   char ** fileExtensions;    /* duf, duff */
   char  * fileType;          /* Dumb File Format  */
   char  * fileShortType;     /* DUFF */
   char ** featuresSupported; /* duff-version 1, duff-rgb, duff-cmyk */
   char  * primaModule;       /* Prima::ImgPlugins::duff.pm */
   char  * primaPackage;      /* Prima::ImgPlugins::duff */
   unsigned int IOFlags;      /* IMG_XXX */
   int   * saveTypes;         /* imMono, imBW ... 0 */
   char ** loadOutput;        /* hash keys reported by load  */
} ImgCodecInfo, *PImgCodecInfo;

struct ImgCodec;
struct ImgCodecVMT;

typedef struct ImgCodecVMT *PImgCodecVMT;
typedef struct ImgCodec    *PImgCodec;

struct ImgCodec {
   struct ImgCodecVMT * vmt;
   PImgCodecInfo info;
   void         *instance;
   void         *initParam;
};

struct ImgCodecVMT {
  int       size;
  void * (* init)            ( PImgCodecInfo * info, void * param);
  void   (* done)            ( PImgCodec instance);
  HV *   (* load_defaults)   ( PImgCodec instance);
  void   (* load_check_in)   ( PImgCodec instance, HV * system, HV * user);
  void * (* open_load)       ( PImgCodec instance, PImgLoadFileInstance fi);
  Bool   (* load)            ( PImgCodec instance, PImgLoadFileInstance fi);
  void   (* close_load)      ( PImgCodec instance, PImgLoadFileInstance fi);
  HV *   (* save_defaults)   ( PImgCodec instance);
  void   (* save_check_in)   ( PImgCodec instance, HV * system, HV * user);
  void * (* open_save)       ( PImgCodec instance, PImgSaveFileInstance fi);
  Bool   (* save)            ( PImgCodec instance, PImgSaveFileInstance fi);
  void   (* close_save)      ( PImgCodec instance, PImgSaveFileInstance fi);
};

extern List               imgCodecs;
extern struct ImgCodecVMT CNullImgCodecVMT;
extern char * imgPVEmptySet[];
extern int    imgIVEmptySet[];

extern void  apc_img_init(void);
extern void  apc_img_done(void);
extern Bool  apc_img_register( PImgCodecVMT codec, void * initParam);

extern int   apc_img_frame_count( char * fileName, PImgIORequest ioreq);
extern PList apc_img_load( Handle self, char * fileName, PImgIORequest ioreq, HV * profile, char * error);
extern int   apc_img_save( Handle self, char * fileName, PImgIORequest ioreq, HV * profile, char * error);

extern void  apc_img_codecs( PList result);
extern HV *  apc_img_info2hash( PImgCodec c);

extern void  apc_img_profile_add( HV * to, HV * from, HV * keys);
extern int   apc_img_read_palette( PRGBColor palBuf, SV * palette, Bool triplets);

/* event macros */
extern void  apc_img_notify_header_ready( PImgLoadFileInstance fi);
extern void  apc_img_notify_scanlines_ready( PImgLoadFileInstance fi, int scanlines);

#define EVENT_HEADER_READY(fi) \
  if ( fi-> eventMask & IMG_EVENTS_HEADER_READY) \
    apc_img_notify_header_ready((fi))

#define EVENT_SCANLINES_RESET(fi) \
  (fi)-> lastEventScanline = (fi)-> lastCachedScanline = 0; \
  gettimeofday( &(fi)-> lastEventTime, nil)

#define EVENT_TOPDOWN_SCANLINES_READY(fi,scanlines) \
  if ( (fi)-> eventMask & IMG_EVENTS_DATA_READY) \
    apc_img_notify_scanlines_ready((fi),scanlines)
#define EVENT_SCANLINES_FINISHED(fi) \
  if ( (fi)-> eventMask & IMG_EVENTS_DATA_READY) {\
    fi-> lastEventTime.tv_sec = fi-> lastEventTime.tv_usec = 0;\
    apc_img_notify_scanlines_ready((fi),0); \
  }

#ifdef __cplusplus
}
#endif


#endif
