# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config %Config_inst);

%Config_inst = (
  incpaths              => [ 'C:\\usr\\local\\perl\\active.631\\site\\lib\\Prima\\CORE','C:\\usr\\local\\perl\\active.631\\site\\lib\\Prima\\CORE\\generic','C:\\usr\\local\\perl\\active.631\\lib\\CORE' ],
  gencls                => 'C:\\usr\\local\\perl\\active.631\\bin\\gencls.bat',
  tmlink                => 'C:\\usr\\local\\perl\\active.631\\bin\\tmlink.bat',
  libname               => 'C:\\usr\\local\\perl\\active.631\\site\\lib\\Prima.lib',
  dlname                => 'C:\\usr\\local\\perl\\active.631\\site\\lib\\auto\\Prima\\Prima.dll',
  ldpaths               => ['"\\usr\\lib"','"\\usr\\local\\lib"','"\\usr\\lib"','"\\usr\\local\\lib"','"\\usr\\lib"','"\\usr\\local\\lib"','"C:\\usr\\local\\perl\\active.631\\lib\\CORE"','C:\\usr\\local\\perl\\active.631\\site\\lib\\auto\\Prima'],
);

%Config = (
  ifs                   => '\\',
  quote                 => '\"',
  platform              => 'win32',
  compiler              => 'msvc',
  incpaths              => [ 'C:\\home\\Prima\\install\\Prima\\include','C:\\home\\Prima\\install\\Prima\\include\\generic','C:\\usr\\local\\perl\\active.631\\lib\\CORE' ],
  platform_path         => 'C:\\home\\Prima\\install\\Prima\\win32',
  gencls                => '\"C:\\usr\\local\\perl\\active.631\\bin\\perl.exe\" C:\\home\\Prima\\install\\Prima\\utils\\gencls.pl',
  tmlink                => '\"C:\\usr\\local\\perl\\active.631\\bin\\perl.exe\" C:\\home\\Prima\\install\\Prima\\utils\\tmlink.pl',
  scriptext             => '.bat',
  genclsoptions         => '--tml --h --inc',
  cc                    => 'cl',
  cflags                => '-c -nologo -O1 -MD -DNDEBUG -DWIN32 -D_CONSOLE -DNO_STRICT -DHAVE_DES_FCRYPT  -DPERL_IMPLICIT_CONTEXT -DPERL_IMPLICIT_SYS -DPERL_MSVCRT_READFIX -W1  -nologo -O1 -MD -DNDEBUG  ',
  cdebugflags           => '-Zi',
  cincflag              => '-I',
  cobjflag              => '-Fo',
  cdefflag              => '-D',
  cdefs                 => ['HAVE_CONFIG_H=1'],
  objext                => '.obj',
  lib                   => 'lib',
  liboutflag            => '-out:',
  libext                => '.lib',
  libname               => 'C:\\home\\Prima\\install\\Prima\\auto\\Prima\\Prima.lib',
  dlname                => 'C:\\home\\Prima\\install\\Prima\\auto\\Prima\\Prima.dll',
  dlext                 => '.dll',
  ld                    => 'link',
  ldflags               => ' -dll -nologo  -release  -libpath:"C:/usr/local/perl/active.631/lib\CORE"  -machine:x86  ',
  lddefflag             => '/def:',
  lddebugflags          => '/DEBUG',
  ldoutflag             => '/OUT:',
  ldlibflag             => '',
  ldlibpathflag         => '/LIBPATH:',
  ldpaths               => ['"\\usr\\lib"','"\\usr\\local\\lib"','"\\usr\\lib"','"\\usr\\local\\lib"','"\\usr\\lib"','"\\usr\\local\\lib"','"C:\\usr\\local\\perl\\active.631\\lib\\CORE"','C:\\home\\Prima\\install\\Prima\\auto\\Prima'],
  ldlibs                => ['oldnames.lib','kernel32.lib','user32.lib','gdi32.lib','winspool.lib','comdlg32.lib','advapi32.lib','shell32.lib','ole32.lib','oleaut32.lib','netapi32.lib','uuid.lib','wsock32.lib','mpr.lib','winmm.lib','version.lib','odbc32.lib','odbccp32.lib','msvcrt.lib','perl56.lib','prigraph.lib','Prima.lib'],
  ldlibext              =>'.lib',
  inline                => '__inline',
  perl                  => 'C:\\usr\\local\\perl\\active.631\\bin\\perl.exe',
);

1;
