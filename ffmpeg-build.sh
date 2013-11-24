#!/bin/bash

# deb configuration

PKGNAME="ffmpeg-hi"
PKGVERSION="2.1.1"
PKGSECTION="video"
PKGAUTHOR="Ronny Wegener <wegener.ronny@gmail.com>"
PKGHOMEPAGE="http://ffmpeg-builder.googlecode.com"
PKGDEPENDS=""
PKGDESCRIPTION="Multimedia encoder
 Customized ffmpeg build for use with FFmpegYAG.
 Statically linked to reduce dependencies.
 Supports 8 and 10 bit encoding with x264.
 Supports HE-AAC profiles with fdkaac."

# environment variables

export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
export CFLAGS="-g -O2 -I/usr/local/include"
export LDFLAGS="-s -L/usr/local/lib"

# local variables

PKG_DIR=$(dirname $0)/archive
SRC_DIR=$(dirname $0)/src
BIN_DIR=$(dirname $0)/dist/usr/bin
DEB_DIR=$(dirname $0)/dist
CONFIGURE_ALL_FLAGS="--disable-shared --enable-static"
CONFIGURE_FFMPEG_LIBS=""
CONFIGURE_FFMPEG_FLAGS="\
--enable-runtime-cpudetect \
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

function remove_dev_debs {

    read -p "
Some packages are searching for installed development debian packages.
i.e. libxml2 is looking for liblzma-dev (shared!). If this package is
found, the dependency is dragged into the library. When building ffmpeg
this dependency may also be required and needs to be passed to the linker
when linking ffmpeg.

Make sure your system don't have any development packages installed that
might interfere with packages from this build

Press [Enter] to uninstall *-dev packages or [Ctrl + c] to quit..."

    # comment shared dependencies which are currently unused (i.e. expat)
    # or seems 'future' consistent with their ABI (application binary interface)

    apt-get autoremove yasm
    apt-get autoremove zlib1g-dev
    apt-get autoremove libbz2-dev
    apt-get autoremove liblzma-dev
    apt-get autoremove libexpat1-dev
    apt-get autoremove libxml2-dev
    apt-get autoremove libfreetype6-dev
    apt-get autoremove libfribidi-dev
    apt-get autoremove libfontconfig1-dev
    apt-get autoremove libass-dev
    apt-get autoremove libfaac-dev
    apt-get autoremove libfdk-aac-dev
    apt-get autoremove libmp3lame-dev
    apt-get autoremove libtheora-dev
    apt-get autoremove libvorbis-dev
    apt-get autoremove libogg-dev
    apt-get autoremove libxvidcore-dev
    apt-get autoremove libvpx-dev
    apt-get autoremove libx264.*-dev
    apt-get autoremove libbluray-dev
}

function build_yasm {
    cd $SRC_DIR
    rm -r yasm*
    #wget -N http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
    tar -xzvf $PKG_DIR/yasm*.tar.*
    cd yasm*
    ./configure
    make
    make install
    make clean
}

