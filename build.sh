#!/bin/bash

# pkg configuration

PKGNAME="ffmpeg-hi"
PKGVERSION="2.8.7"
PKGSECTION="video"
PKGAUTHOR="Ronny Wegener <wegener.ronny@gmail.com>"
PKGHOMEPAGE="http://ffmpeg-hi.sourceforge.net"
PKGDEPENDS=""
PKGDESCRIPTION="Multimedia encoder
 Customized ffmpeg build for use with FFmpegYAG.
 Statically linked to reduce dependencies.
 Supports 8 and 10 bit encoding with x264.
 Supports HE-AAC profiles with fdkaac."

# environment variables

export PATH="/usr/local/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
export CFLAGS="-g -O2 -I/usr/local/include"
export LDFLAGS="-s -L/usr/local/lib"

# local variables

cd $(dirname $0)

CWD=$(pwd)
PKG_DIR=$CWD/archive
SRC_DIR=$CWD/src
DIST_DIR=$CWD/build
BIN_DIR=$DIST_DIR/usr/bin
CONFIGURE_ALL_FLAGS="--enable-static --disable-shared"
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
--enable-libx265 \
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

function check_app {
    echo "CHECK: $1"
    $1 --version > /dev/null 2>&1
    if [ $? != 0 ]
    then
        echo "ERROR: $1 is missing"
        exit
    fi
}

function check_environment {
    check_app tar
    #check_app bzip2
    check_app xz
    check_app make
    check_app cmake
    #check_app ld
    check_app gcc
    check_app perl
    check_app python
}

function init_environment {
    #mkdir -p $PKG_DIR
    mkdir -p $SRC_DIR
    mkdir -p $BIN_DIR

    apt-get --version > /dev/null 2>&1
    if [ $? == 0 ]
    then
        ENVIRONMENT="deb"
    fi
    yum --version > /dev/null 2>&1
    if [ $? = 0 ]
    then
        ENVIRONMENT="fedora"
    fi
    zypper --version > /dev/null 2>&1
    if [ $? = 0 ]
    then
        ENVIRONMENT="opensuse"
    fi
    if [ "$(uname -o)" = "Msys" ]
    then
        ENVIRONMENT="mingw"
        set -e
    else
        set -e
    fi

    check_environment
}

get_lsb_release()
{
    # FIXME: Fedora/OpenSuse/CentOS/Redhat do not use lsb-release, they use e.g. fedora-release

    RELEASE_FILE=/dev/null
    if [ -f /etc/os-release ]
    then
        RELEASE_FILE=/etc/os-release
    fi
    if [ -f /etc/lsb-release ]
    then
        RELEASE_FILE=/etc/lsb-release
    fi
    if [ -f /etc/upstream-release/os-release ]
    then
        RELEASE_FILE=/etc/upstream-release/os-release
    fi
    if [ -f /etc/upstream-release/lsb-release ]
    then
        RELEASE_FILE=/etc/upstream-release/lsb-release
    fi
    DIST=linux
    VER=$(date +%y.%m)
    if [[ $(grep '^ID=' $RELEASE_FILE | wc -l) > 1 ]]
    then
        DIST=$(grep '^ID=' $RELEASE_FILE | sed 's|\"||g;s|\s|-|g' | cut -d '=' -f 2 | tr '[:upper:]' '[:lower:]')
        DIST=$(grep '^VERSION_ID=' $RELEASE_FILE | sed 's|\"||g' | cut -d '=' -f 2)
    fi
    if [[ $(grep '^DISTRIB_' $RELEASE_FILE | wc -l) > 1 ]]
    then
        DIST=$(grep '^DISTRIB_ID=' $RELEASE_FILE | sed 's|\"||g;s|\s|-|g' | cut -d '=' -f 2 | tr '[:upper:]' '[:lower:]')
        VER=$(grep '^DISTRIB_RELEASE=' $RELEASE_FILE | sed 's|\"||g' | cut -d '=' -f 2)
    fi
    ARCH=x86
    rpm --version > /dev/null 2>&1
    if [ $? == 0 ]
    then
        ARCH=$(rpm --eval %_target_cpu)
    fi
    apt-get --version > /dev/null 2>&1
    if [ $? == 0 ]
    then
        ARCH=$(dpkg --print-architecture)
    fi
    echo "${DIST}-${VER}_${ARCH}"
}

