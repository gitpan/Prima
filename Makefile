# Makefile for Prima project under i386-freebsd
#
# THIS IS GENERATED FILE.
#
# Do not edit -- all changes will be lost.
# Edit Makefile.PL instead.

all: prima


include/generic/AbstractMenu.h: Makefile AbstractMenu.cls utils/gencls.pl Prima/Gencls.pm include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml AbstractMenu.cls include/generic

include/generic/AccelTable.h: Makefile AccelTable.cls utils/gencls.pl Prima/Gencls.pm include/generic/AbstractMenu.h AbstractMenu.cls include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml AccelTable.cls include/generic

include/generic/Application.h: Makefile Application.cls utils/gencls.pl Prima/Gencls.pm include/generic/Widget.h Widget.cls include/generic/Drawable.h Drawable.cls include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Application.cls include/generic

include/generic/Clipboard.h: Makefile Clipboard.cls utils/gencls.pl Prima/Gencls.pm include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Clipboard.cls include/generic

include/generic/Component.h: Makefile Component.cls utils/gencls.pl Prima/Gencls.pm include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Component.cls include/generic

include/generic/DeviceBitmap.h: Makefile DeviceBitmap.cls utils/gencls.pl Prima/Gencls.pm include/generic/Drawable.h Drawable.cls include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml DeviceBitmap.cls include/generic

include/generic/Drawable.h: Makefile Drawable.cls utils/gencls.pl Prima/Gencls.pm include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Drawable.cls include/generic

include/generic/File.h: Makefile File.cls utils/gencls.pl Prima/Gencls.pm include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml File.cls include/generic

include/generic/Icon.h: Makefile Icon.cls utils/gencls.pl Prima/Gencls.pm include/generic/Image.h Image.cls include/generic/Drawable.h Drawable.cls include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Icon.cls include/generic

include/generic/Image.h: Makefile Image.cls utils/gencls.pl Prima/Gencls.pm include/generic/Drawable.h Drawable.cls include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Image.cls include/generic

include/generic/Menu.h: Makefile Menu.cls utils/gencls.pl Prima/Gencls.pm include/generic/AbstractMenu.h AbstractMenu.cls include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Menu.cls include/generic

include/generic/Object.h: Makefile Object.cls utils/gencls.pl Prima/Gencls.pm 
	perl utils/gencls.pl --inc --h --tml Object.cls include/generic

include/generic/Popup.h: Makefile Popup.cls utils/gencls.pl Prima/Gencls.pm include/generic/AbstractMenu.h AbstractMenu.cls include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Popup.cls include/generic

include/generic/Printer.h: Makefile Printer.cls utils/gencls.pl Prima/Gencls.pm include/generic/Drawable.h Drawable.cls include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Printer.cls include/generic

include/generic/Timer.h: Makefile Timer.cls utils/gencls.pl Prima/Gencls.pm include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Timer.cls include/generic

include/generic/Types.h: Makefile Types.cls utils/gencls.pl Prima/Gencls.pm 
	perl utils/gencls.pl --inc --h --tml Types.cls include/generic

include/generic/Utils.h: Makefile Utils.cls utils/gencls.pl Prima/Gencls.pm 
	perl utils/gencls.pl --inc --h --tml Utils.cls include/generic

include/generic/Widget.h: Makefile Widget.cls utils/gencls.pl Prima/Gencls.pm include/generic/Drawable.h Drawable.cls include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Widget.cls include/generic

include/generic/Window.h: Makefile Window.cls utils/gencls.pl Prima/Gencls.pm include/generic/Widget.h Widget.cls include/generic/Drawable.h Drawable.cls include/generic/Component.h Component.cls include/generic/Object.h Object.cls 
	perl utils/gencls.pl --inc --h --tml Window.cls include/generic

AbstractMenu.o: Makefile AbstractMenu.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/AbstractMenu.h include/generic/Component.h include/generic/Object.h include/generic/Image.h include/generic/Drawable.h include/generic/Menu.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o AbstractMenu.o AbstractMenu.c

