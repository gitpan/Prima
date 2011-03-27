/*
  This file was automatically generated.
  Do not edit, you'll loose your changes anyway.
*/

#include "img.h"

#ifdef __cplusplus
extern "C" {
#endif

extern void apc_img_codec_jpeg(void);
extern void apc_img_codec_png(void);
extern void apc_img_codec_tiff(void);
extern void apc_img_codec_gif(void);
extern void apc_img_codec_Xpm(void);
extern void apc_img_codec_bmp(void);

void
prima_cleanup_image_subsystem(void)
{
	apc_img_done();
}

void
prima_init_image_subsystem(void)
{
	apc_img_init();
	apc_img_codec_jpeg();
	apc_img_codec_png();
	apc_img_codec_tiff();
	apc_img_codec_gif();
	apc_img_codec_Xpm();
	apc_img_codec_bmp();
}

#ifdef __cplusplus
}
#endif