function build_zlib {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-zlib" ]]
    then
    cd $SRC_DIR
    tar -xJvf $PKG_DIR/zlib*.tar.*
    cd zlib*
    ./configure --static
    make libz.a
    make install
    #make clean
    pkg-config zlib >/dev/null 2>&1
        # NOTE: when package config fails, export the lib dependencies to variables
        if [ $? != 0 ]
        then
            export ZLIB_CFLAGS="-I/usr/local/include"
            export ZLIB_LIBS="-L/usr/local/lib -lz"
        fi
        cd $SRC_DIR
        rm -r -f zlib*
    fi
}

function build_bzip2 {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-bzlib" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ] || [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
        then
            cd $SRC_DIR
            tar -xzvf $PKG_DIR/bzip2*.tar.*
            cd bzip2*
            make
            make install
            #make clean
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            cd $SRC_DIR
            tar -xzvf $PKG_DIR/bzip2*.tar.*
            cd bzip2*
            make libbz2.a
            mkdir -p /usr/local/include
            cp bzlib.h /usr/local/include
            mkdir -p /usr/local/lib
            cp libbz2.a /usr/local/lib
            #make clean
        else
            echo "ERROR"
            exit
        fi
        cd $SRC_DIR
        rm -r -f bzip2*
    fi
}

function build_expat {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ] || [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
        then
            cd $SRC_DIR
            tar -xzvf $PKG_DIR/expat*.tar.*
            cd expat*
            ./configure $CONFIGURE_ALL_FLAGS
            make
            make install
            #make clean

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
            tar -xzvf $PKG_DIR/expat*.tar.*
            cd expat*
            ./configure $CONFIGURE_ALL_FLAGS --build=$(arch)-pc-mingw32
            make
            make install
            #make clean

        pkg-config expat >/dev/null 2>&1
            # NOTE: when package config fails, export the lib dependencies to variables
            if [ $? != 0 ]
            then
                export EXPAT_CFLAGS="-I/usr/local/include"
                export EXPAT_LIBS="-L/usr/local/lib -lexpat"
            fi
        else
            echo "ERROR"
            exit
        fi
        cd $SRC_DIR
        rm -r -f expat*
    fi
}

function build_xml2 {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libbluray" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ] || [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
        then
            cd $SRC_DIR
            tar -xzvf $PKG_DIR/libxml2*.tar.*
            cd libxml2*
            ./configure $CONFIGURE_ALL_FLAGS --without-debug --without-python
            make
            make install-strip
            #make clean

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
            tar -xzvf $PKG_DIR/libxml2*.tar.*
            cd libxml2*
            ./configure $CONFIGURE_ALL_FLAGS --build=$(gcc -dumpmachine) --with-zlib=/usr/local --without-debug --without-python
            make
            make install-strip
            #make clean

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
            echo "ERROR"
            exit
        fi
        cd $SRC_DIR
        rm -r -f libxml2*
    fi
}

function build_freetype {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libfreetype" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ] || [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
        then
            cd $SRC_DIR
            tar -xjvf $PKG_DIR/freetype*.tar.*
            cd freetype*
            ./configure $CONFIGURE_ALL_FLAGS
            make
            make install
            #make clean

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
            tar -xjvf $PKG_DIR/freetype*.tar.*
            cd freetype*
            ./configure $CONFIGURE_ALL_FLAGS
            make
            make install
            #make clean

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
            echo "ERROR"
            exit
        fi
        cd $SRC_DIR
        rm -r -f freetype*
    fi
}

function build_fribidi {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ] || [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
        then
            cd $SRC_DIR
            tar -xjvf $PKG_DIR/fribidi*.tar.*
            cd fribidi*
            ./configure $CONFIGURE_ALL_FLAGS --disable-debug
            make -C charset
            # fixing lib/Makefile directly before make -C lib, or it will be overwritten by another configure process
            sed -i -e 's/am__append_1 =/#am__append_1 =/g' lib/Makefile
            make -C lib
            make
            make install
            #make clean

            pkg-config fribidi >/dev/null 2>&1
            if [ $? != 0 ]
            then
                export FRIBIDI_CFLAGS="-I/usr/local/include/fribidi"
                export FRIBIDI_LIBS="-L/usr/local/lib -lfribidi"
            fi
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            cd $SRC_DIR
            tar -xjvf $PKG_DIR/fribidi*.tar.*
            cd fribidi*
            # fix for static build
            sed -i -e 's/__declspec(dllimport)//g' lib/fribidi-common.h
            ./configure $CONFIGURE_ALL_FLAGS --disable-debug
            make -C charset
            # fixing lib/Makefile directly before make -C lib, or it will be overwritten by another configure process
            sed -i -e 's/am__append_1 =/#am__append_1 =/g' lib/Makefile
            make -C lib
            make
            make install
            #make clean

            pkg-config fribidi >/dev/null 2>&1
            if [ $? != 0 ]
            then
                export FRIBIDI_CFLAGS="-I/usr/local/include/fribidi"
                export FRIBIDI_LIBS="-L/usr/local/lib -lfribidi"
            fi
        else
            echo "ERROR"
            exit
        fi
        cd $SRC_DIR
        rm -r -f fribidi*
    fi
}

