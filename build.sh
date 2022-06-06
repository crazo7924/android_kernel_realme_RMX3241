#!/bin/bash

function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST=Anupam_Roy
export KBUILD_BUILD_USER="Gorilla669"
git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang

[ -d "out" ] && rm -rf AnyKernel && rm -rf out || mkdir -p out

make O=out ARCH=arm64 RM6833_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      LD=ld.lld \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/clang/bin/aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="${PWD}/clang/bin/arm-linux-gnueabi-" \
                      CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log 
}

function zupload()
{
git clone --depth=1 https://github.com/Johny8988/AnyKernel3.git AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
date=$(date "+%Y-%m-%d")
zip -r9 ThunderStorm-lto-KERNEL-RM6833-$date.zip *
curl -sL https://git.io/file-transfer | sh
./transfer wet ThunderStorm-lto-KERNEL-RM6833-$date.zip
}

compile
zupload