AccelTable.o: Makefile AccelTable.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/AccelTable.h include/generic/AbstractMenu.h include/generic/Component.h include/generic/Object.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o AccelTable.o AccelTable.c

Application.o: Makefile Application.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Timer.h include/generic/Component.h include/generic/Object.h include/generic/Window.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/generic/Application.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Application.o Application.c

Clipboard.o: Makefile Clipboard.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Application.h include/generic/Image.h include/generic/Drawable.h include/generic/Clipboard.h include/generic/Component.h include/generic/Object.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Clipboard.o Clipboard.c

Component.o: Makefile Component.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Component.h include/generic/Object.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Component.o Component.c

DeviceBitmap.o: Makefile DeviceBitmap.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/DeviceBitmap.h include/generic/Drawable.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o DeviceBitmap.o DeviceBitmap.c

Drawable.o: Makefile Drawable.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Drawable.h include/generic/Image.h include/generic/Drawable.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Drawable.o Drawable.c

File.o: Makefile File.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/File.h include/generic/Component.h include/generic/Object.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o File.o File.c

Icon.o: Makefile Icon.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Icon.h include/generic/Image.h include/generic/Drawable.h include/generic/Types.h include/img_conv.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Icon.o Icon.c

Image.o: Makefile Image.c include/img.h include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Clipboard.h include/generic/Component.h include/generic/Object.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Image.o Image.c

Menu.o: Makefile Menu.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Window.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Types.h include/generic/Menu.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Menu.o Menu.c

Object.o: Makefile Object.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Object.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Object.o Object.c

Popup.o: Makefile Popup.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Popup.h include/generic/AbstractMenu.h include/generic/Component.h include/generic/Object.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Popup.o Popup.c

Printer.o: Makefile Printer.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Printer.h include/generic/Drawable.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Printer.o Printer.c

Timer.o: Makefile Timer.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Timer.h include/generic/Component.h include/generic/Object.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Timer.o Timer.c

Utils.o: Makefile Utils.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Utils.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Utils.o Utils.c

Widget.o: Makefile Widget.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Application.h include/generic/Icon.h include/generic/Image.h include/generic/Drawable.h include/generic/Types.h include/generic/Popup.h include/generic/AbstractMenu.h include/generic/Component.h include/generic/Object.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Window.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Widget.o Widget.c

Window.o: Makefile Window.c include/apricot.h include/generic/config.h include/generic/Types.h include/generic/Window.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Types.h include/generic/Menu.h include/generic/Icon.h include/generic/Image.h include/generic/Drawable.h include/generic/Types.h include/generic/Application.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o Window.o Window.c

primguts.o: Makefile primguts.c include/apricot.h include/generic/config.h include/generic/Types.h include/guts.h include/generic/Object.h include/generic/Component.h include/generic/Object.h include/generic/File.h include/generic/Component.h include/generic/Object.h include/generic/Clipboard.h include/generic/Component.h include/generic/Object.h include/generic/DeviceBitmap.h include/generic/Drawable.h include/generic/Types.h include/generic/Drawable.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Window.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/generic/Icon.h include/generic/Image.h include/generic/Drawable.h include/generic/Types.h include/generic/AbstractMenu.h include/generic/Component.h include/generic/Object.h include/generic/AccelTable.h include/generic/AbstractMenu.h include/generic/Component.h include/generic/Object.h include/generic/Menu.h include/generic/Popup.h include/generic/AbstractMenu.h include/generic/Component.h include/generic/Object.h include/generic/Application.h include/generic/Timer.h include/generic/Component.h include/generic/Object.h include/generic/Utils.h include/generic/Printer.h include/generic/Drawable.h include/generic/Types.h include/img_conv.h include/generic/thunks.tinc
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o primguts.o primguts.c

img/bc_color.o: Makefile img/bc_color.c include/img_conv.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/bc_color.o img/bc_color.c

img/bc_const.o: Makefile img/bc_const.c include/img_conv.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/bc_const.o img/bc_const.c

