# Original location of the repository

https://sourceforge.net/p/ffmpeg-hi/code/ci/master/tree/

## Purpose of forking

* Creating an AWS Lambda compatible static ffmpeg binary with `libfdk_aac` and `openssl` support.

# Title

# Build

to create a package run the following commands and follow the instructions on the screen:
```sh
sudo su
./configure
sudo make
```

# Libraries

| Source                                   | Description                         |
| ---------------------------------------- | ----------------------------------- |
| [bzip2](https://sourceware.org/bzip2/) | Data Compressor                     |
| [expat](https://github.com/libexpat/libexpat/releases) | XML Parser                          |
| [fdk-aac](https://sourceforge.net/projects/opencore-amr/files/fdk-aac/) | High Efficient Advanced Audio Codec |
| [ffmpeg](http://ffmpeg.org/download.html#releases) | Multimedia Framework                |
| [fontconfig](https://www.freedesktop.org/software/fontconfig/release/) | Font Accessor                       |
| [freetype](https://download.savannah.gnu.org/releases/freetype/) | Font Renderer                       |
| [fribidi](https://github.com/fribidi/fribidi/releases) | Unicode Algorithm                   |
| [harfbuzz](https://github.com/harfbuzz/harfbuzz/releases) | Text Shaping Engine                 |
| [lame](https://sourceforge.net/projects/lame/files/lame/) | Audio Codec                         |
| [libass](https://github.com/libass/libass/releases) | Subtitle Renderer                   |
| [libiconv](https://ftp.gnu.org/pub/gnu/libiconv/) | Font Character Encoding Converter   |
| [libogg](https://www.xiph.org/downloads/) | Multimedia Container Format         |
| [libpng](http://www.libpng.org/pub/png/libpng.html) | PNG reference library files |
| [libtheora](https://www.xiph.org/downloads/) | Video Codec                         |
| [libvorbis](https://www.xiph.org/downloads/) | Audio Codec                         |
| [libvpx](http://downloads.webmproject.org/releases/webm/index.html) | Video Codec                         |
| [libxml2](https://gitlab.gnome.org/GNOME/libxml2/-/releases)    | XML Parser                          |
| [openssl](https://www.openssl.org/source/) | OpenSSL |
| [pcre2](https://github.com/PCRE2Project/pcre2/releases) | Pearl Compatible Regular Expressions |
| [x264](https://www.videolan.org/developers/x264.html) | x264 Video Codec                         |
| [x265](https://bitbucket.org/multicoreware/x265_git/downloads/) | Video Codec                         |
| [xvidcore](https://labs.xvid.com/source/) | Video Codec                         |
| [zlib](https://www.zlib.net/) | Data Compressor                     |
