#!/bin/bash

# environment variables

export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
export CFLAGS="-g -O2 -I/usr/local/include"
export LDFLAGS="-s -L/usr/local/lib"

# local variables

BUILD_DIR="/usr/local/src"
CONFIGURE_ALL_FLAGS="--disable-shared --enable-static"
CONFIGURE_FFMPEG_FLAGS="\
--enable-runtime-cpudetect \
--enable-w32threads \
--disable-debug \
"

CONFIGURE_FFMPEG_CODEC_FLAGS="\
--enable-gpl \
--enable-nonfree \
--enable-zlib \
--enable-bzlib \
--enable-libfreetype \
--enable-fontconfig \
--enable-libass \
--enable-libfaac \
--enable-libfdk_aac \
--enable-libmp3lame \
--enable-libvorbis \
--enable-libtheora \
--enable-libxvid \
--enable-libx264 \
--enable-libvpx \
--enable-libbluray \
"

#~ TODO: include additional libraries into ffmpeg build
#~
#~ [+] included (working)
#~ [o] included (incomplete)
#~ [-] excluded
#~ [ ] not included yet
#~
#~ [ ] --enable-avisynth        enable reading of AVISynth script files [no]
#~ [+] --enable-bzlib           enable bzlib [autodetect]
#~ [+] --enable-fontconfig      enable fontconfig
#~ [ ] --enable-frei0r          enable frei0r video filtering
#~ [-] --enable-gnutls          enable gnutls [no]
#~ [ ] --enable-iconv           enable iconv [autodetect]
#~ [-] --enable-libaacplus      enable AAC+ encoding via libaacplus [no]
#~ [o] --enable-libass          enable libass subtitles rendering [no]
#~ [+] --enable-libbluray       enable BluRay reading using libbluray [no]
#~ [-] --enable-libcaca         enable textual display using libcaca
#~ [ ] --enable-libcelt         enable CELT decoding via libcelt [no]
#~ [ ] --enable-libcdio         enable audio CD grabbing with libcdio
#~ [-] --enable-libdc1394       enable IIDC-1394 grabbing using libdc1394 and libraw1394 [no]
#~ [+] --enable-libfaac         enable AAC encoding via libfaac [no]
#~ [+] --enable-libfdk-aac      enable AAC encoding via libfdk-aac [no]
#~ [-] --enable-libflite        enable flite (voice synthesis) support via libflite [no]
#~ [+] --enable-libfreetype     enable libfreetype [no]
#~ [ ] --enable-libgsm          enable GSM de/encoding via libgsm [no]
#~ [-] --enable-libiec61883     enable iec61883 via libiec61883 [no]
#~ [-] --enable-libilbc         enable iLBC de/encoding via libilbc [no]
#~ [-] --enable-libmodplug      enable ModPlug via libmodplug [no]
#~ [+] --enable-libmp3lame      enable MP3 encoding via libmp3lame [no]
#~ [-] --enable-libnut          enable NUT (de)muxing via libnut, native (de)muxer exists [no]
#~ [-] --enable-libopencore-amrnb enable AMR-NB de/encoding via libopencore-amrnb [no]
#~ [-] --enable-libopencore-amrwb enable AMR-WB decoding via libopencore-amrwb [no]
#~ [ ] --enable-libopencv       enable video filtering via libopencv [no]
#~ [ ] --enable-libopenjpeg     enable JPEG 2000 de/encoding via OpenJPEG [no]
#~ [ ] --enable-libopus         enable Opus decoding via libopus [no]
#~ [-] --enable-libpulse        enable Pulseaudio input via libpulse [no]
#~ [-] --enable-librtmp         enable RTMP[E] support via librtmp [no]
#~ [-] --enable-libschroedinger enable Dirac de/encoding via libschroedinger [no]
#~ [ ] --enable-libsoxr         enable Include libsoxr resampling [no]
#~ [ ] --enable-libspeex        enable Speex de/encoding via libspeex [no]
#~ [-] --enable-libstagefright-h264  enable H.264 decoding via libstagefright [no]
#~ [+] --enable-libtheora       enable Theora encoding via libtheora [no]
#~ [ ] --enable-libtwolame      enable MP2 encoding via libtwolame [no]
#~ [-] --enable-libutvideo      enable Ut Video encoding and decoding via libutvideo [no]
#~ [-] --enable-libv4l2         enable libv4l2/v4l-utils [no]
#~ [-] --enable-libvo-aacenc    enable AAC encoding via libvo-aacenc [no]
#~ [-] --enable-libvo-amrwbenc  enable AMR-WB encoding via libvo-amrwbenc [no]
#~ [+] --enable-libvorbis       enable Vorbis en/decoding via libvorbis, native implementation exists [no]
#~ [+] --enable-libvpx          enable VP8 and VP9 de/encoding via libvpx [no]
#~ [+] --enable-libx264         enable H.264 encoding via x264 [no]
#~ [ ] --enable-libxavs         enable AVS encoding via xavs [no]
#~ [+] --enable-libxvid         enable Xvid encoding via xvidcore, native MPEG-4/Xvid encoder exists [no]
#~ [-] --enable-openal          enable OpenAL 1.1 capture support [no]
#~ [-] --enable-openssl         enable openssl [no]
#~ [-] --enable-x11grab         enable X11 grabbing [no]
#~ [+] --enable-zlib            enable zlib [autodetect]