img/bc_extra.o: Makefile img/bc_extra.c include/img_conv.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/bc_extra.o img/bc_extra.c

img/codec_X11.o: Makefile img/codec_X11.c include/img.h include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/codec_X11.o img/codec_X11.c

img/codec_jpeg.o: Makefile img/codec_jpeg.c include/img.h include/img_conv.h include/generic/Image.h include/generic/Drawable.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/codec_jpeg.o img/codec_jpeg.c

img/codec_png.o: Makefile img/codec_png.c include/img.h include/img_conv.h include/generic/Icon.h include/generic/Image.h include/generic/Drawable.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/codec_png.o img/codec_png.c

img/codec_ungif.o: Makefile img/codec_ungif.c include/img.h include/img_conv.h include/generic/Image.h include/generic/Drawable.h include/generic/Icon.h include/generic/Image.h include/generic/Drawable.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/codec_ungif.o img/codec_ungif.c

img/codecs.o: Makefile img/codecs.c include/img.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/codecs.o img/codecs.c

img/conv.o: Makefile img/conv.c include/img_conv.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/conv.o img/conv.c

img/ic_conv.o: Makefile img/ic_conv.c include/img_conv.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/ic_conv.o img/ic_conv.c

img/img.o: Makefile img/img.c include/img.h include/img_conv.h include/generic/Image.h include/generic/Drawable.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/img.o img/img.c

img/imgscale.o: Makefile img/imgscale.c include/img_conv.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/imgscale.o img/imgscale.c

img/imgtype.o: Makefile img/imgtype.c include/img_conv.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o img/imgtype.o img/imgtype.c

unix/apc_app.o: Makefile unix/apc_app.c include/apricot.h include/generic/config.h include/generic/Types.h include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Application.h include/generic/File.h include/generic/Component.h include/generic/Object.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_app.o unix/apc_app.c

unix/apc_clipboard.o: Makefile unix/apc_clipboard.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Application.h include/generic/Clipboard.h include/generic/Component.h include/generic/Object.h include/generic/Icon.h include/generic/Image.h include/generic/Drawable.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_clipboard.o unix/apc_clipboard.c

unix/apc_event.o: Makefile unix/apc_event.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/AbstractMenu.h include/generic/Component.h include/generic/Object.h include/generic/Application.h include/generic/Window.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_event.o unix/apc_event.c

unix/apc_font.o: Makefile unix/apc_font.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_font.o unix/apc_font.c

unix/apc_graphics.o: Makefile unix/apc_graphics.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Image.h include/generic/Drawable.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_graphics.o unix/apc_graphics.c

unix/apc_img.o: Makefile unix/apc_img.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Image.h include/generic/Drawable.h include/generic/Icon.h include/generic/Image.h include/generic/Drawable.h include/generic/Types.h include/generic/DeviceBitmap.h include/generic/Drawable.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_img.o unix/apc_img.c

unix/apc_menu.o: Makefile unix/apc_menu.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Menu.h include/generic/Image.h include/generic/Drawable.h include/generic/Window.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Types.h include/generic/Application.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_menu.o unix/apc_menu.c

unix/apc_misc.o: Makefile unix/apc_misc.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Application.h include/generic/File.h include/generic/Component.h include/generic/Object.h include/generic/Icon.h include/generic/Image.h include/generic/Drawable.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_misc.o unix/apc_misc.c

unix/apc_pointer.o: Makefile unix/apc_pointer.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Icon.h include/generic/Image.h include/generic/Drawable.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_pointer.o unix/apc_pointer.c

unix/apc_timer.o: Makefile unix/apc_timer.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_timer.o unix/apc_timer.c

unix/apc_widget.o: Makefile unix/apc_widget.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Window.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Types.h include/generic/Application.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_widget.o unix/apc_widget.c

unix/apc_win.o: Makefile unix/apc_win.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Menu.h include/generic/Icon.h include/generic/Image.h include/generic/Drawable.h include/generic/Types.h include/generic/Window.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Types.h include/generic/Application.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/apc_win.o unix/apc_win.c

