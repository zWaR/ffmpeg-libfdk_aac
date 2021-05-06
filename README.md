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
| [bzip2](http://www.bzip.org/downloads.html) | Data Compressor                     |
| [expat](https://sourceforge.net/projects/expat/files/expat/) | XML Parser                          |
| [fdk-aac](https://sourceforge.net/projects/opencore-amr/files/fdk-aac/) | High Efficient Advanced Audio Codec |
| [ffmpeg](http://ffmpeg.org/download.html#releases) | Multimedia Framework                |
| [fontconfig](https://www.freedesktop.org/software/fontconfig/release/) | Font Accessor                       |
| [freetype](https://sourceforge.net/projects/freetype/files/freetype2/) | Font Renderer                       |
| [fribidi](https://fribidi.org/download/) | Unicode Algorithm                   |
| [harfbuzz](https://www.freedesktop.org/software/harfbuzz/release/) | Text Shaping Engine                 |
| [lame](https://sourceforge.net/projects/lame/files/lame/) | Audio Codec                         |
| [libass](https://github.com/libass/libass/releases) | Subtitle Renderer                   |
| [libiconv](https://ftp.gnu.org/pub/gnu/libiconv/) | Font Character Encoding Converter   |
| [libogg](https://www.xiph.org/downloads/) | Multimedia Container Format         |
| [libtheora](https://www.xiph.org/downloads/) | Video Codec                         |
| [libvorbis](https://www.xiph.org/downloads/) | Audio Codec                         |
| [libvpx](http://downloads.webmproject.org/releases/webm/index.html) | Video Codec                         |
| [libxml2](ftp://xmlsoft.org/libxml2/)    | XML Parser                          |
| [x264](ftp://ftp.videolan.org/pub/x264/snapshots) | Video Codec                         |
| [x265](https://bitbucket.org/multicoreware/x265/downloads/?tab=tags) | Video Codec                         |
| [xvidcore](https://labs.xvid.com/source/) | Video Codec                         |
| [zlib](https://sourceforge.net/projects/libpng/files/zlib/) | Data Compressor                     |
| [gnutls](https://www.gnutls.org/download.html) | GnuTLS |
