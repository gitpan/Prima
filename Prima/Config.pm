# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config %Config_inst);

%Config_inst = (
	incpaths              => [ 'C:\\strawberry\\perl\\site\\lib\\Prima\\CORE','C:\\strawberry\\perl\\site\\lib\\Prima\\CORE\\generic','C:\\strawberry\\perl\\lib\\CORE' ],
	gencls                => 'C:\\strawberry\\perl\\bin\\gencls.bat',
	tmlink                => 'C:\\strawberry\\perl\\bin\\tmlink.bat',
	libname               => 'C:\\strawberry\\perl\\site\\lib\\auto\\Prima\\Prima.a',
	dlname                => 'C:\\strawberry\\perl\\site\\lib\\auto\\Prima\\Prima.dll',
	ldpaths               => ['C:\\strawberry\\c\\lib','C:\\strawberry\\c\\i686-w64-mingw32\\lib','C:\\strawberry\\perl\\lib\\CORE'],

	libs                  => 'C:\strawberry\perl\site\lib/auto/Prima/Prima.a',
	define                => '-DHAVE_CONFIG_H=1',
	inc                   => '-IC:\\strawberry\\perl\\site\\lib\\Prima\\CORE -IC:\\strawberry\\perl\\site\\lib\\Prima\\CORE\\generic -IC:\\strawberry\\perl\\lib\\CORE',
);

%Config = (
	ifs                   => '\\',
	quote                 => '\"',
	platform              => 'win32',
	compiler              => 'gcc',
	incpaths              => [ 'C:\\home\\Prima\\Prima\\include','C:\\home\\Prima\\Prima\\include\\generic','C:\\strawberry\\perl\\lib\\CORE' ],
	platform_path         => 'C:\\home\\Prima\\Prima\\win32',
	gencls                => '\"c:\\strawberry\\perl\\bin\\perl.exe\" C:\\home\\Prima\\Prima\\utils\\gencls.pl',
	tmlink                => '\"c:\\strawberry\\perl\\bin\\perl.exe\" C:\\home\\Prima\\Prima\\utils\\tmlink.pl',
	scriptext             => '.bat',
	genclsoptions         => '--tml --h --inc',
	cc                    => 'gcc',
	cflags                => '-c  -s -O2 -DWIN32 -DHAVE_DES_FCRYPT  -DUSE_SITECUSTOMIZE -DPERL_IMPLICIT_CONTEXT -DPERL_IMPLICIT_SYS -fno-strict-aliasing -mms-bitfields -DPERL_MSVCRT_READFIX   -s -O2  ',
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
	libname               => 'C:\\home\\Prima\\Prima\\auto\\Prima\\Prima.a',
	libs                  => 'C:\\home\\Prima\\Prima\\auto\\Prima\\Prima.a',
	dlname                => 'C:\\home\\Prima\\Prima\\auto\\Prima\\Prima.dll',
	dlext                 => '.dll',
	ld                    => 'g++',
	ldflags               => ' -mdll -s -L"C:\strawberry\perl\lib\CORE" -L"C:\strawberry\c\lib"  ',
	lddefflag             => '',
	lddebugflags          => '-g',
	ldoutflag             => '-o ',
	ldlibflag             => '-l',
	ldlibpathflag         => '-L',
	ldpaths               => ['C:\\strawberry\\c\\lib','C:\\strawberry\\c\\i686-w64-mingw32\\lib','C:\\strawberry\\perl\\lib\\CORE'],
	ldlibs                => ['Xpm','gif','tiff','png','jpeg','moldname','kernel32','user32','gdi32','winspool','comdlg32','advapi32','shell32','ole32','oleaut32','netapi32','uuid','ws2_32','mpr','winmm','version','odbc32','odbccp32','comctl32','gdi32','mpr','winspool','comdlg32','perl512'],
	ldlibext              => '',
	inline                => 'inline',
	perl                  => 'c:\\strawberry\\perl\\bin\\perl.exe',
	dl_load_flags         => 0,

	libs                  => 'C:\strawberry\perl\site\lib/auto/Prima/Prima.a',
	define                => '-DHAVE_CONFIG_H=1',
	inc                   => '-IC:\\strawberry\\perl\\site\\lib\\Prima\\CORE -IC:\\strawberry\\perl\\site\\lib\\Prima\\CORE\\generic -IC:\\strawberry\\perl\\lib\\CORE',
);

1;
