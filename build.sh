#!/bin/bash
set -e

crave run --no-patch -- "
#Clone device dependencies kernel / vendor / dt 
git clone https://github.com/Andreyka445/android_device_realme_RMX2185
git clone https://github.com/realme-mediatek-dev/proprietary_vendor_realme_RMX2185
git clone https://github.com/realme-mediatek-dev/android_vendor_oplus
https://github.com/realme-mediatek-dev/android_kernel_realme_mt6765

#initialize rom repo
repo init -u https://github.com/Evolution-X/manifest -b udc --git-lfs

#Sync
/opt/crave/resync.sh


#Setup environment and start build
. build/envsetup.sh &&
lunch lineage_RMX2185-user &&
m evolution
"
