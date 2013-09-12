# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config %Config_inst);

%Config_inst = (
	incpaths              => [ '$(lib)\Prima\CORE','$(lib)\Prima\CORE\generic' ],
	gencls                => '$(bin)\gencls.bat',
	tmlink                => '$(bin)\tmlink.bat',
	libname               => '$(lib)\auto\Prima\libPrima.a',
	dlname                => '$(lib)\auto\Prima\Prima.dll',
	ldpaths               => [],

	inc                   => '-I$(lib)\Prima\CORE -I$(lib)\Prima\CORE\generic',
	libs                  => '$(lib)\auto\Prima\libPrima.a',
);

%Config = (
	ifs                   => '\\',
	quote                 => '\"',
	platform              => 'win32',
	incpaths              => [ 'C:/home/Prima/Prima\include','C:/home/Prima/Prima\include\generic' ],
	gencls                => 'C:\home\Prima\Prima\blib\script\gencls.bat',
	tmlink                => 'C:\home\Prima\Prima\blib\script\tmlink.bat',
	scriptext             => '.bat',
	genclsoptions         => '--tml --h --inc',
	cobjflag              => '-o ',
	coutexecflag          => '-o ',
	clinkprefix           => '',
	clibpathflag          => '-L',
	cdefs                 => [],
	libext                => '.a',
	libprefix             => 'lib',
	libname               => 'C:\home\Prima\Prima\blib\arch\auto\Prima\libPrima.a',
	dlname                => 'C:\home\Prima\Prima\blib\arch\auto\Prima\Prima.dll',
	ldoutflag             => '-o ',
	ldlibflag             => '-l',
	ldlibpathflag         => '-L',
	ldpaths               => [],
	ldlibs                => ['Xpm','gif','tiff','png','jpeg','gdi32','mpr','winspool','comdlg32'],
	ldlibext              => '',
	inline                => 'inline',
	dl_load_flags         => 0,

	inc                   => '-IC:/home/Prima/Prima\include -IC:/home/Prima/Prima\include\generic',
	define                => '',
	libs                  => 'C:\home\Prima\Prima\blib\arch\auto\Prima\libPrima.a',
);

1;