function build_fontconfig {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-fontconfig" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ] || [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
        then
            cd $SRC_DIR
            tar -xjvf $PKG_DIR/fontconfig*.tar.*
            cd fontconfig*
            ./configure $CONFIGURE_ALL_FLAGS --disable-docs --enable-libxml2
            make
            make install
            #make clean

            pkg-config fontconfig >/dev/null 2>&1
            # NOTE: when package config fails, export the lib dependencies to variables
            if [ $? != 0 ]
            then
                export FONTCONFIG_CFLAGS="-I/usr/local/include"
                export FONTCONFIG_LIBS="-L/usr/local/lib -lfontconfig $XML2_LIBS $FREETYPE_LIBS"
                # TODO: deceide if libxml or expat was used, and export corresponding lib dependencies...
                #export FONTCONFIG_LIBS="-L/usr/local/lib -lfontconfig -lexpat -lfreetype"
            else
                cp -f fontconfig.pc $PKG_CONFIG_PATH/fontconfig.pc
                # NOTE: modify fontconfig.pc so it will return private libs even when called without --static
                sed -i -e "s|Libs:.*|Libs: $(pkg-config --libs --static fontconfig)|g" $PKG_CONFIG_PATH/fontconfig.pc
            fi
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            # TODO: important note about the font configuration directory in windows:
            # http://ffmpeg.zeranoe.com/forum/viewtopic.php?f=10&t=318&start=10
            cd $SRC_DIR
            tar -xjvf $PKG_DIR/fontconfig*.tar.*
            cd fontconfig*
            ./configure $CONFIGURE_ALL_FLAGS --disable-docs --enable-libxml2
            make
            make install
            #make clean

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
            echo "ERROR"
            exit
        fi
        cd $SRC_DIR
        rm -r -f fontconfig*
    fi
}

function build_harfbuzz {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        cd $SRC_DIR
        tar -xjvf $PKG_DIR/harfbuzz*.tar.*
        cd harfbuzz*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install
        #make clean

        pkg-config harfbuzz >/dev/null 2>&1
        # NOTE: when package config fails, export the lib dependencies to variables
        if [ $? != 0 ]
        then
            export HARFBUZZ_CFLAGS="-I/usr/local/include"
            export HARFBUZZ_LIBS="-L/usr/local/lib -lharfbuzz -lm"
        fi
        cd $SRC_DIR
        rm -r -f harfbuzz*
    fi
}

function build_iconv {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        cd $SRC_DIR
        tar -xzvf $PKG_DIR/libiconv*.tar.*
        cd libiconv*
        # derivative fix for disabling gets error when glibc is undefined (http://www.itkb.ro/kb/linux/patch-libiconv-pentru-glibc-216)
        sed -i -e 's/_GL_WARN_ON_USE (gets,.*//g' srclib/stdio.in.h
        if [ "$ENVIRONMENT" == "mingw" ]
        then
            ./configure $CONFIGURE_ALL_FLAGS --build=$(arch)-pc-mingw32
        else
            ./configure $CONFIGURE_ALL_FLAGS
        fi
        make
        make install
        #make clean
        cd $SRC_DIR
        rm -r -f libiconv*
    fi
}

function build_ass {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libass" ]]
    then
        cd $SRC_DIR
        tar -xJvf $PKG_DIR/libass*.tar.*
        cd libass*
        ./configure $CONFIGURE_ALL_FLAGS --disable-asm --disable-harfbuzz
        make
        make install
        #make clean
        cd $SRC_DIR
        rm -r -f libass*
    fi
}

function build_faac {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libfaac" ]]
    then
        cd $SRC_DIR
        tar -xjvf $PKG_DIR/faac*.tar.*
        cd faac*
        if [ "$ENVIRONMENT" == "mingw" ]
        then
            ./configure $CONFIGURE_ALL_FLAGS --build=$(arch)-pc-mingw32 --without-mp4v2
        else
            ./configure $CONFIGURE_ALL_FLAGS --without-mp4v2
        fi
        make
        make install
        #make clean
        cd $SRC_DIR
        rm -r -f faac*
    fi
}

