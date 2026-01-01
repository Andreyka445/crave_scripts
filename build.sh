#!/bin/bash
set -e

crave run --no-patch -- "
# Очистка
echo 'Cleaning...'
rm -rf .repo/local_manifests device/tecno/LH7n device/tecno/mt6789-common
rm -rf device/tecno/LH7n-kernel vendor/tecno/LH7n vendor/tecno/mt6789-common
rm -rf vendor/sony/dolby vendor/JamesDSP packages/apps/ViPER4AndroidFX
rm -rf hardware/mediatek hardware/transsion device/mediatek/sepolicy_vndr
rm -rf vendor/*-priv/keys device/qcom/sepolicy_vndr build/soong
rm -rf vendor/google/gms vendor/gms prebuilts/clang/host/linux-x86

# Синхронизация
echo 'Syncing...'
git clone https://github.com/Andreyka445/local_manifests.git -b miku .repo/local_manifests
repo init -u https://github.com/Miku-UI-fork/manifesto -b Blooming
/opt/crave/resync.sh

# Сборка
echo 'Building...'
. build/envsetup.sh
lunch miku_LH7n-bp2a-userdebug
make installclean
make diva
"
