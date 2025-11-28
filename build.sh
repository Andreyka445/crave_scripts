#!/bin/bash
set -e

crave run --no-patch -- "
#Nuke dirs
rm -rf .repo/local_manifests &&
rm -rf device/tecno/LH7n &&
rm -rf device/tecno/mt6789-common &&
rm -rf device/tecno/LH7n-kernel &&
rm -rf vendor/tecno/LH7n &&
rm -rf vendor/tecno/mt6789-common &&
rm -rf vendor/sony/dolby &&
rm -rf vendor/JamesDSP &&
rm -rf packages/apps/ViPER4AndroidFX &&
rm -rf hardware/mediatek &&
rm -rf hardware/transsion
rm -rf device/mediatek/sepolicy_vndr &&
rm -rf vendor/lineage-priv/keys &&
rm -rf vendor/evolution-priv/keys &&
rm -rf vendor/lmodroid-priv/keys &&
rm -rf build/soong &&
rm -rf vendor/google/gms &&
rm -rf vendor/gms &&
rm -rf prebuilts/clang/host/linux-x86 &&
rm -rf platform/prebuilts/clang/host/linux-x86 &&

echo "==> Syncing sources..."

#Clone the deivce manifest
git clone https://github.com/Andreyka445/local_manifests.git -b evox-16-lh7n .repo/local_manifests

#initialize rom repo
repo init -u https://github.com/Evolution-X/manifest -b bq1 --git-lfs

#Sync
/opt/crave/resync.sh

#Signing
git clone --depth=1 --branch evolution https://github.com/Andreyka445/signingkey vendor/evolution-priv/keys

echo "=== Starting Build ==="

#Setup environment and start build
. build/envsetup.sh
lunch lineage_LH7n-bp3a-userdebug
make installclean
m evolution

echo "=== Build complete Successful ==="
"
