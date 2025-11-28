#!/bin/bash
set -e

removedir=(
.repo/local_manifests
device/tecno/LH7n
device/tecno/mt6789-common
device/tecno/LH7n-kernel
vendor/tecno/LH7n
vendor/tecno/mt6789-common
vendor/sony/dolby
vendor/JamesDSP
packages/apps/ViPER4AndroidFX
hardware/mediatek
hardware/transsion
device/mediatek/sepolicy_vndr
vendor/lineage-priv/keys
vendor/evolution-priv/keys
vendor/lmodroid-priv/keys
build/soong
vendor/google/gms
vendor/gms
prebuilts/clang/host/linux-x86
platform/prebuilts/clang/host/linux-x86
)

rm -rf "${removedir[@]}"

#Clone the deivce manifest
git clone https://github.com/Andreyka445/local_manifests.git -b evox-16-lh7n .repo/local_manifests

#initialize rom repo
repo init -u https://github.com/Evolution-X/manifest -b bq1 --git-lfs

#Sync
/opt/crave/resync.sh

#Signing
git clone --depth=1 --branch evolution https://github.com/Andreyka445/signingkey vendor/evolution-priv/keys &&

#Setup environment and start build
. build/envsetup.sh
lunch lineage_LH7n-bp3a-userdebug
make installclean
m evolution 
"
