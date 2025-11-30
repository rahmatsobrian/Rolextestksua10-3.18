#!/bin/bash

# enable full error tracking
set -o pipefail

# setup color (GitHub Actions mendukung ANSI color)
red='\033[0;31m'
green='\e[0;32m'
white='\033[0m'
yellow='\033[0;33m'

WORK_DIR=$(pwd)
KERN_IMG="${WORK_DIR}/out/arch/arm64/boot/Image-gz.dtb"
KERN_IMG2="${WORK_DIR}/out/arch/arm64/boot/Image.gz"

TC64="${WORK_DIR}/linegcc49/bin/aarch64-linux-android-"
TC32="${WORK_DIR}/linegcc49/bin/arm-linux-androideabi-"

function build_kernel() {
    echo -e "\n${yellow}<< Building kernel >>$white\n"

    START_TIME=$(date +%s)

    # hapus folder out biar build bersih
    rm -rf out

    echo -e "${yellow}[1] Loading defconfig...$white"
    make -j"$(nproc --all)" O=out ARCH=arm64 rolex_defconfig

    echo -e "${yellow}[2] Compiling kernel...$white"
    make -j"$(nproc --all)" \
        ARCH=arm64 O=out \
        CROSS_COMPILE="${TC64}" \
        CROSS_COMPILE_ARM32="${TC32}" \
        CROSS_COMPILE_COMPAT="${TC32}"

    END_TIME=$(date +%s)
    BUILD_TIME=$((END_TIME - START_TIME))

    if [ -e "$KERN_IMG" ] || [ -e "$KERN_IMG2" ]; then
        echo -e "\n${green}<< Compile kernel success! >>$white"
        echo -e "${yellow}Waktu build: ${BUILD_TIME} detik$white\n"
        return 0
    else
        echo -e "\n${red}<< Compile kernel failed! >>$white"
        echo -e "${yellow}Waktu build: ${BUILD_TIME} detik$white\n"
        return 1
    fi
}

# execute
build_kernel
exit $?