# arg1 = install directory, arg2 = package url
function install_package {
    echo
    #read -p "Press [Enter] to install $(basename $2)..."
    echo
    WD=$(pwd)
    mkdir -p $1
    cd $1
    wget -c $2
    bsdtar -x -f *.tar.*
    rm $(basename $2)
    cd $WD
    echo
}

function install_yasm {
    mkdir -p /usr/local/bin
    wget -c http://ffmpeg-builder.googlecode.com/files/yasm-1.2.0-win32.exe -O /usr/local/bin/yasm.exe
    echo
}

function install_pkgconfig {
    cd /usr/local
    wget -c http://ffmpeg-builder.googlecode.com/files/pkg-config-lite-0.28-1_bin-win32.zip
    bsdtar -x -f pkg-config*.zip
    mkdir -p /usr/local
    cp -r pkg-config*/* /usr/local
    rm -r pkg-config*
    echo
}

function build_zlib {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-zlib" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/zlib-1.2.7.tar.bz2
        bsdtar -x -f zlib*.tar.*
        cd zlib*
        make -f win32/Makefile.gcc
        mkdir -p /usr/local/include
        cp zlib.h zconf.h /usr/local/include
        mkdir -p /usr/local/lib
        cp libz.a /usr/local/lib
    fi
}

function build_bzip2 {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-bzlib" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/bzip2-1.0.6.tar.gz
        bsdtar -x -f bzip2*.tar.*
        cd bzip2*
        make
        mkdir -p /usr/local/include
        cp bzlib.h /usr/local/include
        mkdir -p /usr/local/lib
        cp libbz2.a /usr/local/lib
    fi
}

function build_expat {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/expat-2.1.0.tar.gz
        bsdtar -x -f expat*.tar.*
        cd expat*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install

        pkg-config expat >/dev/null 2>&1
        if [ $? != 0 ]
        then
            export EXPAT_CFLAGS="-I/usr/local/include"
            export EXPAT_LIBS="-L/usr/local/lib -lexpat"
        fi
    fi
}

function build_xml2 {
    # TODO: add support for libxml2...
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libbluray" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/libxml2-2.9.0.tar.gz
        bsdtar -x -f libxml2*.tar.*
        cd libxml2*
        ./configure $CONFIGURE_ALL_FLAGS --without-debug
        make
        make install

        pkg-config libxml-2.0 >/dev/null 2>&1
        if [ $? != 0 ]
        then
            export LIBXML2_CFLAGS="-I/usr/local/include/libxml2  -DLIBXML_STATIC"
            export LIBXML2_LIBS="-L/usr/local/lib -lxml2 -lz -lws2_32"
            export XML2_INCLUDEDIR="-I/usr/local/include/libxml2"
            export XML2_LIBDIR="-L/usr/local/lib"
            export XML2_LIBS="-lxml2 -lz -lws2_32"
        else
            # NOTE: modify libxml2.pc so it will return private libs even when called without --static
            sed -i -e "s|Libs:.*|Libs: $(pkg-config --libs --static libxml-2.0)|g" $PKG_CONFIG_PATH/libxml-2.0.pc
        fi
    fi
}

function build_freetype {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libfreetype" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/freetype-2.4.11.tar.bz2
        bsdtar -x -f freetype*.tar.*
        cd freetype*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install

        pkg-config freetype2 >/dev/null 2>&1
        if [ $? != 0 ]
        then
            export FREETYPE_CFLAGS="-I/usr/local/include -I/usr/local/include/freetype2"
            export FREETYPE_LIBS="-L/usr/local/lib -lfreetype -lz"
        else
            # NOTE: modify lfreetype.pc so it will return private libs even when called without --static
            sed -i -e "s|Libs:.*|Libs: $(pkg-config --libs --static freetype2)|g" $PKG_CONFIG_PATH/freetype2.pc
        fi
    fi
}

function build_fribidi {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/fribidi-0.19.5.tar.bz2
        bsdtar -x -f fribidi*.tar.*
        cd fribidi*
        # fix for static build
        sed -i -e  's/__declspec(dllimport)//g' lib/fribidi-common.h
        ./configure $CONFIGURE_ALL_FLAGS --disable-debug
        make -C charset
        # fixing lib/Makefile directly before make -C lib, or it will be overwritten by another configure process
        sed -i -e  's/am__append_1 =/#am__append_1 =/g' lib/Makefile
        make -C lib
        make
        make install

        pkg-config fribidi >/dev/null 2>&1
        if [ $? != 0 ]
        then
            export FRIBIDI_CFLAGS="-I/usr/local/include/fribidi"
            export FRIBIDI_LIBS="-L/usr/local/lib -lfribidi"
        fi
    fi
}

function build_fontconfig {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        # TODO: important note about the font configuration directory in windows:
        # http://ffmpeg.zeranoe.com/forum/viewtopic.php?f=10&t=318&start=10
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/fontconfig-2.10.92.tar.bz2
        bsdtar -x -f fontconfig*.tar.*
        cd fontconfig*
        ./configure $CONFIGURE_ALL_FLAGS --disable-docs --enable-libxml2
        make
        make install

        pkg-config fontconfig >/dev/null 2>&1
        if [ $? != 0 ]
        then
            export FONTCONFIG_CFLAGS="-I/usr/local/include"
            export FONTCONFIG_LIBS="-L/usr/local/lib -lfontconfig $XML2_LIBS $FREETYPE_LIBS"
            #export FONTCONFIG_LIBS="-L/usr/local/lib -lfontconfig -lexpat -lfreetype"
        else
            # NOTE: modify fontconfig.pc so it will return private libs even when called without --static
            sed -i -e "s|Libs:.*|Libs: $(pkg-config --libs --static fontconfig)|g" $PKG_CONFIG_PATH/fontconfig.pc
        fi
    fi
}

function build_ass {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/libass-0.10.1.tar.xz
        bsdtar -x -f libass*.tar.*
        cd libass*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install
    fi
}

function build_faac {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libfaac" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/faac-1.28.tar.bz2
        bsdtar -x -f faac*.tar.*
        cd faac*
        ./configure $CONFIGURE_ALL_FLAGS --without-mp4v2
        make
        make install
    fi
}

function build_fdkaac {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libfdk_aac" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/fdk-aac-0.1.1.tar.gz
        bsdtar -x -f fdk-aac*.tar.*
        cd fdk-aac*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install
    fi
}

function build_lame {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libmp3lame" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/lame-3.99.5.tar.gz
        bsdtar -x -f lame*.tar.*
        cd lame*
        ./configure $CONFIGURE_ALL_FLAGS --disable-frontend
        make
        make install
    fi
}

function build_ogg {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libvorbis" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libtheora" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/libogg-1.3.0.tar.xz
        bsdtar -x -f libogg*.tar.*
        cd libogg*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install

        pkg-config ogg >/dev/null 2>&1
        if [ $? != 0 ]
        then
            export OGG_CFLAGS="-I/usr/local/include"
            export OGG_LIBS="-L/usr/local/lib -logg"
        fi
    fi
}

function build_vorbis {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libvorbis" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libtheora" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/libvorbis-1.3.3.tar.xz
        bsdtar -x -f libvorbis*.tar.*
        cd libvorbis*
        ./configure $CONFIGURE_ALL_FLAGS # --with-ogg=/usr/local
        make
        make install

        pkg-config vorbis >/dev/null 2>&1
        if [ $? != 0 ]
        then
            export VORBIS_CFLAGS="-I/usr/local/include"
            export VORBIS_LIBS="-L/usr/local/lib -lvorbis -lm"
        fi
    fi
}

function build_theora {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libtheora" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/libtheora-1.1.1.tar.bz2
        bsdtar -x -f libtheora*.tar.*
        cd libtheora*
        ./configure $CONFIGURE_ALL_FLAGS --disable-examples # --disable-oggtest --disable-vorbistest --disable-sdltest --with-ogg=/usr/local --with-vorbis=/usr/local
        make
        make install
    fi
}

function build_xvid {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libxvid" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/xvidcore-1.3.2.tar.bz2
        bsdtar -x -f xvid*.tar.*
        cd xvid*/build/generic
        ./configure $CONFIGURE_ALL_FLAGS
        sed -i -e 's/-mno-cygwin//g' platform.inc
        make
        make install
        rm /usr/local/lib/xvidcore.dll
        ln -s /usr/local/lib/xvidcore.a /usr/local/lib/libxvidcore.a
    fi
}

