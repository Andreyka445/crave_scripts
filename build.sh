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
repo init -u https://github.com/Miku-UI/manifesto -b Blooming --git-lfs
/opt/crave/resync.sh

# Патчи
echo 'Applying patches...'
PATCHES_TEMP=/tmp/miku_patches_\$\$
git clone -q https://github.com/Andreyka445/miku_pathes.git \$PATCHES_TEMP

apply_patch() {
    patch=\$1; dir=\$2
    [ -d "\$dir" ] && cd "\$dir" && git apply --whitespace=nowarn "\$patch" 2>/dev/null && echo \"  ✓ \$(basename \$patch)\" || echo \"  ⚠ \$(basename \$patch)\"
}

for p in \$PATCHES_TEMP/patches/build/make/*.patch; do apply_patch "\$p" build/make; done
for p in \$PATCHES_TEMP/patches/build/soong/*.patch; do apply_patch "\$p" build/soong; done
for p in \$PATCHES_TEMP/patches/vendor/miku/*.patch; do apply_patch "\$p" vendor/miku; done

rm -rf \$PATCHES_TEMP

# Сборка
echo 'Building...'
. build/envsetup.sh
lunch miku_LH7n-bp2a-userdebug
make installclean
make diva
"
