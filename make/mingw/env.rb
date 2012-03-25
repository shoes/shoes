require File.expand_path('make/make')
extend Make

EXT_RUBY = "../mingw"
EXT_RUBY_BIN = "#{EXT_RUBY}/bin"
EXT_RUBY_LIB = "#{EXT_RUBY}/lib"
EXT_RUBY_LIBRUBY = "#{EXT_RUBY}/lib/ruby/#{RUBY_V}"

# TODO: We really shouldn't perform actions just by including a file
if ENV['VIDEO']
  rm_rf "dist"
  mkdir_p 'dist'
  vlc_deps = '../deps_vlc_0.8'
  copy_files vlc_deps + '/bin/plugins', 'dist'
  cp_r vlc_deps + '/bin/libvlc.dll', EXT_RUBY + '/bin'
  copy_files vlc_deps + '/include/vlc', EXT_RUBY + '/include'
  copy_files vlc_deps + '/lib', EXT_RUBY
end

CC = ENV['CC'] ? ENV['CC'] : "gcc"
file_list = ["shoes/*.c"] + %w{shoes/native/windows.c shoes/http/winhttp.c shoes/http/windownload.c}

SRC = FileList[*file_list]
OBJ = SRC.map do |x|
  x.gsub(/\.\w+$/, '.o')
end

ADD_DLL = ["shoes/appwin32.o"]

# Linux build environment
CAIRO_CFLAGS = '-I/mingw/include/glib-2.0 -I/mingw/lib/glib-2.0/include -I/mingw/include/cairo'
CAIRO_LIB = '-lcairo'
PANGO_CFLAGS = '-I/mingw/include/pango-1.0'
PANGO_LIB = '-lpangocairo-1.0 -lpango-1.0 -lpangoft2-1.0 -lpangowin32-1.0'
if ENV['VIDEO']
  VLC_CFLAGS = '-I/mingw/include/vlc'
  VLC_LIB = '-llibvlc'
else
  VLC_CFLAGS = VLC_LIB = ''
end

LINUX_CFLAGS = %[-Wall -I#{ENV['SHOES_DEPS_PATH'] || "/usr"}/include #{CAIRO_CFLAGS} #{PANGO_CFLAGS} -I#{RbConfig::CONFIG['archdir']}]
if RbConfig::CONFIG['rubyhdrdir']
  LINUX_CFLAGS << " -I#{RbConfig::CONFIG['rubyhdrdir']} -I#{RbConfig::CONFIG['rubyhdrdir']}/#{SHOES_RUBY_ARCH}"
end
LINUX_LIB_NAMES = %W[#{RUBY_SO} cairo pangocairo-1.0 ungif]

FLAGS.each do |flag|
  LINUX_CFLAGS << " -D#{flag}" if ENV[flag]
end
if ENV['DEBUG']
  LINUX_CFLAGS << " -g -O0 "
else
  LINUX_CFLAGS << " -O "
end
LINUX_CFLAGS << " -DRUBY_1_9" if RUBY_1_9

DLEXT = 'dll'
LINUX_CFLAGS << ' -I. -I/mingw/include'
LINUX_CFLAGS << ' -I/mingw/include/ruby-1.9.1/ruby' if RUBY_1_9
LINUX_CFLAGS << " -DXMD_H -DHAVE_BOOLEAN -DSHOES_WIN32 -D_WIN32_IE=0x0500 -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -DCOBJMACROS"
LINUX_LDFLAGS = " -DBUILD_DLL -lungif -ljpeg -lglib-2.0 -lgobject-2.0 -lgio-2.0 -lgmodule-2.0 -lgthread-2.0 -fPIC -shared"
LINUX_LDFLAGS << ' -lshell32 -lkernel32 -luser32 -lgdi32 -lcomdlg32 -lcomctl32 -lole32 -loleaut32 -ladvapi32 -loleacc -lwinhttp'
LINUX_CFLAGS << " -DVLC_0_8"  if ENV['VIDEO'] and VLC_0_8
cp APP['icons']['win32'], "shoes/appwin32.ico"

LINUX_LIBS = LINUX_LIB_NAMES.map { |x| "-l#{x}" }.join(' ')

LINUX_LIBS << " -L#{RbConfig::CONFIG['libdir']} #{CAIRO_LIB} #{PANGO_LIB} #{VLC_LIB}"