function build_fdkaac {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libfdk_aac" ]]
    then
        cd $SRC_DIR
        tar -xzvf $PKG_DIR/fdk-aac*
        cd fdk-aac*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install
        #make clean
        cd $SRC_DIR
        rm -r -f fdk-aac*
    fi
}

function build_lame {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libmp3lame" ]]
    then
        cd $SRC_DIR
        tar -xzvf $PKG_DIR/lame*.tar.*
        cd lame*
        if [ "$ENVIRONMENT" == "mingw" ]
        then
            ./configure $CONFIGURE_ALL_FLAGS --build=$(arch)-pc-mingw32 --disable-frontend
            make "CFLAGS=-msse"
        else
            ./configure $CONFIGURE_ALL_FLAGS --disable-frontend
            make
        fi
        make install
        #make clean
        cd $SRC_DIR
        rm -r -f lame*
    fi
}

function build_ogg {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libvorbis" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libtheora" ]]
    then
        cd $SRC_DIR
        tar -xJvf $PKG_DIR/libogg*.tar.*
        cd libogg*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install
        #make clean

        pkg-config ogg >/dev/null 2>&1
        # NOTE: when package config fails, export the lib dependencies to variables
        if [ $? != 0 ]
        then
            export OGG_CFLAGS="-I/usr/local/include"
            export OGG_LIBS="-L/usr/local/lib -logg"
        fi
        cd $SRC_DIR
        rm -r -f libogg*
    fi
}

function build_vorbis {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libvorbis" || "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libtheora" ]]
    then
        cd $SRC_DIR
        tar -xJvf $PKG_DIR/libvorbis*.tar.*
        cd libvorbis*
        ./configure $CONFIGURE_ALL_FLAGS
        make
        make install
        #make clean

        pkg-config vorbis >/dev/null 2>&1
        # NOTE: when package config fails, export the lib dependencies to variables
        if [ $? != 0 ]
        then
            export VORBIS_CFLAGS="-I/usr/local/include"
            export VORBIS_LIBS="-L/usr/local/lib -lvorbis -lm"
        fi
        cd $SRC_DIR
        rm -r -f libvorbis*
    fi
}

function build_theora {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libtheora" ]]
    then
        cd $SRC_DIR
        tar -xjvf $PKG_DIR/libtheora*.tar.*
        cd libtheora*
        if [ "$ENVIRONMENT" == "mingw" ]
        then
            ./configure $CONFIGURE_ALL_FLAGS --build=$(arch)-pc-mingw32 --disable-examples
        else
            ./configure $CONFIGURE_ALL_FLAGS --disable-examples
        fi
        make
        make install
        #make clean
        cd $SRC_DIR
        rm -r -f libtheora*
    fi
}