unix/color.o: Makefile unix/color.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Drawable.h include/generic/Window.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Types.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/color.o unix/color.c

unix/wm_support.o: Makefile unix/wm_support.c include/unix/guts.h include/generic/config.h include/guts.h include/unix/bsd/queue.h include/generic/Widget.h include/generic/Drawable.h include/generic/Types.h include/generic/Image.h include/generic/Drawable.h include/img_conv.h include/generic/Application.h
	cc -I/usr/local/include -Wall -g -O -DPIC -fpic -c -Iinclude -Iinclude/generic -I/usr/libdata/perl/5.00503/mach/CORE -I/usr/local/include -I/usr/X11R6/include -DHAVE_CONFIG_H=1 -o unix/wm_support.o unix/wm_support.c

include/generic/thunks.tinc: Makefile include/generic/AbstractMenu.h include/generic/AccelTable.h include/generic/Application.h include/generic/Clipboard.h include/generic/Component.h include/generic/DeviceBitmap.h include/generic/Drawable.h include/generic/File.h include/generic/Icon.h include/generic/Image.h include/generic/Menu.h include/generic/Object.h include/generic/Popup.h include/generic/Printer.h include/generic/Timer.h include/generic/Types.h include/generic/Utils.h include/generic/Widget.h include/generic/Window.h
	perl utils/tmlink.pl -Iinclude/generic -oinclude/generic/thunks.tinc include/generic/AbstractMenu.tml include/generic/AccelTable.tml include/generic/Application.tml include/generic/Clipboard.tml include/generic/Component.tml include/generic/DeviceBitmap.tml include/generic/Drawable.tml include/generic/File.tml include/generic/Icon.tml include/generic/Image.tml include/generic/Menu.tml include/generic/Object.tml include/generic/Popup.tml include/generic/Printer.tml include/generic/Timer.tml include/generic/Types.tml include/generic/Utils.tml include/generic/Widget.tml include/generic/Window.tml

CP=perl Makefile.PL --cp
CPBIN=perl Makefile.PL --cpbin
MD=perl Makefile.PL --md
RM=perl Makefile.PL --rm
RMDIR=perl Makefile.PL --rmdir

dirs: 
	@echo Creating directories...
	@$(MD) include/generic auto/Prima


clean:
	$(RM) include/generic/AbstractMenu.h include/generic/AbstractMenu.inc include/generic/AbstractMenu.tml include/generic/AccelTable.h include/generic/AccelTable.inc include/generic/AccelTable.tml include/generic/Application.h include/generic/Application.inc include/generic/Application.tml include/generic/Clipboard.h include/generic/Clipboard.inc include/generic/Clipboard.tml include/generic/Component.h include/generic/Component.inc include/generic/Component.tml include/generic/DeviceBitmap.h include/generic/DeviceBitmap.inc include/generic/DeviceBitmap.tml include/generic/Drawable.h include/generic/Drawable.inc include/generic/Drawable.tml include/generic/File.h include/generic/File.inc include/generic/File.tml include/generic/Icon.h include/generic/Icon.inc include/generic/Icon.tml include/generic/Image.h include/generic/Image.inc include/generic/Image.tml include/generic/Menu.h include/generic/Menu.inc include/generic/Menu.tml include/generic/Object.h include/generic/Object.inc include/generic/Object.tml include/generic/Popup.h include/generic/Popup.inc include/generic/Popup.tml include/generic/Printer.h include/generic/Printer.inc include/generic/Printer.tml include/generic/Timer.h include/generic/Timer.inc include/generic/Timer.tml include/generic/Types.h include/generic/Types.inc include/generic/Types.tml include/generic/Utils.h include/generic/Utils.inc include/generic/Utils.tml include/generic/Widget.h include/generic/Widget.inc include/generic/Widget.tml include/generic/Window.h include/generic/Window.inc include/generic/Window.tml AbstractMenu.o AccelTable.o Application.o Clipboard.o Component.o DeviceBitmap.o Drawable.o File.o Icon.o Image.o Menu.o Object.o Popup.o Printer.o Timer.o Utils.o Widget.o Window.o primguts.o img/bc_color.o img/bc_const.o img/bc_extra.o img/codec_X11.o img/codec_jpeg.o img/codec_png.o img/codec_ungif.o img/codecs.o img/conv.o img/ic_conv.o img/img.o img/imgscale.o img/imgtype.o unix/apc_app.o unix/apc_clipboard.o unix/apc_event.o unix/apc_font.o unix/apc_graphics.o unix/apc_img.o unix/apc_menu.o unix/apc_misc.o unix/apc_pointer.o unix/apc_timer.o unix/apc_widget.o unix/apc_win.o unix/color.o unix/wm_support.o include/generic/thunks.tinc auto/Prima/Prima.so