function build_vpx {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libvpx" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/libvpx-1.2.0.tar.bz2
        bsdtar -x -f libvpx*.tar.*
        cd libvpx*
        ./configure $CONFIGURE_ALL_FLAGS --enable-runtime-cpu-detect --enable-vp8 --enable-postproc --disable-debug --disable-examples --disable-install-bins --disable-docs --disable-unit-tests
        make
        make install
    fi
}

function build_x264 {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libx264" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/x264-0.133.tar.bz2
        bsdtar -x -f x264*.tar.*
        cd x264-snapshot*
        # NOTE: x264 threads must be same regarding to ffmpeg
        # i.e.
        # when ffmpeg is compiled with --enable-w32threads [default on mingw]
        # then x264 also needs to be compiled with --enable-win32thread
        ./configure $CONFIGURE_ALL_FLAGS --bit-depth=10 --enable-strip --disable-cli --enable-win32thread
        make
        make install
    fi
}

function build_bluray {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libbluray" ]]
    then
        cd $BUILD_DIR
        wget -c http://ffmpeg-builder.googlecode.com/files/libbluray-0.2.3.tar.bz2
        bsdtar -x -f libbluray*.tar.*
        cd libbluray*
        ./configure $CONFIGURE_ALL_FLAGS --disable-examples --disable-debug --disable-doxygen-doc --disable-doxygen-dot # --disable-libxml2
        make
        make install
    fi
}

function build_ffmpeg {
    cd $BUILD_DIR
    wget -c http://ffmpeg-builder.googlecode.com/files/ffmpeg-2.0.tar.bz2
    bsdtar -x -f ffmpeg*.tar.*
    cd ffmpeg*
    ./configure $CONFIGURE_ALL_FLAGS $CONFIGURE_FFMPEG_CODEC_FLAGS $CONFIGURE_FFMPEG_FLAGS
    make
    make install
}

function build_all {

    mkdir -p $BUILD_DIR

    install_yasm
    install_pkgconfig

    build_zlib
    build_bzip2
    build_expat
    build_xml2
    build_freetype

    build_fribidi
    build_fontconfig
    # TODO: add harfbuzz shaper for libass?
    build_ass

    build_faac
    build_fdkaac
    build_lame
    build_ogg
    build_vorbis
    build_theora
    build_xvid
    build_vpx
    build_x264
    build_bluray

    build_ffmpeg
}

build_all