function install_pkgconfig {
    if [ "$ENVIRONMENT" == "mingw" ]
    then
        cd /usr/local
        #wget -N http://ffmpeg-builder.googlecode.com/files/pkg-config-lite-0.28-1.tar.bz2
        tar -xjvf $PKG_DIR/pkg-config-lite-*.tar.*
        mkdir -p /usr/local
        cp -r pkg-config*/* /usr/local
        rm -r pkg-config*
        echo
    fi
}

function build_zlib {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-zlib" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/zlib-1.2.8.tar.xz
            tar -xJvf $PKG_DIR/zlib*.tar.*
            cd zlib*
            ./configure --static
            make libz.a
            make install
            make clean
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/zlib-1.2.8.tar.xz
            tar -xJvf $PKG_DIR/zlib*.tar.*
            cd zlib*
            make -f win32/Makefile.gcc
            mkdir -p /usr/local/include
            cp zlib.h zconf.h /usr/local/include
            mkdir -p /usr/local/lib
            cp libz.a /usr/local/lib
        else
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/zlib-1.2.8.tar.xz
            tar -xJvf $PKG_DIR/zlib*.tar.*
            cd zlib*
            ./configure --static
            make libz.a
            make install
            make clean
        fi
    fi
}

function build_bzip2 {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-bzlib" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/bzip2-1.0.6.tar.gz
            tar -xzvf $PKG_DIR/bzip2*.tar.*
            cd bzip2*
            make
            make install
            make clean
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/bzip2-1.0.6.tar.gz
            tar -xzvf $PKG_DIR/bzip2*.tar.*
            cd bzip2*
            make
            mkdir -p /usr/local/include
            cp bzlib.h /usr/local/include
            mkdir -p /usr/local/lib
            cp libbz2.a /usr/local/lib
            make clean
        else
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/bzip2-1.0.6.tar.gz
            tar -xzvf $PKG_DIR/bzip2*.tar.*
            cd bzip2*
            make
            make install
            make clean
        fi
    fi
}

function build_expat {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/expat-2.1.0.tar.gz
            tar -xzvf $PKG_DIR/expat*.tar.*
            cd expat*
            ./configure $CONFIGURE_ALL_FLAGS
            make
            make install
            make clean

            pkg-config expat >/dev/null 2>&1
            # NOTE: when package config fails, export the lib dependencies to variables
            if [ $? != 0 ]
            then
                export EXPAT_CFLAGS="-I/usr/local/include"
                export EXPAT_LIBS="-L/usr/local/lib -lexpat"
            fi
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/expat-2.1.0.tar.gz
            tar -xzvf $PKG_DIR/expat*.tar.*
            cd expat*
            ./configure $CONFIGURE_ALL_FLAGS
            make
            make install
            make clean

            pkg-config expat >/dev/null 2>&1
            # NOTE: when package config fails, export the lib dependencies to variables
            if [ $? != 0 ]
            then
                export EXPAT_CFLAGS="-I/usr/local/include"
                export EXPAT_LIBS="-L/usr/local/lib -lexpat"
            fi
        else
            echo ERROR
        fi
    fi
}

function build_xml2 {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libbluray" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/libxml2-2.9.0.tar.gz
            tar -xzvf $PKG_DIR/libxml2*.tar.*
            cd libxml2*
            ./configure $CONFIGURE_ALL_FLAGS --without-debug
            make
            make install
            make clean

            pkg-config libxml-2.0 >/dev/null 2>&1
            # NOTE: when package config fails, export the lib dependencies to variables
            if [ $? != 0 ]
            then
                export LIBXML2_CFLAGS="-I/usr/local/include/libxml2 -DLIBXML_STATIC"
                export LIBXML2_LIBS="-L/usr/local/lib -lxml2 -lz -lws2_32"
                export XML2_INCLUDEDIR="-I/usr/local/include/libxml2"
                export XML2_LIBDIR="-L/usr/local/lib"
                export XML2_LIBS="-lxml2 -lz -lws2_32"
            else
                # NOTE: modify libxml2.pc so it will return private libs even when called without --static
                sed -i -e "s|Libs:.*|Libs: $(pkg-config --libs --static libxml-2.0)|g" $PKG_CONFIG_PATH/libxml-2.0.pc
            fi
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/libxml2-2.9.0.tar.gz
            tar -xzvf $PKG_DIR/libxml2*.tar.*
            cd libxml2*
            ./configure $CONFIGURE_ALL_FLAGS --without-debug
            make
            make install
            make clean

            pkg-config libxml-2.0 >/dev/null 2>&1
            # NOTE: when package config fails, export the lib dependencies to variables
            if [ $? != 0 ]
            then
                export LIBXML2_CFLAGS="-I/usr/local/include/libxml2 -DLIBXML_STATIC"
                export LIBXML2_LIBS="-L/usr/local/lib -lxml2 -lz -lws2_32"
                export XML2_INCLUDEDIR="-I/usr/local/include/libxml2"
                export XML2_LIBDIR="-L/usr/local/lib"
                export XML2_LIBS="-lxml2 -lz -lws2_32"
            else
                # NOTE: modify libxml2.pc so it will return private libs even when called without --static
                sed -i -e "s|Libs:.*|Libs: $(pkg-config --libs --static libxml-2.0)|g" $PKG_CONFIG_PATH/libxml-2.0.pc
            fi
        else
            echo ERROR
        fi
    fi
}

function build_freetype {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libfreetype" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/freetype-2.4.11.tar.bz2
            tar -xjvf $PKG_DIR/freetype*.tar.*
            cd freetype*
            ./configure $CONFIGURE_ALL_FLAGS
            make
            make install
            make clean

            pkg-config freetype2 >/dev/null 2>&1
            # NOTE: when package config fails, export the lib dependencies to variables
            if [ $? != 0 ]
            then
                export FREETYPE_CFLAGS="-I/usr/local/include -I/usr/local/include/freetype2"
                export FREETYPE_LIBS="-L/usr/local/lib -lfreetype -lz"
            else
                # NOTE: modify lfreetype.pc so it will return private libs even when called without --static
                sed -i -e "s|Libs:.*|Libs: $(pkg-config --libs --static freetype2)|g" $PKG_CONFIG_PATH/freetype2.pc
            fi
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/freetype-2.4.11.tar.bz2
            tar -xjvf $PKG_DIR/freetype*.tar.*
            cd freetype*
            ./configure $CONFIGURE_ALL_FLAGS
            make
            make install
            make clean

            pkg-config freetype2 >/dev/null 2>&1
            # NOTE: when package config fails, export the lib dependencies to variables
            if [ $? != 0 ]
            then
                export FREETYPE_CFLAGS="-I/usr/local/include -I/usr/local/include/freetype2"
                export FREETYPE_LIBS="-L/usr/local/lib -lfreetype -lz"
            else
                # NOTE: modify lfreetype.pc so it will return private libs even when called without --static
                sed -i -e "s|Libs:.*|Libs: $(pkg-config --libs --static freetype2)|g" $PKG_CONFIG_PATH/freetype2.pc
            fi
        else
            echo ERROR
        fi
    fi
}

function build_fribidi {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/fribidi-0.19.5.tar.bz2
            tar -xjvf $PKG_DIR/fribidi*.tar.*
            cd fribidi*
            # fix for static build
            #sed -i -e  's/__declspec(dllimport)//g' lib/fribidi-common.h
            ./configure $CONFIGURE_ALL_FLAGS --disable-debug
            make -C charset
            # fixing lib/Makefile directly before make -C lib, or it will be overwritten by another configure process
            sed -i -e  's/am__append_1 =/#am__append_1 =/g' lib/Makefile
            make -C lib
            make
            make install
            make clean

            pkg-config fribidi >/dev/null 2>&1
            if [ $? != 0 ]
            then
                export FRIBIDI_CFLAGS="-I/usr/local/include/fribidi"
                export FRIBIDI_LIBS="-L/usr/local/lib -lfribidi"
            fi
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/fribidi-0.19.5.tar.bz2
            tar -xjvf $PKG_DIR/fribidi*.tar.*
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
            make clean

            pkg-config fribidi >/dev/null 2>&1
            if [ $? != 0 ]
            then
                export FRIBIDI_CFLAGS="-I/usr/local/include/fribidi"
                export FRIBIDI_LIBS="-L/usr/local/lib -lfribidi"
            fi
        else
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/fribidi-0.19.5.tar.bz2
            tar -xjvf $PKG_DIR/fribidi*.tar.*
            cd fribidi*
            ./configure $CONFIGURE_ALL_FLAGS --disable-debug
            make
            make install
            make clean

            pkg-config fribidi >/dev/null 2>&1
            # NOTE: when package config fails, export the lib dependencies to variables
            if [ $? != 0 ]
            then
                export FRIBIDI_CFLAGS="-I/usr/local/include/fribidi"
                export FRIBIDI_LIBS="-L/usr/local/lib -lfribidi"
            fi
        fi
    fi
}

function build_fontconfig {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/fontconfig-2.10.92.tar.bz2
            tar -xjvf $PKG_DIR/fontconfig*.tar.*
            cd fontconfig*
            ./configure $CONFIGURE_ALL_FLAGS --disable-docs --enable-libxml2
            make
            make install
            make clean

            pkg-config fontconfig >/dev/null 2>&1
            # NOTE: when package config fails, export the lib dependencies to variables
            if [ $? != 0 ]
            then
                export FONTCONFIG_CFLAGS="-I/usr/local/include"
                export FONTCONFIG_LIBS="-L/usr/local/lib -lfontconfig $XML2_LIBS $FREETYPE_LIBS"
                # TODO: deceide if libxml or expat was used, and export corresponding lib dependencies...
                #export FONTCONFIG_LIBS="-L/usr/local/lib -lfontconfig -lexpat -lfreetype"
            else
                # NOTE: modify fontconfig.pc so it will return private libs even when called without --static
                sed -i -e "s|Libs:.*|Libs: $(pkg-config --libs --static fontconfig)|g" $PKG_CONFIG_PATH/fontconfig.pc
            fi
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            # TODO: important note about the font configuration directory in windows:
            # http://ffmpeg.zeranoe.com/forum/viewtopic.php?f=10&t=318&start=10
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/fontconfig-2.10.92.tar.bz2
            tar -xjvf $PKG_DIR/fontconfig*.tar.*
            cd fontconfig*
            ./configure $CONFIGURE_ALL_FLAGS --disable-docs --enable-libxml2
            make
            make install
            make clean

            pkg-config fontconfig >/dev/null 2>&1
            # NOTE: when package config fails, export the lib dependencies to variables
            if [ $? != 0 ]
            then
                export FONTCONFIG_CFLAGS="-I/usr/local/include"
                export FONTCONFIG_LIBS="-L/usr/local/lib -lfontconfig $XML2_LIBS $FREETYPE_LIBS"
                # TODO: deceide if libxml or expat was used, and export corresponding lib dependencies...
                #export FONTCONFIG_LIBS="-L/usr/local/lib -lfontconfig -lexpat -lfreetype"
            else
                # NOTE: modify fontconfig.pc so it will return private libs even when called without --static
                sed -i -e "s|Libs:.*|Libs: $(pkg-config --libs --static fontconfig)|g" $PKG_CONFIG_PATH/fontconfig.pc
            fi
        else
            echo ERROR
        fi
    fi
}

function build_ass {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        cd $SRC_DIR
        #wget -N http://ffmpeg-builder.googlecode.com/files/libass-0.10.1.tar.xz
        tar -xJvf $PKG_DIR/libass*.tar.*
        cd libass*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install
        make clean
    fi
}

function build_faac {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libfaac" ]]
    then
        cd $SRC_DIR
        #wget -N http://ffmpeg-builder.googlecode.com/files/faac-1.28.tar.bz2
        tar -xjvf $PKG_DIR/faac*.tar.*
        cd faac*
        ./configure $CONFIGURE_ALL_FLAGS --without-mp4v2
        make
        make install
        make clean
    fi
}

function build_fdkaac {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libfdk_aac" ]]
    then
        cd $SRC_DIR
        #wget -N http://ffmpeg-builder.googlecode.com/files/fdk-aac-0.1.2.tar.gz
        tar -xzvf $PKG_DIR/fdk-aac*
        cd fdk-aac*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install
        make clean
    fi
}

function build_lame {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libmp3lame" ]]
    then
        cd $SRC_DIR
        #wget -N http://ffmpeg-builder.googlecode.com/files/lame-3.99.5.tar.gz
        tar -xzvf $PKG_DIR/lame*.tar.*
        cd lame*
        ./configure $CONFIGURE_ALL_FLAGS --disable-frontend
        make
        make install
        make clean
    fi
}

function build_ogg {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libvorbis" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libtheora" ]]
    then
        cd $SRC_DIR
        #wget -N http://ffmpeg-builder.googlecode.com/files/libogg-1.3.1.tar.xz
        tar -xJvf $PKG_DIR/libogg*.tar.*
        cd libogg*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install
        make clean

        pkg-config ogg >/dev/null 2>&1
        # NOTE: when package config fails, export the lib dependencies to variables
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
        cd $SRC_DIR
        #wget -N http://ffmpeg-builder.googlecode.com/files/libvorbis-1.3.3.tar.xz
        tar -xJvf $PKG_DIR/libvorbis*.tar.*
        cd libvorbis*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install
        make clean

        pkg-config vorbis >/dev/null 2>&1
        # NOTE: when package config fails, export the lib dependencies to variables
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
        cd $SRC_DIR
        #wget -N http://ffmpeg-builder.googlecode.com/files/libtheora-1.1.1.tar.bz2
        tar -xjvf $PKG_DIR/libtheora*.tar.*
        cd libtheora*
        ./configure $CONFIGURE_ALL_FLAGS --disable-examples
        make
        make install
        make clean
    fi
}

function build_xvid {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libxvid" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/xvidcore-1.3.2.tar.bz2
            tar -xjvf $PKG_DIR/xvid*.tar.*
            cd xvid*/build/generic
            ./configure $CONFIGURE_ALL_FLAGS
            make
            make install
            make clean
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            cd $SRC_DIR
            #wget -N http://ffmpeg-builder.googlecode.com/files/xvidcore-1.3.2.tar.bz2
            tar -xjvf $PKG_DIR/xvid*.tar.*
            cd xvid*/build/generic
            ./configure $CONFIGURE_ALL_FLAGS
            sed -i -e 's/-mno-cygwin//g' platform.inc
            make
            make install
            make clean
            rm /usr/local/lib/xvidcore.dll
            ln -s /usr/local/lib/xvidcore.a /usr/local/lib/libxvidcore.a
        else
            echo ERROR
        fi
    fi
}