realclean: clean
	$(RM) include/generic/config.h Makefile

bindist: all
	perl Makefile.PL --dist bin Prima-1.04

zipdist:
	perl Makefile.PL --dist zip Prima-1.04

tardist:
	perl Makefile.PL --dist tar Prima-1.04

dist: tardist
	$(RM) Prima-1.04.tar.gz
	@gzip -9 Prima-1.04.tar

prima: dirs auto/Prima/Prima.so

auto/Prima/Prima.so: AbstractMenu.o AccelTable.o Application.o Clipboard.o Component.o DeviceBitmap.o Drawable.o File.o Icon.o Image.o Menu.o Object.o Popup.o Printer.o Timer.o Utils.o Widget.o Window.o primguts.o img/bc_color.o img/bc_const.o img/bc_extra.o img/codec_X11.o img/codec_jpeg.o img/codec_png.o img/codec_ungif.o img/codecs.o img/conv.o img/ic_conv.o img/img.o img/imgscale.o img/imgtype.o unix/apc_app.o unix/apc_clipboard.o unix/apc_event.o unix/apc_font.o unix/apc_graphics.o unix/apc_img.o unix/apc_menu.o unix/apc_misc.o unix/apc_pointer.o unix/apc_timer.o unix/apc_widget.o unix/apc_win.o unix/color.o unix/wm_support.o 
	cc -Wl,-E -shared -L/usr/local/lib -lgcc -g -L/usr/local/lib -L/usr/lib -L/usr/local/lib -L/usr/X11R6/lib -o auto/Prima/Prima.so AbstractMenu.o AccelTable.o Application.o Clipboard.o Component.o DeviceBitmap.o Drawable.o File.o Icon.o Image.o Menu.o Object.o Popup.o Printer.o Timer.o Utils.o Widget.o Window.o primguts.o img/bc_color.o img/bc_const.o img/bc_extra.o img/codec_X11.o img/codec_jpeg.o img/codec_png.o img/codec_ungif.o img/codecs.o img/conv.o img/ic_conv.o img/img.o img/imgscale.o img/imgtype.o unix/apc_app.o unix/apc_clipboard.o unix/apc_event.o unix/apc_font.o unix/apc_graphics.o unix/apc_img.o unix/apc_menu.o unix/apc_misc.o unix/apc_pointer.o unix/apc_timer.o unix/apc_widget.o unix/apc_win.o unix/color.o unix/wm_support.o -lgdbm -ldb -lm -lc -lcrypt -lutil -lX11 -lXext -ljpeg -lpng -lungif

test: all
	@perl -w test/Tester.pl


Makefile: Makefile.PL 
	@echo Rebuilding Makefile...
	@perl Makefile.PL 
	@make
	@echo You are safe to ignore the following error...
	@false


