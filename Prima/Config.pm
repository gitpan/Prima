# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config %Config_inst);

%Config_inst = (
	incpaths              => [ '$(lib)/Prima/CORE','$(lib)/Prima/CORE/generic','/usr/local/include','/usr/include/freetype2','/usr/include/gtk-2.0','/usr/lib/gtk-2.0/include','/usr/include/atk-1.0','/usr/include/cairo','/usr/include/pango-1.0','/usr/include/gio-unix-2.0/','/usr/include/pixman-1','/usr/include/libpng12','/usr/include/glib-2.0','/usr/lib/glib-2.0/include' ],
	gencls                => '$(bin)/gencls',
	tmlink                => '$(bin)/tmlink',
	libname               => '$(lib)/auto/Prima/Prima.a',
	dlname                => '$(lib)/auto/Prima/Prima.so',
	ldpaths               => [],

	inc                   => '-I$(lib)/Prima/CORE -I$(lib)/Prima/CORE/generic -I/usr/local/include -I/usr/include/freetype2 -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/pango-1.0 -I/usr/include/gio-unix-2.0/ -I/usr/include/pixman-1 -I/usr/include/libpng12 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include',
	libs                  => '',
);

%Config = (
	ifs                   => '\/',
	quote                 => '\'',
	platform              => 'unix',
	incpaths              => [ '/usr/home/dk/src/Prima/include','/usr/home/dk/src/Prima/include/generic','/usr/local/include','/usr/include/freetype2','/usr/include/gtk-2.0','/usr/lib/gtk-2.0/include','/usr/include/atk-1.0','/usr/include/cairo','/usr/include/pango-1.0','/usr/include/gio-unix-2.0/','/usr/include/pixman-1','/usr/include/libpng12','/usr/include/glib-2.0','/usr/lib/glib-2.0/include' ],
	gencls                => '/usr/home/dk/src/Prima/blib/script/gencls',
	tmlink                => '/usr/home/dk/src/Prima/blib/script/tmlink',
	scriptext             => '',
	genclsoptions         => '--tml --h --inc',
	cobjflag              => '-o ',
	coutexecflag          => '-o ',
	clinkprefix           => '',
	clibpathflag          => '-L',
	cdefs                 => [],
	libext                => '.a',
	libprefix             => '',
	libname               => '/usr/home/dk/src/Prima/blib/arch/auto/Prima/Prima.a',
	dlname                => '/usr/home/dk/src/Prima/blib/arch/auto/Prima/Prima.so',
	ldoutflag             => '-o ',
	ldlibflag             => '-l',
	ldlibpathflag         => '-L',
	ldpaths               => [],
	ldlibs                => ['Xpm','ungif','tiff','png','jpeg','X11','Xext','freetype','fontconfig','Xrender','Xft','gtk-x11-2.0','gdk-x11-2.0','atk-1.0','pangoft2-1.0','gdk_pixbuf-2.0','m','pangocairo-1.0','cairo','gio-2.0','pango-1.0','gobject-2.0','gmodule-2.0','gthread-2.0','rt','glib-2.0'],
	ldlibext              => '',
	inline                => 'inline',
	dl_load_flags         => 1,

	inc                   => '-I/usr/home/dk/src/Prima/include -I/usr/home/dk/src/Prima/include/generic -I/usr/local/include -I/usr/include/freetype2 -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/pango-1.0 -I/usr/include/gio-unix-2.0/ -I/usr/include/pixman-1 -I/usr/include/libpng12 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include',
	define                => '',
	libs                  => '',
);

1;
