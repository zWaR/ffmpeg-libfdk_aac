#!/bin/bash

. /etc/os-release
if [[ ! " jammy " =~ " ${VERSION_CODENAME} " ]]; then
  echo "Ubuntu version ${VERSION_CODENAME} not supported"
  echo "Ubuntu 22.04 LTS (Jammy) is the only supported Ubuntu distribution"
else
  wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
    sudo gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu ${VERSION_CODENAME}/lts/2350 unified" | \
    sudo tee /etc/apt/sources.list.d/intel-gpu-${VERSION_CODENAME}.list
  sudo apt update

  sudo apt install -y \
    linux-headers-$(uname -r) \
    linux-modules-extra-$(uname -r) \
    flex bison \
    intel-fw-gpu intel-i915-dkms xpu-smi

  sudo apt install -y \
    intel-opencl-icd intel-level-zero-gpu level-zero \
    intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2 \
    libigdgmm12 vainfo hwinfo clinfo

  sudo apt install -y \
    libigc-dev intel-igc-cm libigdfcl-dev libigfxcmrt-dev level-zero-dev \
    libvpl-dev

  sudo reboot
fi

git clone https://github.com/intel/vpl-gpu-rt vpl-gpu-rt
pushd .
cd vpl-gpu-rt
mkdir -p build
cd build
cmake ..
make
make install
popd