install: all
	@$(CP) \
	include/generic/Application.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/PS/fonts/Courier-BoldOblique /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/fonts/NewCenturySchlbk-Bold /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/fonts/Courier /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	examples/Hand.gif /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples \
	Prima/PS/locale/ibm-cp850 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/PS/Fonts.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS \
	Prima/PS/fonts/ZapfDingbats /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/IniFile.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/Setup.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS \
	Prima/ScrollBar.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	include/generic/Printer.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/Const.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	pod/Prima/internals.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/StdBitmap.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/VB/VBControls.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB \
	include/generic/Popup.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/PS/Printer.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS \
	Prima/PS/fonts/Symbol /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	include/generic/Types.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \

	@$(CP) \
	Prima/Widgets.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/fonts/Courier-Oblique /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	pod/Prima/File.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	include/generic/Window.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/ExtLists.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	auto/Prima/Prima.a /usr/local/lib/perl5/site_perl/5.005/i386-freebsd \
	Prima/Edit.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/FontDialog.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	pod/Prima/image-load.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/Image/gif.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Image \
	Prima/PS/fonts/Helvetica-Narrow-Bold /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/VB/starter.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB \
	Prima/Image/TransparencyControl.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Image \
	Prima/Classes.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/VB/classes.gif /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB \
	Prima/Terminals.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/fonts/Times-Bold /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	include/generic/Clipboard.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/Config.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/EditDialog.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \

	@$(CP) \
	Prima/FrameSet.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	include/guts.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE \
	pod/Prima/Drawable.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/fonts/Helvetica-Narrow-BoldOblique /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/fonts/Helvetica-Narrow /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/fonts/Palatino-Italic /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	pod/Prima/Widget.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	include/generic/AccelTable.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/StdDlg.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	include/generic/Timer.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/PS/fonts/Palatino-Bold /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/KeySelector.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	include/unix/guts.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/unix \
	include/generic/DeviceBitmap.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/MsgBox.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/VB/CfgMaint.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB \
	include/img.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE \
	examples/matrix.gif /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples \
	include/generic/Component.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/Image/jpeg.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Image \

	@$(CP) \
	Prima/PS/fonts/Helvetica-Narrow-Oblique /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PrintDialog.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	include/generic/File.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/PS/fonts/AvantGarde-BookOblique /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	include/generic/AbstractMenu.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/PS/fonts/NewCenturySchlbk-BoldItalic /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/locale/ascii /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/FileDialog.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd \
	Prima/PS/fonts/Helvetica-BoldOblique /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/fonts/Helvetica /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/VB/Classes.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB \
	Prima/VB/VB.gif /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB \
	Prima/DetailedList.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	include/generic/Object.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/sysimage.gif /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/fonts/Palatino-BoldItalic /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	include/generic/Drawable.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	pod/Prima/codecs.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/Header.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \

	@$(CP) \
	Prima/PS/Encodings.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS \
	pod/gencls.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd \
	Prima/PS/locale/iso8859-1 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/VB/examples/Sample.fm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/examples \
	pod/Prima/Menu.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/locale/iso8859-2 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/PS/locale/iso8859-3 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/Buttons.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	pod/Prima/Window.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/locale/iso8859-4 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/Utils.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/VB/examples/Widgety.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/examples \
	Prima/PS/fonts/Helvetica-Oblique /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/locale/iso8859-7 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/Docks.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/Notebooks.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/locale/iso8859-9 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	include/generic/Menu.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/PS/locale/ps-iso-latin1 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	pod/Prima/Timer.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \

	@$(CP) \
	Prima/Gencls.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/VB/Config.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB \
	Prima/Make.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/fonts/Bookman-LightItalic /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/fonts/Helvetica-Bold /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/Stress.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/fonts/Times-Italic /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/fonts/Courier-Bold /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	include/apricot.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE \
	include/generic/Icon.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	include/gbm.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE \
	Prima/PS/fonts/NewCenturySchlbk-Italic /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/Lists.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	pod/Prima/Object.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/ImageDialog.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/Outlines.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/ScrollWidget.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/Drawable.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS \
	Prima/Sliders.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/locale/ps-standart /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \

	@$(CP) \
	Prima/MDI.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	pod/Prima/Image.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/locale/ibm-cp437 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/DockManager.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/IntUtils.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/locale/iso8859-10 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	pod/Prima/gp-problems.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/locale/iso8859-13 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/Label.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/locale/iso8859-14 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/PS/locale/iso8859-15 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/PS/fonts/ZapfChancery-MediumItalic /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/fonts/Palatino-Roman /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	include/generic/Widget.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	include/img_conv.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE \
	pod/Prima/Clipboard.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/fonts/AvantGarde-Demi /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/fonts/Bookman-DemiItalic /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/StartupWindow.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/ColorDialog.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \

	@$(CP) \
	include/generic/Utils.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/PS/fonts/Bookman-Demi /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/Application.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/fonts/AvantGarde-Book /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/fonts/NewCenturySchlbk-Roman /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/ImageViewer.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/VB/VBLoader.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB \
	Prima/InputLine.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	include/generic/config.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/PS/setup.fm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS \
	Prima/ComboBox.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/fonts/AvantGarde-DemiOblique /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/locale/win-cp1250 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	pod/Prima/Printer.pod /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \
	Prima/PS/locale/win-cp1252 /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	Prima/VB/CoreClasses.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB \
	include/generic/Image.h /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	Prima/PS/fonts/Times-BoldItalic /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	auto/Prima/Prima.so /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/auto/Prima \
	Prima/Image/GBM.pm /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Image \

	@$(CP) \
	Prima/PS/fonts/Times-Roman /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	Prima/PS/fonts/Bookman-Light /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \

	@$(CPBIN) \
	examples/rtc.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/rtc \
	examples/f_fill.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/f_fill \
	examples/transparent.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/transparent \
	examples/macro.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/macro \
	examples/grip.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/grip \
	examples/ps_setup.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/ps_setup \
	examples/menu.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/menu \
	examples/matrix.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/matrix \
	examples/triangle.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/triangle \
	examples/eyes.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/eyes \
	examples/mdi.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/mdi \
	examples/keys.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/keys \
	examples/frames.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/frames \
	examples/label.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/label \
	examples/e.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/e \
	examples/editor.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/editor \
	examples/socket.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/socket \
	Prima/VB/cfgmaint.pl /usr/local/bin/cfgmaint \
	examples/drivecombo.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/drivecombo \
	examples/extlist.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/extlist \

	@$(CPBIN) \
	examples/print.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/print \
	utils/gencls.pl /usr/local/bin/gencls \
	examples/fontdlg.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/fontdlg \
	examples/buttons.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/buttons \
	examples/palette.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/palette \
	examples/amba.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/amba \
	examples/ownerchange.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/ownerchange \
	examples/pointers.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/pointers \
	examples/rot.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/rot \
	examples/pitch.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/pitch \
	Prima/VB/VB.pl /usr/local/bin/VB \
	examples/sheet.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/sheet \
	examples/cv.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/cv \
	examples/launch.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/launch \
	examples/generic.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/generic \
	examples/iv.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/iv \
	examples/textview.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/textview \
	examples/outline.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/outline \
	utils/tmlink.pl /usr/local/bin/tmlink \
	examples/buttons2.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/buttons2 \

	@$(CPBIN) \
	examples/dock.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/dock \
	examples/notebk.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/notebk \
	examples/scrollbar.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/scrollbar \
	examples/listbox.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/listbox \
	examples/edit.pl /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/edit \

	@echo Updating config...
	perl Makefile.PL --updateconfig /usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Config.pm

