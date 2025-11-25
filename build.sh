#!/bin/bash
set -e

crave run --no-patch -- "
#Clone device dependencies kernel / vendor / dt 
git clone https://github.com/Andreyka445/android_device_realme_RMX2185
git clone https://github.com/realme-mediatek-dev/proprietary_vendor_realme_RMX2185
git clone https://github.com/realme-mediatek-dev/android_vendor_oplus
git clone https://github.com/realme-mediatek-dev/android_kernel_realme_mt6765

#initialize rom repo
repo init -u https://github.com/CipherOS/android_manifest.git -b fourteen

#Sync
/opt/crave/resync.sh

#Setup environment and start build
. build/envsetup.sh &&
lunch cipher_RMX2185-userdebug &&
mka bacon
"