function build_vpx {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libvpx" ]]
    then
        cd $SRC_DIR
        #wget -N http://ffmpeg-builder.googlecode.com/files/libvpx-1.2.0.tar.bz2
        tar -xjvf $PKG_DIR/libvpx*.tar.*
        cd libvpx*
        # FIXME: dependency loop in mingw32
        ./configure $CONFIGURE_ALL_FLAGS --enable-runtime-cpu-detect --enable-vp8 --enable-postproc --disable-debug --disable-examples --disable-install-bins --disable-docs --disable-unit-tests
        make
        make install
        make clean
    fi
}

function build_x264 {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libx264" ]]
    then
        cd $SRC_DIR
        #wget -N http://ffmpeg-builder.googlecode.com/files/x264-0.136.tar.bz2
        tar -xjvf $PKG_DIR/x264*.tar.*
        cd x264-snapshot*
        # NOTE: x264 threads must be same regarding to ffmpeg
        # i.e.
        # when ffmpeg is compiled with --enable-w32threads [default on mingw]
        # then x264 also needs to be compiled with --enable-win32thread
        if [ "$ENVIRONMENT" == "mingw" ]
        then
            if [ "$BITDEPTH" == "10" ]
            then
                ./configure $CONFIGURE_ALL_FLAGS --bit-depth=10 --enable-strip --disable-cli --enable-win32thread
            else
                ./configure $CONFIGURE_ALL_FLAGS --enable-strip --disable-cli --enable-win32thread
            fi
        else
            if [ "$BITDEPTH" == "10" ]
            then
                ./configure $CONFIGURE_ALL_FLAGS --bit-depth=10 --enable-strip --disable-cli
            else
                ./configure $CONFIGURE_ALL_FLAGS --enable-strip --disable-cli
            fi
        fi
        make
        make install
        make clean
    fi
}

