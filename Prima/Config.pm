# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config %Config_inst);

%Config_inst = (
	incpaths              => [ '$(lib)/Prima/CORE','$(lib)/Prima/CORE/generic','/usr/local/include','/usr/include/freetype2','/usr/include/gtk-2.0','/usr/lib/x86_64-linux-gnu/gtk-2.0/include','/usr/include/atk-1.0','/usr/include/cairo','/usr/include/gdk-pixbuf-2.0','/usr/include/pango-1.0','/usr/include/gio-unix-2.0/','/usr/include/glib-2.0','/usr/lib/x86_64-linux-gnu/glib-2.0/include','/usr/include/pixman-1','/usr/include/libpng12' ],
	gencls                => '$(bin)/gencls',
	tmlink                => '$(bin)/tmlink',
	libname               => '$(lib)/auto/Prima/Prima.a',
	dlname                => '$(lib)/auto/Prima/Prima.so',
	ldpaths               => [],

	inc                   => '-I$(lib)/Prima/CORE -I$(lib)/Prima/CORE/generic -I/usr/local/include -I/usr/include/freetype2 -I/usr/include/gtk-2.0 -I/usr/lib/x86_64-linux-gnu/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/gio-unix-2.0/ -I/usr/include/glib-2.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/libpng12',
	libs                  => '',
);

%Config = (
	ifs                   => '\/',
	quote                 => '\'',
	platform              => 'unix',
	incpaths              => [ '/nfs/home/dmka/src/Prima/include','/nfs/home/dmka/src/Prima/include/generic','/usr/local/include','/usr/include/freetype2','/usr/include/gtk-2.0','/usr/lib/x86_64-linux-gnu/gtk-2.0/include','/usr/include/atk-1.0','/usr/include/cairo','/usr/include/gdk-pixbuf-2.0','/usr/include/pango-1.0','/usr/include/gio-unix-2.0/','/usr/include/glib-2.0','/usr/lib/x86_64-linux-gnu/glib-2.0/include','/usr/include/pixman-1','/usr/include/libpng12' ],
	gencls                => '/nfs/home/dmka/src/Prima/blib/script/gencls',
	tmlink                => '/nfs/home/dmka/src/Prima/blib/script/tmlink',
	scriptext             => '',
	genclsoptions         => '--tml --h --inc',
	cobjflag              => '-o ',
	coutexecflag          => '-o ',
	clinkprefix           => '',
	clibpathflag          => '-L',
	cdefs                 => [],
	libext                => '.a',
	libprefix             => '',
	libname               => '/nfs/home/dmka/src/Prima/blib/arch/auto/Prima/Prima.a',
	dlname                => '/nfs/home/dmka/src/Prima/blib/arch/auto/Prima/Prima.so',
	ldoutflag             => '-o ',
	ldlibflag             => '-l',
	ldlibpathflag         => '-L',
	ldpaths               => [],
	ldlibs                => ['Xpm','ungif','tiff','png','jpeg','X11','Xext','freetype','fontconfig','Xrender','Xft','gtk-x11-2.0','gdk-x11-2.0','atk-1.0','gio-2.0','pangoft2-1.0','pangocairo-1.0','gdk_pixbuf-2.0','cairo','pango-1.0','gobject-2.0','glib-2.0','Xrandr'],
	ldlibext              => '',
	inline                => 'inline',
	dl_load_flags         => 1,

	inc                   => '-I/nfs/home/dmka/src/Prima/include -I/nfs/home/dmka/src/Prima/include/generic -I/usr/local/include -I/usr/include/freetype2 -I/usr/include/gtk-2.0 -I/usr/lib/x86_64-linux-gnu/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/gio-unix-2.0/ -I/usr/include/glib-2.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/libpng12',
	define                => '',
	libs                  => '',
);

1;
