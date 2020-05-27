#!/bin/bash

sudo apt-get install build-essential curl tar pkg-config
sudo apt-get -y --force-yes install \
  autoconf \
  automake \
  build-essential \
  cmake \
  frei0r-plugins-dev \
  gawk \
  libass-dev \
  libfreetype6-dev \
  libopencore-amrnb-dev \
  libopencore-amrwb-dev \
  libsdl1.2-dev \
  libspeex-dev \
  libssl-dev \
  libtheora-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvo-amrwbenc-dev \
  libvorbis-dev \
  libwebp-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  libxvidcore-dev \
  pkg-config \
  texi2html \
  zlib1g-dev

#nvenc dependencies
sudo apt-get -y install glew-utils libglew-dev libglew2.0 freeglut3 freeglut3-dev libghc-glut-dev libghc-glut-doc libghc-glut-prof libalut-dev libxmu-dev libxmu-headers libxmu6 libxmu6-dbg libxmuu-dev libxmuu1 libxmuu1-dbg git-core

sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo apt-get update

sudo apt install nvidia-driver-440 xserver-xorg-video-nvidia-440 nvidia-utils-440 nvidia-kernel-source-440 nvidia-kernel-common-440 nvidia-dkms-440 nvidia-compute-utils-440 libnvidia-ifr1-440 libnvidia-gl-440 libnvidia-fbc1-440 libnvidia-encode-440 libnvidia-decode-440 libnvidia-cfg1-440 libnvidia-compute-440

# For 12.04
# libx265 requires cmake version >= 2.8.8
# 12.04 only have 2.8.7
ubuntu_version=`lsb_release -rs`
need_ppa=`echo $ubuntu_version'<=12.04' | bc -l`
if [ $need_ppa -eq 1 ]; then
    sudo add-apt-repository ppa:roblib/ppa
    sudo apt-get update
    sudo apt-get install cmake
fi

./build-nvenc.sh "$@"
