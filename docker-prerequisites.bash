#!/bin/bash

CWD=$(pwd)
PKG_DIR=$CWD/docker-archive
SRC_DIR=$CWD/src

function build_yasm {
  yum remove -y yasm
  cd $SRC_DIR
  tar -xvzf $PKG_DIR/yasm*.tar.*
  cd yasm*
  ./configure
  make
  make install
  cd $SRC_DIR
  rm -r -f yasm*
}

function build_all {
  yum update && yum install -y make python3
  build_yasm
}

build_all
