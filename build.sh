#!/bin/bash
set -e

# =============================
#   InfinityX Build Script
#   For: Gapps
# =============================

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
rm -rf hardware/transsion &&
rm -rf device/mediatek/sepolicy_vndr &&
rm -rf vendor/lineage-priv/keys &&
rm -rf vendor/evolution-priv/keys &&
rm -rf vendor/lmodroid-priv/keys &&
rm -rf device/qcom/sepolicy_vndr &&
rm -rf build/soong &&
rm -rf vendor/google/gms &&
rm -rf vendor/gms &&
rm -rf prebuilts/clang/host/linux-x86 &&
rm -rf platform/prebuilts/clang/host/linux-x86 &&

# --- Init ROM repo ---
repo init -u https://github.com/ProjectInfinity-X/manifest -b 16 --git-lfs && \

# --- Sync ROM ---
/opt/crave/resync.sh && \

# --- Clone device specific repos---
git clone https://github.com/Andreyka445/android_device_tecno_LH7n -b infinityx-16-lh7n device/tecno/LH7n
git clone https://github.com/MillenniumOSS/android_device_tecno_LH7n-kernel -b sixteen device/tecno/LH7n-kernel
git clone https://github.com/MillenniumOSS/android_vendor_tecno_LH7n -b sixteen vendor/tecno/LH7n
git clone https://github.com/MillenniumOSS/android_hardware_mediatek -b sixteen hardware/mediatek
git clone https://github.com/MillenniumOSS/android_hardware_millennium -b sixteen hardware/millennium
git clone https://github.com/MillenniumOSS/android_device_mediatek_sepolqicy_vndr -b sixteen device/mediatek/sepolicy_vndr
git clone https://github.com/MillenniumOSS/android_vendor_mediatek_ims -b sixteen vendor/mediatek/ims

#Signing
git clone --depth=1 --branch infinityx https://github.com/Andreyka445/signingkey vendor/infinity-priv/keys

# =============================
#  Build: Gapps
# =============================

# --- Gapps Build ---
echo "===== Setting up for Gapps Build ====="
. build/envsetup.sh && \
lunch infinity_LH7n-userdebug
make installclean && \
m bacon && \

echo "===== Builds completed successfully! ====="
