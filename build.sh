#!/bin/bash

# =================================================================
#                     LH7n Infinity Build Script
# =================================================================
#
# Stop the script immediately if any command fails
set -e

# =======================
#   SETUP & PRE-CHECKS
# =======================

# Load environment variables from .env file
if [ -f .env ]; then
  set -o allexport
  source .env
  set +o allexport
else
  echo "Error: .env file not found! Create one with your secrets."
  exit 1
fi

# Check for required secrets
if [ -z "$TG_BOT_TOKEN" ] || [ -z "$TG_CHAT_ID" ] || [ -z "$PIXELDRAIN_API_KEY" ]; then
    echo "Error: One or more required variables are missing in your .env file."
    echo "Required: TG_BOT_TOKEN, TG_CHAT_ID, PIXELDRAIN_API_KEY"
    exit 1
fi

# Telegram notification function
send_telegram_message() {
    curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" \
        --data-urlencode "chat_id=$TG_CHAT_ID" \
        --data-urlencode "text=$1" \
        --data-urlencode "parse_mode=Markdown" > /dev/null
}

# Trap to send a notification on script failure
handle_exit() {
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        send_telegram_message "❌ *LH7n Build Failed!*

The script exited with a non-zero status code: `$EXIT_CODE`.
Please check the logs for the exact error."
    fi
}
trap handle_exit EXIT

# Send "Build Started" notification
send_telegram_message "🚀 *New LH7n Build Started!*

Infinity OS build for Tecno LH7n has been initiated."

# === Exports ===
BUILD_START_TIME=$(date +%s)
export BUILD_USERNAME=Andreyka445
export BUILD_HOSTNAME=lh7n

# =======================
#   1. CLEANUP SECTION
# =======================

echo "Cleaning up directories..."
rm -rf .repo/local_manifests
rm -rf device/tecno/LH7n
rm -rf device/tecno/mt6789-common
rm -rf device/tecno/LH7n-kernel
rm -rf vendor/tecno/LH7n
rm -rf vendor/tecno/mt6789-common
rm -rf vendor/sony/dolby
rm -rf vendor/JamesDSP
rm -rf packages/apps/ViPER4AndroidFX
rm -rf hardware/mediatek
rm -rf hardware/transsion
rm -rf device/mediatek/sepolicy_vndr
rm -rf vendor/lineage-priv/keys
rm -rf vendor/evolution-priv/keys
rm -rf vendor/infinity-priv/keys
rm -rf device/qcom/sepolicy_vndr
rm -rf build/soong
rm -rf vendor/google/gms
rm -rf vendor/gms
rm -rf prebuilts/clang/host/linux-x86
rm -rf platform/prebuilts/clang/host/linux-x86

echo "Cleanup finished."

# =======================
#   2. LOCAL MANIFEST & REPO SYNC
# =======================
echo "Cloning local manifest..."
git clone https://github.com/Andreyka445/local_manifests.git -b evox-16-lh7n .repo/local_manifests

echo "Initializing Infinity repository..."
repo init -u https://github.com/Evolution-X/manifest -b bq1 --git-lfs

echo "Syncing sources..."
if [ -f "/opt/crave/resync.sh" ]; then
    /opt/crave/resync.sh

# =======================
#   3. SIGNING KEYS
# =======================
echo "Cloning signing keys..."
git clone --depth=1 --branch evolution https://github.com/Andreyka445/signingkey vendor/evolution-priv/keys

# =======================
#   4. BUILD THE ROM
# =======================
echo "Starting the build process..."
. build/envsetup.sh
lunch lineage_LH7n-bp3a-userdebug

echo "Running 'make installclean' for a safe build..."
make installclean

echo "Starting the main build..."
m evolution

send_telegram_message "✅ *LH7n Build Finished Successfully!*

Now preparing to upload the file..."

# =======================
#   5. UPLOAD THE BUILD
# =======================
echo "Starting the upload process..."

# === Stop Build Timer and Calculate Duration ===
BUILD_END_TIME=$(date +%s)
DURATION=$((BUILD_END_TIME - BUILD_START_TIME))
DURATION_FORMATTED=$(printf '%dh:%dm:%ds
' $(($DURATION/3600)) $(($DURATION%3600/60)) $(($DURATION%60)))

OUTPUT_DIR="out/target/product/LH7n"
ZIP_FILE=$(find "$OUTPUT_DIR" -type f -iname "Infinity*.zip" -o -iname "Project*.zip" -printf "%T@ %p
" | sort -n | tail -n1 | cut -d' ' -f2-)

if [[ -f "$ZIP_FILE" ]]; then
  echo "Uploading $ZIP_FILE to Pixeldrain..."
  RESPONSE=$(curl -s -u ":$PIXELDRAIN_API_KEY" -X POST -F "file=@$ZIP_FILE" https://pixeldrain.com/api/file)
  FILE_ID=$(echo "$RESPONSE" | jq -r '.id')
  
  if [[ "$FILE_ID" != "null" && -n "$FILE_ID" ]]; then
    DOWNLOAD_URL="https://pixeldrain.com/u/$FILE_ID"
    FILE_NAME=$(basename "$ZIP_FILE")
    FILE_SIZE_BYTES=$(stat -c%s "$ZIP_FILE")
    FILE_SIZE_HUMAN=$(numfmt --to=iec --suffix=B "$FILE_SIZE_BYTES" 2>/dev/null || echo "${FILE_SIZE_BYTES}B")
    UPLOAD_DATE=$(date +"%Y-%m-%d %H:%M")
    
    echo "Upload successful: $DOWNLOAD_URL"
    UPLOAD_MESSAGE="🎉 *LH7n Infinity OS Upload Complete!*

*Build Time:* `$DURATION_FORMATTED`
📱 *Device:* Tecno LH7n
📎 *Filename:* `$FILE_NAME`
📦 *Size:* $FILE_SIZE_HUMAN
🕓 *Uploaded:* $UPLOAD_DATE
🔗 [Download Link]($DOWNLOAD_URL)"
    send_telegram_message "$UPLOAD_MESSAGE"
  else
    echo "Upload failed. Pixeldrain response: $RESPONSE"
    send_telegram_message "❌ *Upload Failed!*

✅ Build successful, but upload to Pixeldrain failed.
*Response:* `$RESPONSE`"
  fi
else
  echo "Error: No .zip file found in $OUTPUT_DIR"
  send_telegram_message "❌ *Upload Failed!*

✅ Build completed, but no .zip file found in `$OUTPUT_DIR`."
fi

echo "Script finished successfully."
trap - EXIT  # Remove trap for clean exit