deinstall:
	@$(RM) \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/listbox \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Application.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Courier-BoldOblique \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/NewCenturySchlbk-Bold \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Courier \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/Hand.gif \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/ibm-cp850 \
	/usr/local/bin/tmlink \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/Fonts.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/ZapfDingbats \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/ps_setup \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/IniFile.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/Setup.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/ScrollBar.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Printer.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Const.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/internals.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/StdBitmap.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/VBControls.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Popup.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/Printer.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Symbol \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Types.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Widgets.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Courier-Oblique \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/File.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Window.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/ExtLists.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima.a \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/cv \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Edit.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/FontDialog.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/launch \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/image-load.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Image/gif.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/keys \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Helvetica-Narrow-Bold \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/starter.pl \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Image/TransparencyControl.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/dock \

	@$(RM) \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Classes.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/classes.gif \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Terminals.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Times-Bold \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Clipboard.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/rtc \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Config.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/EditDialog.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/FrameSet.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/guts.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Drawable.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Helvetica-Narrow-BoldOblique \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Helvetica-Narrow \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Palatino-Italic \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Widget.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/pointers \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/matrix \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/AccelTable.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/StdDlg.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Timer.h \
	/usr/local/bin/VB \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Palatino-Bold \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/KeySelector.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/unix/guts.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/DeviceBitmap.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/MsgBox.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/CfgMaint.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/scrollbar \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/e \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/img.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/matrix.gif \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Component.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/socket \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Image/jpeg.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Helvetica-Narrow-Oblique \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PrintDialog.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/amba \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/File.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/eyes \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/sheet \

	@$(RM) \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/AvantGarde-BookOblique \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/frames \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/AbstractMenu.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/label \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/NewCenturySchlbk-BoldItalic \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/ascii \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/FileDialog.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Helvetica-BoldOblique \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Helvetica \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/Classes.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/VB.gif \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/DetailedList.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Object.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/sysimage.gif \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Palatino-BoldItalic \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/menu \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Drawable.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/codecs.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Header.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/Encodings.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/gencls.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/iso8859-1 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/examples/Sample.fm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Menu.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/iso8859-2 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/iso8859-3 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Buttons.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Window.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/iso8859-4 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Utils.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/examples/Widgety.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/edit \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Helvetica-Oblique \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/iso8859-7 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Docks.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Notebooks.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/iso8859-9 \
	/usr/local/bin/cfgmaint \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Menu.h \

	@$(RM) \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/ps-iso-latin1 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/f_fill \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Timer.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/buttons \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Gencls.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/Config.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/ownerchange \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Make.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/transparent \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/rot \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Bookman-LightItalic \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Helvetica-Bold \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Stress.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Times-Italic \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Courier-Bold \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/apricot.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/generic \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Icon.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/gbm.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/buttons2 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/NewCenturySchlbk-Italic \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Lists.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Object.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/notebk \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/ImageDialog.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Outlines.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/ScrollWidget.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/Drawable.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Sliders.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/drivecombo \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/ps-standart \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/MDI.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/fontdlg \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Image.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/ibm-cp437 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/DockManager.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/IntUtils.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/iso8859-10 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/gp-problems.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/iso8859-13 \

	@$(RM) \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Label.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/iso8859-14 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/iso8859-15 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/ZapfChancery-MediumItalic \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Palatino-Roman \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/pitch \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Widget.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/img_conv.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Clipboard.pod \
	/usr/local/bin/gencls \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/AvantGarde-Demi \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Bookman-DemiItalic \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/StartupWindow.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/textview \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/outline \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/ColorDialog.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Utils.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Bookman-Demi \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/editor \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Application.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/AvantGarde-Book \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/NewCenturySchlbk-Roman \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/ImageViewer.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/VBLoader.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/InputLine.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/config.h \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/setup.fm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/ComboBox.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/print \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/extlist \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/AvantGarde-DemiOblique \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/palette \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/win-cp1250 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Printer.pod \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale/win-cp1252 \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/CoreClasses.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/macro \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/grip \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/triangle \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic/Image.h \

	@$(RM) \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Times-BoldItalic \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/auto/Prima/Prima.so \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/mdi \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Image/GBM.pm \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples/iv \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Times-Roman \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts/Bookman-Light \

	@$(RMDIR) \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/generic \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB/examples \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE/unix \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/locale \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS/fonts \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/examples \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/Image \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/auto/Prima \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/CORE \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/PS \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima/VB \
	/usr/local/lib/perl5/site_perl/5.005/i386-freebsd/Prima \


