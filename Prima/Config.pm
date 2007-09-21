# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config %Config_inst);

%Config_inst = (
	incpaths              => [ '/usr/local/lib/perl5/site_perl/5.8.8/mach/Prima/CORE','/usr/local/lib/perl5/site_perl/5.8.8/mach/Prima/CORE/generic','/usr/local/lib/perl5/5.8.8/mach/CORE','/usr/local/include','/usr/local/include/freetype2','/usr/local/include/gtk-2.0','/usr/local/lib/gtk-2.0/include','/usr/local/include/atk-1.0','/usr/local/include/cairo','/usr/local/include/pango-1.0','/usr/local/include/glib-2.0','/usr/local/lib/glib-2.0/include' ],
	gencls                => '/usr/local/bin/gencls',
	tmlink                => '/usr/local/bin/tmlink',
	libname               => '/usr/local/lib/perl5/site_perl/5.8.8/mach/auto/Prima/Prima.a',
	dlname                => '/usr/local/lib/perl5/site_perl/5.8.8/mach/auto/Prima/Prima.so',
	ldpaths               => ['/usr/lib','/usr/local/lib','/usr/local/lib','/lib'],
);

%Config = (
	ifs                   => '/',
	quote                 => '\'',
	platform              => 'unix',
	compiler              => 'gcc',
	incpaths              => [ '/usr/home/dk/src/Prima/include','/usr/home/dk/src/Prima/include/generic','/usr/local/lib/perl5/5.8.8/mach/CORE','/usr/local/include','/usr/local/include/freetype2','/usr/local/include/gtk-2.0','/usr/local/lib/gtk-2.0/include','/usr/local/include/atk-1.0','/usr/local/include/cairo','/usr/local/include/pango-1.0','/usr/local/include/glib-2.0','/usr/local/lib/glib-2.0/include' ],
	platform_path         => '/usr/home/dk/src/Prima/unix',
	gencls                => '\'perl\' /usr/home/dk/src/Prima/utils/gencls.pl',
	tmlink                => '\'perl\' /usr/home/dk/src/Prima/utils/tmlink.pl',
	scriptext             => '',
	genclsoptions         => '--tml --h --inc',
	cc                    => 'cc',
	cflags                => '-c -DAPPLLIB_EXP="/usr/local/lib/perl5/5.8.8/BSDPAN" -DHAS_FPSETMASK -DHAS_FLOATINGPOINT_H -fno-strict-aliasing -pipe -Wdeclaration-after-statement -I/usr/local/include -Wall  -O2 -fno-strict-aliasing -pipe   ',
	cdebugflags           => '-g -O',
	cincflag              => '-I',
	cobjflag              => '-o ',
	cdefflag              => '-D',
	cdefs                 => ['HAVE_CONFIG_H=1'],
	objext                => '.o',
	lib                   => '',
	liboutflag            => '',
	libext                => '.a',
	libprefix             => '',
	libname               => '/usr/home/dk/src/Prima/auto/Prima/Prima.a',
	dlname                => '/usr/home/dk/src/Prima/auto/Prima/Prima.so',
	dlext                 => '.so',
	ld                    => 'cc',
	ldflags               => ' -shared  -L/usr/local/lib  ',
	lddefflag             => '',
	lddebugflags          => '-g',
	ldoutflag             => '-o ',
	ldlibflag             => '-l',
	ldlibpathflag         => '-L',
	ldpaths               => ['/usr/lib','/usr/local/lib','/usr/local/lib','/lib'],
	ldlibs                => ['m','crypt','util','gcc','X11','Xext','freetype','fontconfig','Xrender','Xft','iconv','gtk-x11-2.0','gdk-x11-2.0','Xrandr','Xi','Xinerama','atk-1.0','gdk_pixbuf-2.0','pangocairo-1.0','Xcursor','Xfixes','cairo','pangoft2-1.0','z','pango-1.0','gobject-2.0','gmodule-2.0','glib-2.0','jpeg','png','tiff','ungif','Xpm'],
	ldlibext              =>'',
	inline                => 'inline',
	perl                  => 'perl',
	dl_load_flags         => 1,
);

1;
