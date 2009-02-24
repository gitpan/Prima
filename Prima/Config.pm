# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config %Config_inst);

%Config_inst = (
	incpaths              => [ '/usr/local/lib/perl/5.10.0/Prima/CORE','/usr/local/lib/perl/5.10.0/Prima/CORE/generic','/usr/lib/perl/5.10/CORE','/usr/local/include','/usr/include/freetype2','/usr/include/gtk-2.0','/usr/lib/gtk-2.0/include','/usr/include/atk-1.0','/usr/include/cairo','/usr/include/pango-1.0','/usr/include/glib-2.0','/usr/lib/glib-2.0/include','/usr/include/directfb','/usr/include/libpng12','/usr/include/pixman-1' ],
	gencls                => '/usr/bin/gencls',
	tmlink                => '/usr/bin/tmlink',
	libname               => '/usr/local/lib/perl/5.10.0/auto/Prima/Prima.a',
	dlname                => '/usr/local/lib/perl/5.10.0/auto/Prima/Prima.so',
	ldpaths               => ['/usr/local/lib','/lib','/usr/lib','/lib64','/usr/lib64','/usr/local/lib','/lib'],

	libs                  => '',
	define                => '-DHAVE_CONFIG_H=1',
	inc                   => '-I/usr/local/lib/perl/5.10.0/Prima/CORE -I/usr/local/lib/perl/5.10.0/Prima/CORE/generic -I/usr/lib/perl/5.10/CORE -I/usr/local/include -I/usr/include/freetype2 -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/directfb -I/usr/include/libpng12 -I/usr/include/pixman-1',
);

%Config = (
	ifs                   => '/',
	quote                 => '\'',
	platform              => 'unix',
	compiler              => 'gcc',
	incpaths              => [ '/home/dk/src/Prima/include','/home/dk/src/Prima/include/generic','/usr/lib/perl/5.10/CORE','/usr/local/include','/usr/include/freetype2','/usr/include/gtk-2.0','/usr/lib/gtk-2.0/include','/usr/include/atk-1.0','/usr/include/cairo','/usr/include/pango-1.0','/usr/include/glib-2.0','/usr/lib/glib-2.0/include','/usr/include/directfb','/usr/include/libpng12','/usr/include/pixman-1' ],
	platform_path         => '/home/dk/src/Prima/unix',
	gencls                => '\'/usr/bin/perl\' /home/dk/src/Prima/utils/gencls.pl',
	tmlink                => '\'/usr/bin/perl\' /home/dk/src/Prima/utils/tmlink.pl',
	scriptext             => '',
	genclsoptions         => '--tml --h --inc',
	cc                    => 'cc',
	cflags                => '-c -D_REENTRANT -D_GNU_SOURCE -DDEBIAN -fno-strict-aliasing -pipe -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64   -O2 -g  ',
	cdebugflags           => '-g -O -Wall',
	cincflag              => '-I',
	cobjflag              => '-o ',
	cdefflag              => '-D',
	cdefs                 => ['HAVE_CONFIG_H=1'],
	objext                => '.o',
	lib                   => '',
	liboutflag            => '',
	libext                => '.a',
	libprefix             => '',
	libname               => '/home/dk/src/Prima/auto/Prima/Prima.a',
	libs                  => '/home/dk/src/Prima/auto/Prima/Prima.a',
	dlname                => '/home/dk/src/Prima/auto/Prima/Prima.so',
	dlext                 => '.so',
	ld                    => 'cc',
	ldflags               => ' -shared -O2 -g -L/usr/local/lib  ',
	lddefflag             => '',
	lddebugflags          => '-g',
	ldoutflag             => '-o ',
	ldlibflag             => '-l',
	ldlibpathflag         => '-L',
	ldpaths               => ['/usr/local/lib','/lib','/usr/lib','/lib64','/usr/lib64','/usr/local/lib','/lib'],
	ldlibs                => ['Xpm','ungif','tiff','png','jpeg','db','dl','m','pthread','c','crypt','gcc','X11','Xext','freetype','fontconfig','Xrender','Xft','gtk-x11-2.0','gdk-x11-2.0','atk-1.0','gdk_pixbuf-2.0','pangocairo-1.0','pango-1.0','cairo','gobject-2.0','gmodule-2.0','glib-2.0'],
	ldlibext              =>'',
	inline                => 'inline',
	perl                  => '/usr/bin/perl',
	dl_load_flags         => 1,

	libs                  => '',
	define                => '-DHAVE_CONFIG_H=1',
	inc                   => '-I/usr/local/lib/perl/5.10.0/Prima/CORE -I/usr/local/lib/perl/5.10.0/Prima/CORE/generic -I/usr/lib/perl/5.10/CORE -I/usr/local/include -I/usr/include/freetype2 -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/directfb -I/usr/include/libpng12 -I/usr/include/pixman-1',
);

1;
