# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config %Config_inst);

%Config_inst = (
	incpaths              => [ '$(lib)/Prima/CORE','$(lib)/Prima/CORE/generic','/usr/local/include','/usr/include/freetype2' ],
	gencls                => '$(bin)/gencls',
	tmlink                => '$(bin)/tmlink',
	libname               => '$(lib)/auto/Prima/Prima.a',
	dlname                => '$(lib)/auto/Prima/Prima.so',
	ldpaths               => ['/usr/X11R6/lib'],

	inc                   => '-I$(lib)/Prima/CORE -I$(lib)/Prima/CORE/generic -I/usr/local/include -I/usr/include/freetype2',
	libs                  => '',
);

%Config = (
	ifs                   => '\/',
	quote                 => '\'',
	platform              => 'unix',
	incpaths              => [ '/home/dk/src/Prima/include','/home/dk/src/Prima/include/generic','/usr/local/include','/usr/include/freetype2' ],
	gencls                => '/home/dk/src/Prima/blib/script/gencls',
	tmlink                => '/home/dk/src/Prima/blib/script/tmlink',
	scriptext             => '',
	genclsoptions         => '--tml --h --inc',
	cobjflag              => '-o ',
	coutexecflag          => '-o ',
	clinkprefix           => '',
	clibpathflag          => '-L',
	cdefs                 => [],
	libext                => '.a',
	libprefix             => '',
	libname               => '/home/dk/src/Prima/blib/arch/auto/Prima/Prima.a',
	dlname                => '/home/dk/src/Prima/blib/arch/auto/Prima/Prima.so',
	ldoutflag             => '-o ',
	ldlibflag             => '-l',
	ldlibpathflag         => '-L',
	ldpaths               => ['/usr/X11R6/lib'],
	ldlibs                => ['Xpm','ungif','tiff','png','jpeg','X11','Xext','freetype','fontconfig','Xrender','Xft'],
	ldlibext              => '',
	inline                => 'inline',
	dl_load_flags         => 1,

	inc                   => '-I/home/dk/src/Prima/include -I/home/dk/src/Prima/include/generic -I/usr/local/include -I/usr/include/freetype2',
	define                => '',
	libs                  => '',
);

1;