function build_xvid {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libxvid" ]]
    then
        if [ "$ENVIRONMENT" == "deb" ] || [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
        then
            cd $SRC_DIR
            tar -xjvf $PKG_DIR/xvid*.tar.*
            cd xvid*/build/generic
            ./configure $CONFIGURE_ALL_FLAGS
            make
            make install && :
            #make clean
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            cd $SRC_DIR
            tar -xjvf $PKG_DIR/xvid*.tar.*
            cd xvid*/build/generic
            ./configure $CONFIGURE_ALL_FLAGS --build=$(arch)-pc-mingw32
            #sed -i -e 's|-mno-cygwin||g' platform.inc
            make
            make install
            #make clean
            rm -f /usr/local/lib/xvidcore.dll
            ln -s -f /usr/local/lib/xvidcore.a /usr/local/lib/libxvidcore.a
        else
            echo "ERROR"
            exit
        fi
        cd $SRC_DIR
        rm -r -f xvid*
    fi
}

function build_vpx {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libvpx" ]]
    then
        cd $SRC_DIR
        tar -xzvf $PKG_DIR/libvpx*.tar.*
        cd libvpx*
        if [ "$ENVIRONMENT" == "mingw" ]
        then
            sed -i 's|which yasm.*AS=yasm|AS=yasm|g' ./build/make/configure.sh
            #if [ "$BITDEPTH" == "10" ]
            #then
            #    ./configure $CONFIGURE_ALL_FLAGS --target=$(arch | sed 's|i.86|x86|g')-win$(arch | sed 's|i.86|32|g;s|x86_64|64|g')-gcc --enable-runtime-cpu-detect --enable-vp8 --enable-vp9 --enable-webm-io --enable-postproc --disable-debug --disable-examples --disable-install-bins --disable-docs --disable-unit-tests --disable-dependency-tracking --enable-vp9-highbitdepth
        #else
                ./configure $CONFIGURE_ALL_FLAGS --target=$(arch | sed 's|i.86|x86|g')-win$(arch | sed 's|i.86|32|g;s|x86_64|64|g')-gcc --enable-runtime-cpu-detect --enable-vp8 --enable-vp9 --enable-webm-io --enable-postproc --disable-debug --disable-examples --disable-install-bins --disable-docs --disable-unit-tests --disable-dependency-tracking
        #fi
        else
            #if [ "$BITDEPTH" == "10" ]
            #then
            #    ./configure $CONFIGURE_ALL_FLAGS --target=$(gcc -dumpmachine | sed 's|gnu|gcc|g') --enable-runtime-cpu-detect --enable-vp8 --enable-vp9 --enable-webm-io --enable-postproc --disable-debug --disable-examples --disable-install-bins --disable-docs --disable-unit-tests --enable-vp9-highbitdepth
        #else
                ./configure $CONFIGURE_ALL_FLAGS --target=$(gcc -dumpmachine | sed 's|gnu|gcc|g') --enable-runtime-cpu-detect --enable-vp8 --enable-vp9 --enable-webm-io --enable-postproc --disable-debug --disable-examples --disable-install-bins --disable-docs --disable-unit-tests
        #fi
        fi
        make
        make install
        #make clean
        cd $SRC_DIR
        rm -r -f libvpx*
    fi
}

function build_x264 {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libx264" ]]
    then
        cd $SRC_DIR
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
                ./configure $CONFIGURE_ALL_FLAGS --bit-depth=10 --enable-strip --disable-cli --disable-opencl --disable-avs --disable-ffms --enable-win32thread
            else
                ./configure $CONFIGURE_ALL_FLAGS --enable-strip --disable-cli --disable-opencl --disable-avs --disable-ffms --enable-win32thread
            fi
        else
            if [ "$BITDEPTH" == "10" ]
            then
                ./configure $CONFIGURE_ALL_FLAGS --bit-depth=10 --enable-strip --disable-cli --disable-opencl --disable-avs --disable-ffms
            else
                ./configure $CONFIGURE_ALL_FLAGS --enable-strip --disable-cli --disable-opencl --disable-avs --disable-ffms
            fi
        fi
        make
        make install
        #make clean
    fi
}

function build_x265 {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libx265" ]]
    then
        cd $SRC_DIR
        tar -xzvf $PKG_DIR/x265*.tar.*
        cd x265*
        if [ "$ENVIRONMENT" == "deb" ] || [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
        then
            cd build/linux
            if [ "$BITDEPTH" == "10" ]
            then
                cmake -G "Unix Makefiles" -D "ENABLE_SHARED:BOOL=OFF" -D "ENABLE_CLI:BOOL=OFF" -D "HIGH_BIT_DEPTH:BOOL=ON" ../../source
            else
                cmake -G "Unix Makefiles" -D "ENABLE_SHARED:BOOL=OFF" -D "ENABLE_CLI:BOOL=OFF" -D "HIGH_BIT_DEPTH:BOOL=OFF" ../../source
            fi
            CONFIGURE_FFMPEG_LIBS="$CONFIGURE_FFMPEG_LIBS -L/usr/local/lib -lx265 -lstdc++ -lm -lrt"
        elif [ "$ENVIRONMENT" == "mingw" ]
        then
            cd build/msys
            # disable yasm, or build will fail (error in intrapred16.asm)
            mv -f /usr/local/bin/yasm.exe /usr/local/bin/_yasm.exe
            # native script (32bit target/32bit msys or 64bit target/64bit msys)
            if [ "$BITDEPTH" == "10" ]
            then
                cmake -G "MSYS Makefiles" -D "ENABLE_SHARED:BOOL=OFF" -D "ENABLE_CLI:BOOL=OFF" -D "HIGH_BIT_DEPTH:BOOL=ON" -D "CMAKE_INSTALL_PREFIX:PATH=/usr/local" ../../source
            else
                cmake -G "MSYS Makefiles" -D "ENABLE_SHARED:BOOL=OFF" -D "ENABLE_CLI:BOOL=OFF" -D "HIGH_BIT_DEPTH:BOOL=OFF" -D "CMAKE_INSTALL_PREFIX:PATH=/usr/local" ../../source
            fi
            # re-enable yasm
            mv -f /usr/local/bin/_yasm.exe /usr/local/bin/yasm.exe
            # TODO: check why pkg-config x265 is not working for ffmpeg (reason why we need to add lib manually)
            CONFIGURE_FFMPEG_LIBS="$CONFIGURE_FFMPEG_LIBS -L/usr/local/lib -lx265 -lstdc++"
        fi
        make
        make install
        #make clean
        cd $SRC_DIR
        rm -r -f x265*
    fi
}

function build_bluray {
    if [[ "$CONFIGURE_FFMPEG_CODEC_FLAGS" =~ "--enable-libbluray" ]]
    then
        cd $SRC_DIR
        tar -xjvf $PKG_DIR/libbluray*.tar.*
        cd libbluray*
        ./configure $CONFIGURE_ALL_FLAGS --disable-bdjava --disable-examples --disable-debug --disable-doxygen-doc --disable-doxygen-dot # --disable-libxml2
        make
        make install
        #make clean
        if [ "$ENVIRONMENT" != "mingw" ]
        then
            # NOTE: libbluray depends on "-lxml2 -ldl" so we need to link ffmpeg against those libs
            CONFIGURE_FFMPEG_LIBS="$CONFIGURE_FFMPEG_LIBS -lxml2 -ldl"
        fi
        cd $SRC_DIR
        rm -r -f libbluray*
    fi
}

function build_ffmpeg {
    cd $SRC_DIR
    tar -xjvf $PKG_DIR/ffmpeg*.tar.*
    cd ffmpeg*
    if [ "$ENVIRONMENT" == "deb" ] || [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
    then
        ./configure $(echo $CONFIGURE_ALL_FLAGS | cut -d' ' -f1 --complement) $CONFIGURE_FFMPEG_CODEC_FLAGS $CONFIGURE_FFMPEG_FLAGS --extra-libs="$CONFIGURE_FFMPEG_LIBS" --extra-cflags="-static" --extra-ldflags="-static"
    elif [ "$ENVIRONMENT" == "mingw" ]
    then
        ./configure $(echo $CONFIGURE_ALL_FLAGS | cut -d' ' -f1 --complement) $CONFIGURE_FFMPEG_CODEC_FLAGS $CONFIGURE_FFMPEG_FLAGS --enable-w32threads --cpu=$(gcc -dumpmachine | cut -d '-' -f 1) --extra-libs="$CONFIGURE_FFMPEG_LIBS" --extra-cflags="-static" --extra-ldflags="-static"
    else
        echo "ERROR"
        exit
    fi
    make
    make install
    #make clean
}

function build_all {
    build_zlib
    build_bzip2
    build_expat
    build_xml2
    build_freetype
    build_fribidi
    build_fontconfig
    #build_harfbuzz
    # TODO: add harfbuzz shaper to libass (--enable-harfbuzz)
    build_iconv
    build_ass
    build_faac
    build_fdkaac
    build_lame
    build_ogg
    build_vorbis
    build_theora
    build_xvid
    build_bluray

    BITDEPTH=10
    build_vpx
    build_x264
    build_x265
    build_ffmpeg
    if [ "$ENVIRONMENT" == "deb" ] || [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
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
    build_vpx
    build_x264
    build_x265
    build_ffmpeg
    if [ "$ENVIRONMENT" == "deb" ] || [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
    then
        mv -f /usr/local/bin/ffmpeg $BIN_DIR/ffmpeg-hi8-heaac
    elif [ "$ENVIRONMENT" == "mingw" ]
    then
        mv -f /usr/local/bin/ffmpeg.exe $BIN_DIR/ffmpeg-hi8-heaac.exe
    else
        echo "ERROR"
    fi
}

function build_pkg {

    cd $CWD
    if [ "$ENVIRONMENT" == "deb" ]
    then
        DEBPKG=$CWD/$PKGNAME\_$PKGVERSION\_$(get_lsb_release).deb
        mkdir -p $DIST_DIR/DEBIAN
        md5sum $(find $BIN_DIR -type f) | sed "s|$BIN_DIR|usr/bin|g" > $DIST_DIR/DEBIAN/md5sums
        echo "Package: $PKGNAME" > $DIST_DIR/DEBIAN/control
        echo "Version: $PKGVERSION" >> $DIST_DIR/DEBIAN/control
        echo "Section: $PKGSECTION" >> $DIST_DIR/DEBIAN/control
        echo "Architecture: $(dpkg --print-architecture)" >> $DIST_DIR/DEBIAN/control
        echo "Installed-Size: $(du -k -c $BIN_DIR | grep 'total' | sed -e 's|\s*total||g')" >> $DIST_DIR/DEBIAN/control
        echo "Depends: $PKGDEPENDS" >> $DIST_DIR/DEBIAN/control # TODO: resolve dependencies... (static build without any dependencies)
        echo "Maintainer: $PKGAUTHOR" >> $DIST_DIR/DEBIAN/control
        echo "Priority: optional" >> $DIST_DIR/DEBIAN/control
        echo "Homepage: $PKGHOMEPAGE" >> $DIST_DIR/DEBIAN/control
        echo "Description: $PKGDESCRIPTION" >> $DIST_DIR/DEBIAN/control
        rm -f $DEBPKG
        dpkg-deb -v -b $DIST_DIR $DEBPKG
        rm -r -f $DIST_DIR/DEBIAN
        lintian --profile debian $DEBPKG
    elif [ "$ENVIRONMENT" == "fedora" ] || [ "$ENVIRONMENT" == "opensuse" ]
    then
        RPMPKG=$CWD/$PKGNAME\_$PKGVERSION\_$(get_lsb_release).rpm
        mkdir -p $CWD/rpm/BUILDROOT 2> /dev/null
        mkdir -p $CWD/rpm/SPECS 2> /dev/null
        cp -r $DIST_DIR/* $CWD/rpm/BUILDROOT
        echo "Name: $PKGNAME" > $CWD/rpm/SPECS/specfile.spec
        echo "Version: $PKGVERSION" >> $CWD/rpm/SPECS/specfile.spec
        echo "Release: 0" >> $CWD/rpm/SPECS/specfile.spec
        echo "License: public domain" >> $CWD/rpm/SPECS/specfile.spec
        echo "URL: $PKGHOMEPAGE" >> $CWD/rpm/SPECS/specfile.spec
        #echo "Requires: libc" >> $CWD/rpm/SPECS/specfile.spec
        echo "Summary: Summary not available..." >> $CWD/rpm/SPECS/specfile.spec
        echo "" >> $CWD/rpm/SPECS/specfile.spec
        echo "%description" >> $CWD/rpm/SPECS/specfile.spec
        echo "Description not available..." >> $CWD/rpm/SPECS/specfile.spec
        echo "" >> $CWD/rpm/SPECS/specfile.spec
        echo "%files" >> $CWD/rpm/SPECS/specfile.spec
        find rpm/BUILDROOT -type f | sed 's|rpm/BUILDROOT||g' >> $CWD/rpm/SPECS/specfile.spec
        rpmbuild -bb --noclean --define "_topdir $CWD/rpm" --define "buildroot %{_topdir}/BUILDROOT" "$CWD/rpm/SPECS/specfile.spec"
        mv -f $CWD/rpm/RPMS/*/*.rpm $RPMPKG
        rm -r -f rpm
    elif [ "$ENVIRONMENT" == "mingw" ]
    then
        # TODO: create iss...
        ZIPPKG=$CWD/$PKGNAME\_$PKGVERSION\_windows-portable_$(gcc -dumpmachine | cut -d '-' -f 1).zip
        mkdir -p $CWD/$PKGNAME 2> /dev/null
        cp -r $BIN_DIR/* $CWD/$PKGNAME
        zip -r $ZIPPKG $CWD/$PKGNAME
        rm -r -f $CWD/$PKGNAME
    else
        echo "ERROR"
        exit
    fi
}

function build_clean {

    # remove build binaries
    rm -r -f $BIN_DIR/*

    #remove sources
    rm -r -f $SRC_DIR/*

    # TODO: in msys delete all content in /usr/local/* (e.g. cmake, doc, man, ...)

    # remove binaries
    rm -f /usr/local/bin/*asm* /usr/local/bin/bunzip2 /usr/local/bin/bz* /usr/local/bin/fc-* /usr/local/bin/freetype* /usr/local/bin/xml* /usr/local/bin/faac /usr/local/bin/fribidi /usr/local/bin/ff* /usr/local/bin/x26*

    #remove includes
    rm -r -f /usr/local/include/ass /usr/local/include/libbluray /usr/local/include/fdk-aac /usr/local/include/libswscale /usr/local/include/vorbis /usr/local/include/libavutil /usr/local/include/libavfilter /usr/local/include/lame /usr/local/include/ogg /usr/local/include/libxml2 /usr/local/include/vpx /usr/local/include/freetype2 /usr/local/include/fontconfig /usr/local/include/fribidi /usr/local/include/libpostproc /usr/local/include/theora /usr/local/include/libavcodec /usr/local/include/libavformat /usr/local/include/libyasm /usr/local/include/libavdevice /usr/local/include/libswresample /usr/local/include/harfbuzz
    rm -f /usr/local/include/expat.h /usr/local/include/bzlib.h /usr/local/include/faaccfg.h /usr/local/include/ft2build.h /usr/local/include/zconf.h /usr/local/include/xvid.h /usr/local/include/libyasm.h /usr/local/include/zlib.h /usr/local/include/expat_external.h /usr/local/include/libyasm-stdint.h /usr/local/include/faac.h /usr/local/include/x264*.h /usr/local/include/x265*.h

    # remove libraries
    rm -f /usr/local/lib/pkgconfig/fribidi.pc /usr/local/lib/pkgconfig/libavfilter.pc /usr/local/lib/pkgconfig/vpx.pc /usr/local/lib/pkgconfig/zlib.pc /usr/local/lib/pkgconfig/theoradec.pc /usr/local/lib/pkgconfig/theoraenc.pc /usr/local/lib/pkgconfig/theora.pc /usr/local/lib/pkgconfig/libbluray.pc /usr/local/lib/pkgconfig/ogg.pc /usr/local/lib/pkgconfig/vorbisenc.pc /usr/local/lib/pkgconfig/libavcodec.pc /usr/local/lib/pkgconfig/libpostproc.pc /usr/local/lib/pkgconfig/expat.pc /usr/local/lib/pkgconfig/libswscale.pc /usr/local/lib/pkgconfig/libavdevice.pc /usr/local/lib/pkgconfig/fontconfig.pc /usr/local/lib/pkgconfig/fdk-aac.pc /usr/local/lib/pkgconfig/libavutil.pc /usr/local/lib/pkgconfig/freetype2.pc /usr/local/lib/pkgconfig/libavformat.pc /usr/local/lib/pkgconfig/vorbisfile.pc /usr/local/lib/pkgconfig/x264.pc /usr/local/lib/pkgconfig/libass.pc /usr/local/lib/pkgconfig/vorbis.pc /usr/local/lib/pkgconfig/libswresample.pc /usr/local/lib/pkgconfig/libxml-2.0.pc /usr/local/lib/pkgconfig/harfbuzz.pc /usr/local/lib/pkgconfig/x265.pc /usr/local/lib/pkgconfig/cmake/libxml2
    rm -f /usr/local/lib/libyasm.a /usr/local/lib/libz.a /usr/local/lib/libtheoraenc.a /usr/local/lib/libfdk-aac.la /usr/local/lib/libogg.a /usr/local/lib/libtheoradec.la /usr/local/lib/libavfilter.a /usr/local/lib/libmp3lame.a /usr/local/lib/libtheoradec.a /usr/local/lib/libfaac.a /usr/local/lib/libvorbisenc.a /usr/local/lib/libvorbis.a /usr/local/lib/libogg.la /usr/local/lib/libavdevice.a /usr/local/lib/libfdk-aac.a /usr/local/lib/libxvidcore.so.4 /usr/local/lib/libfribidi.a /usr/local/lib/libvpx.a /usr/local/lib/libfreetype.a /usr/local/lib/libvorbis.la /usr/local/lib/libvorbisfile.a /usr/local/lib/libx264* /usr/local/lib/libx265* /usr/local/lib/libavformat.a /usr/local/lib/libtheoraenc.la /usr/local/lib/libbluray.la /usr/local/lib/libfontconfig.la /usr/local/lib/libswresample.a /usr/local/lib/libfreetype.la /usr/local/lib/libxml2.a /usr/local/lib/libfaac.la /usr/local/lib/libfribidi.la /usr/local/lib/libxml2.la /usr/local/lib/libpostproc.a /usr/local/lib/libxvidcore.so.4.3 /usr/local/lib/libbluray.a /usr/local/lib/libexpat.a /usr/local/lib/libxvidcore.a /usr/local/lib/libxvidcore.so /usr/local/lib/libavutil.a /usr/local/lib/libexpat.la /usr/local/lib/libbz2.a /usr/local/lib/libtheora.la /usr/local/lib/libass.a /usr/local/lib/libvorbisfile.la /usr/local/lib/libvorbisenc.la /usr/local/lib/libfontconfig.a /usr/local/lib/libswscale.a /usr/local/lib/xml2Conf.sh /usr/local/lib/libtheora.a /usr/local/lib/libass.la /usr/local/lib/libmp3lame.la /usr/local/lib/libavcodec.a /usr/local/lib/libharfbuzz.a /usr/local/lib/libharfbuzz.la
}

init_environment
build_all
build_pkg
build_clean
