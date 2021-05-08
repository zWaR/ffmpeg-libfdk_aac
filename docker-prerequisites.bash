#!/bin/bash

CWD=$(pwd)
PKG_DIR=$CWD/docker-archive
SRC_DIR=$CWD/src

function yum_packages {
  yum update
  yum install -y make
  yum install -y python3
  yum install -y tar
  yum install -y gzip
}

function build_yasm {
  yum remove -y yasm
  cd $SRC_DIR
  tar -xvzf $PKG_DIR/yasm*.tar.*
  cd yasm*
  ./configure --prefix="/usr"
  make
  make install
  cd $SRC_DIR
  rm -r -f yasm*
}

function build_all {
  yum_packages
  build_yasm
}

build_all