function build_bluray {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libbluray" ]]
    then
        cd $SRC_DIR
        #wget -N http://ffmpeg-builder.googlecode.com/files/libbluray-0.2.3.tar.bz2
        tar -xjvf $PKG_DIR/libbluray*.tar.*
        cd libbluray*
        ./configure $CONFIGURE_ALL_FLAGS --disable-examples --disable-debug --disable-doxygen-doc --disable-doxygen-dot # --disable-libxml2
        make
        make install
        make clean
        # NOTE: libbluray depends on "-lxml2 -ldl" so we need to link ffmpeg against those libs
        CONFIGURE_FFMPEG_LIBS="$CONFIGURE_FFMPEG_LIBS -lxml2 -ldl"
    fi
}

function build_ffmpeg {
    cd $SRC_DIR
    #wget -N http://ffmpeg-builder.googlecode.com/files/ffmpeg-2.1.tar.bz2
    tar -xjvf $PKG_DIR/ffmpeg*.tar.*
    cd ffmpeg*
    if [ "$ENVIRONMENT" == "deb" ]
    then
        ./configure $CONFIGURE_ALL_FLAGS $CONFIGURE_FFMPEG_CODEC_FLAGS $CONFIGURE_FFMPEG_FLAGS --extra-libs="$CONFIGURE_FFMPEG_LIBS"
    elif [ "$ENVIRONMENT" == "mingw" ]
    then
        ./configure $CONFIGURE_ALL_FLAGS $CONFIGURE_FFMPEG_CODEC_FLAGS $CONFIGURE_FFMPEG_FLAGS --enable-w32threads --cpu=i686 --extra-libs="$CONFIGURE_FFMPEG_LIBS"
    else
        echo ERROR
    fi
    make
    make install
    make clean
}

