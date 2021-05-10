#!/bin/bash

function yum_packages {
  yum update
  yum install -y make
  yum install -y python3
  yum install -y tar
  yum install -y gzip
  yum install -y which
}

function build_all {
  yum_packages
}

build_all
