#!/bin/bash

sudo apt-get install build-essential curl tar pkg-config
mkdir -p $BUILD_DIR/vaapi

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
  zlib1g-dev \
  mercurial \
  libdrm-dev \
  libx11-dev \
  libperl-dev \
  libpciaccess-dev \
  libpciaccess0 \
  xorg-dev \
  intel-gpu-tools \
  opencl-headers \
  libwayland-dev \
  xutils-dev \
  ocl-icd-*
  
#desktop driver
sudo add-apt-repository ppa:oibaf/graphics-drivers
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade

#preparing build libva
cd $BUILD_DIR/vaapi
git clone https://anongit.freedesktop.org/git/mesa/drm.git libdrm
cd libdrm
./autogen.sh --prefix=/usr --enable-udev
time make -j$(nproc) VERBOSE=1
sudo make -j$(nproc) install
sudo ldconfig -vvvv

echo "building libva ..."
cd $BUILD_DIR/vaapi
git clone https://github.com/01org/libva
cd libva
./autogen.sh --prefix=$TARGET_DIR --libdir=/usr/lib/x86_64-linux-gnu
time make -j$(nproc) VERBOSE=1
sudo make -j$(nproc) install
sudo ldconfig -vvvv

echo "building gmmlibs ...."
mkdir -p $BUILD_DIR/vaapi/workspace
cd $BUILD_DIR/vaapi/workspace
git clone https://github.com/intel/gmmlib
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE= Release ../gmmlib
make -j$(nproc)
sudo make -j$(nproc) install

cd $BUILD_DIR/vaapi/workspace
git clone https://github.com/intel/media-driver
cd media-driver
git submodule init
git pull
mkdir -p $BUILD_DIR/vaapi/workspace/build_media
cd $BUILD_DIR/vaapi/workspace/build_media
cmake ../media-driver \
-DBS_DIR_GMMLIB=$PWD/../gmmlib/Source/GmmLib/ \
-DBS_DIR_COMMON=$PWD/../gmmlib/Source/Common/ \
-DBS_DIR_INC=$PWD/../gmmlib/Source/inc/ \
-DBS_DIR_MEDIA=$PWD/../media-driver \
-DCMAKE_INSTALL_PREFIX=/usr \
-DCMAKE_INSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu \
-DINSTALL_DRIVER_SYSCONF=OFF \
-DLIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri
time make -j$(nproc) VERBOSE=1
sudo make -j$(nproc) install VERBOSE=1
sudo usermod -a -G video $USER

LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri
LIBVA_DRIVER_NAME=iHD

sudo add-apt-repository ppa:intel-opencl/intel-opencl
sudo apt-get update

sudo apt install intel-*
sudo apt-get install -y ccache flex bison cmake g++ git patch zlib1g-dev autoconf xutils-dev libtool pkg-config libpciaccess-dev libz-dev clinfo
cd $BUILD_DIR/vaapi
git clone https://github.com/Intel-Media-SDK/MediaSDK msdk
cd msdk
git submodule init
git pull

mkdir -p $BUILD_DIR/vaapi/build_msdk
cd $BUILD_DIR/vaapi/build_msdk
cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_WAYLAND=ON -DENABLE_X11_DRI3=ON -DENABLE_OPENCL=ON  ../msdk
time make -j$(nproc) VERBOSE=1
sudo make install -j$(nproc) VERBOSE=1

cat "/opt/intel/mediasdk/lib\n/opt/intel/mediasdk/plugins" > /etc/ld.so.conf.d/imsdk.conf

sudo ldconfig -vvvv

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

./build_quicksync.sh "$@"