function build_all {

    #mkdir -p $PKG_DIR
    mkdir -p $SRC_DIR
    mkdir -p $BIN_DIR

    build_yasm
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
    build_bluray

    BITDEPTH=10
    build_x264
    build_ffmpeg
    if [ "$ENVIRONMENT" == "deb" ]
    then
        mv -f /usr/local/bin/ffmpeg $BIN_DIR/ffmpeg-hi10-heaac
    elif [ "$ENVIRONMENT" == "mingw" ]
    then
        mv -f /usr/local/bin/ffmpeg.exe $BIN_DIR/ffmpeg-hi10-heaac.exe
    else
        echo "ERROR"
    fi

    cd $SRC_DIR
    rm -r -f x264* ffmpeg*

    BITDEPTH=8
    build_x264
    build_ffmpeg
    if [ "$ENVIRONMENT" == "deb" ]
    then
        mv -f /usr/local/bin/ffmpeg $BIN_DIR/ffmpeg-hi8-heaac
    elif [ "$ENVIRONMENT" == "mingw" ]
    then
        mv -f /usr/local/bin/ffmpeg.exe $BIN_DIR/ffmpeg-hi8-heaac.exe
    else
        echo "ERROR"
    fi

}

function build_deb {

    if [ "$ENVIRONMENT" == "deb" ]
    then
        DEBPKG=$(dirname $0)/$PKGNAME\_$PKGVERSION\_$(dpkg --print-architecture)_$(cat /etc/*release | grep DISTRIB_ID | cut -d '=' -f 2 | tr '[:upper:]' '[:lower:]')-$(cat /etc/*release | grep DISTRIB_RELEASE | cut -d '=' -f 2).deb
        mkdir -p $DEB_DIR/DEBIAN

        md5sum $(find $BIN_DIR -type f) | sed "s|$BIN_DIR|usr/bin|g" > $DEB_DIR/DEBIAN/md5sums
        echo "Package: $PKGNAME" > $DEB_DIR/DEBIAN/control
        echo "Version: $PKGVERSION" >> $DEB_DIR/DEBIAN/control
        echo "Section: $PKGSECTION" >> $DEB_DIR/DEBIAN/control
        echo "Architecture: $(dpkg --print-architecture)" >> $DEB_DIR/DEBIAN/control
        echo "Installed-Size: $(du -k -c $BIN_DIR | grep 'total' | sed -e 's|\s*total||g')" >> $DEB_DIR/DEBIAN/control
        # TODO: resolve dependencies...
        echo "Depends: $PKGDEPENDS" >> $DEB_DIR/DEBIAN/control
        echo "Maintainer: $PKGAUTHOR" >> $DEB_DIR/DEBIAN/control
        echo "Priority: optional" >> $DEB_DIR/DEBIAN/control
        echo "Homepage: $PKGHOMEPAGE" >> $DEB_DIR/DEBIAN/control
        echo "Description: $PKGDESCRIPTION" >> $DEB_DIR/DEBIAN/control

        #echo "#!/bin/sh" > $DEB_DIR/DEBIAN/postinst
        #echo "" >> $DEB_DIR/DEBIAN/postinst
        #echo "if [ -x /usr/bin/update-menus ] ; then update-menus ; fi" >> $DEB_DIR/DEBIAN/postinst
        #echo "if [ -x /usr/bin/update-mime ] ; then update-mime ; fi" >> $DEB_DIR/DEBIAN/postinst
        #chmod 0755 $DEB_DIR/DEBIAN/postinst

        #echo "#!/bin/sh" > $DEB_DIR/DEBIAN/postrm
        #echo "" >> $DEB_DIR/DEBIAN/postrm
        #echo "if [ -x /usr/bin/update-menus ] ; then update-menus ; fi" >> $DEB_DIR/DEBIAN/postrm
        #echo "if [ -x /usr/bin/update-mime ] ; then update-mime ; fi" >> $DEB_DIR/DEBIAN/postrm
        #chmod 0755 $DEB_DIR/DEBIAN/postrm

        rm -f $DEBPKG
        dpkg-deb -v -b $DEB_DIR $DEBPKG
        rm -f -r $DEB_DIR/DEBIAN
        lintian --profile debian $DEBPKG
    fi

}

function build_clean {

    if [ "$ENVIRONMENT" == "deb" ]
    then
        rm -r -f $BIN_DIR/*
    fi

    #remove sources
    rm -r -f $SRC_DIR/*

    # remove binaries
    rm -f /usr/local/bin/*asm* /usr/local/bin/bunzip2 /usr/local/bin/bz* /usr/local/bin/fc-* /usr/local/bin/freetype* /usr/local/bin/xml* /usr/local/bin/faac /usr/local/bin/fribidi /usr/local/bin/ff*

    #remove includes
    rm -r -f /usr/local/include/ass /usr/local/include/libbluray /usr/local/include/fdk-aac /usr/local/include/libswscale /usr/local/include/vorbis /usr/local/include/libavutil /usr/local/include/libavfilter /usr/local/include/lame /usr/local/include/ogg /usr/local/include/libxml2 /usr/local/include/vpx /usr/local/include/freetype2 /usr/local/include/fontconfig /usr/local/include/fribidi /usr/local/include/libpostproc /usr/local/include/theora /usr/local/include/libavcodec /usr/local/include/libavformat /usr/local/include/libyasm /usr/local/include/libavdevice /usr/local/include/libswresample
    rm -f /usr/local/include/expat.h /usr/local/include/bzlib.h /usr/local/include/faaccfg.h /usr/local/include/ft2build.h /usr/local/include/zconf.h /usr/local/include/xvid.h /usr/local/include/libyasm.h /usr/local/include/zlib.h /usr/local/include/expat_external.h /usr/local/include/x264_config.h /usr/local/include/libyasm-stdint.h /usr/local/include/faac.h /usr/local/include/x264.h

    # remove libraries
    rm -f /usr/local/lib/pkgconfig/fribidi.pc /usr/local/lib/pkgconfig/libavfilter.pc /usr/local/lib/pkgconfig/vpx.pc /usr/local/lib/pkgconfig/zlib.pc /usr/local/lib/pkgconfig/theoradec.pc /usr/local/lib/pkgconfig/theoraenc.pc /usr/local/lib/pkgconfig/theora.pc /usr/local/lib/pkgconfig/libbluray.pc /usr/local/lib/pkgconfig/ogg.pc /usr/local/lib/pkgconfig/vorbisenc.pc /usr/local/lib/pkgconfig/libavcodec.pc /usr/local/lib/pkgconfig/libpostproc.pc /usr/local/lib/pkgconfig/expat.pc /usr/local/lib/pkgconfig/libswscale.pc /usr/local/lib/pkgconfig/libavdevice.pc /usr/local/lib/pkgconfig/fontconfig.pc /usr/local/lib/pkgconfig/fdk-aac.pc /usr/local/lib/pkgconfig/libavutil.pc /usr/local/lib/pkgconfig/freetype2.pc /usr/local/lib/pkgconfig/libavformat.pc /usr/local/lib/pkgconfig/vorbisfile.pc /usr/local/lib/pkgconfig/x264.pc /usr/local/lib/pkgconfig/libass.pc /usr/local/lib/pkgconfig/vorbis.pc /usr/local/lib/pkgconfig/libswresample.pc /usr/local/lib/pkgconfig/libxml-2.0.pc
    rm -f /usr/local/lib/libyasm.a /usr/local/lib/libz.a /usr/local/lib/libtheoraenc.a /usr/local/lib/libfdk-aac.la /usr/local/lib/libogg.a /usr/local/lib/libtheoradec.la /usr/local/lib/libavfilter.a /usr/local/lib/libmp3lame.a /usr/local/lib/libtheoradec.a /usr/local/lib/libfaac.a /usr/local/lib/libvorbisenc.a /usr/local/lib/libvorbis.a /usr/local/lib/libogg.la /usr/local/lib/libavdevice.a /usr/local/lib/libfdk-aac.a /usr/local/lib/libxvidcore.so.4 /usr/local/lib/libfribidi.a /usr/local/lib/libvpx.a /usr/local/lib/libfreetype.a /usr/local/lib/libvorbis.la /usr/local/lib/libvorbisfile.a /usr/local/lib/libx264.a /usr/local/lib/libavformat.a /usr/local/lib/libtheoraenc.la /usr/local/lib/libbluray.la /usr/local/lib/libfontconfig.la /usr/local/lib/libswresample.a /usr/local/lib/libfreetype.la /usr/local/lib/libxml2.a /usr/local/lib/libfaac.la /usr/local/lib/libfribidi.la /usr/local/lib/libxml2.la /usr/local/lib/libpostproc.a /usr/local/lib/libxvidcore.so.4.3 /usr/local/lib/libbluray.a /usr/local/lib/libexpat.a /usr/local/lib/libxvidcore.a /usr/local/lib/libavutil.a /usr/local/lib/libexpat.la /usr/local/lib/libbz2.a /usr/local/lib/libtheora.la /usr/local/lib/libass.a /usr/local/lib/libvorbisfile.la /usr/local/lib/libvorbisenc.la /usr/local/lib/libfontconfig.a /usr/local/lib/libswscale.a /usr/local/lib/xml2Conf.sh /usr/local/lib/libtheora.a /usr/local/lib/libass.la /usr/local/lib/libmp3lame.la /usr/local/lib/libavcodec.a

}

read -p "
Please select your environment:

    [deb]   for Debian/Ubuntu/Mint
    [mingw] for windows MinGW/MSYS

Environment [deb]: " ENVIRONMENT

if [ ! $ENVIRONMENT ]
then
    ENVIRONMENT="deb"
fi

if [ "$ENVIRONMENT" == "deb" ]
then
    remove_dev_debs
fi

build_all
build_deb
build_clean
