# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config);

%Config = (
  ifs                   => '\\',
  quote                 => '\"',
  platform              => 'win32',
  compiler              => 'msvc',
  incpaths              => [ 'c:\usr\local\perl\5.00502\lib\MSWin32-x86\CORE' ],
  platform_path         => 'C:\\home\\Prima\\src\\win32',
  gencls                => '\"C:\\usr\\bin\\perl.exe\" C:\\home\\Prima\\src\\utils\\gencls.pl',
  tmlink                => '\"C:\\usr\\bin\\perl.exe\" C:\\home\\Prima\\src\\utils\\tmlink.pl',
  scriptext             => '.bat',
  genclsoptions         => '--tml --h --inc',
  cc                    => 'cl.exe',
  cflags                => '-c -Od -MD -DNDEBUG -DWIN32 -D_CONSOLE -DNO_STRICT    -W3 -WX -Od -MD -DNDEBUG ',
  cdebugflags           => '-Zi',
  cincflag              => '-I',
  cobjflag              => '-Fo',
  cdefflag              => '-D',
  cdefs                 => ['HAVE_CONFIG_H=1'],
  objext                => '.obj',
  lib                   => 'lib',
  liboutflag            => '-out:',
  libext                => '.lib',
  libname               => 'C:\\home\\Prima\\src\\auto\\Prima\\Prima.lib',
  dlname                => 'C:\\home\\Prima\\src\\auto\\Prima\\Prima.dll',
  dlext                 => '.dll',
  ld                    => 'link',
  ldflags               => ' -dll -nologo -nodefaultlib -release -machine:x86  ',
  lddefflag             => '/def:',
  lddebugflags          => '/DEBUG',
  ldoutflag             => '/OUT:',
  ldlibflag             => '',
  ldlibpathflag         => '/LIBPATH:',
  ldpaths               => ['\\lib','c:\\usr\\local\\perl\\5.00502\\lib\\MSWin32-x86\\CORE','C:\\home\\Prima\\src\\auto\\Prima'],
  ldlibs                => ['oldnames.lib','kernel32.lib','user32.lib','gdi32.lib','winspool.lib','comdlg32.lib','advapi32.lib','shell32.lib','ole32.lib','oleaut32.lib','netapi32.lib','uuid.lib','wsock32.lib','mpr.lib','winmm.lib','version.lib','odbc32.lib','odbccp32.lib','msvcrt.lib','perl.lib','prigraph.lib','Prima.lib'],
  ldlibext              =>'.lib',
  perl                  => 'perl',
);

1;
