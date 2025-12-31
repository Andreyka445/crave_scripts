#!/bin/bash
set -e

crave run --no-patch -- "
# Очистка старых файлов
echo '==> Очистка старых файлов...'
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

echo '==> Syncing sources...'

# Клонируем device manifest
git clone https://github.com/Andreyka445/local_manifests.git -b miku .repo/local_manifests

# Инициализируем репозиторий ROM
repo init -u https://github.com/Miku-UI/manifesto -b Blooming --git-lfs

# Синхронизируем
/opt/crave/resync.sh

# ============================================
# ПРИМЕНЕНИЕ ПАТЧЕЙ MIKU UI
# ============================================
echo ''
echo '=== Применение патчей Miku UI ==='
echo ''

# Создаём временную директорию для патчей
PATCHES_TEMP=\"/tmp/miku_patches_\$\$"
mkdir -p \"\$PATCHES_TEMP\"

# Клонируем репозиторий с патчами
echo '📥 Клонируем патчи из GitHub...'
git clone https://github.com/Andreyka445/miku_pathes.git \"\$PATCHES_TEMP\" 2>/dev/null || {
    echo '❌ Ошибка: Не удалось клонировать репозиторий с патчами'
    exit 1
}

# Функция для применения одного патча
apply_patch() {
    local patch_file=\"\$1\"
    local expected_dir=\"\$2\"
    
    local patch_name=\"\$(basename \"\$patch_file\")\"
    echo \"  🔧 \${patch_name}\"
    
    # Извлекаем реальный путь из патча
    local git_line=\"\$(grep -m1 '^diff --git' \"\$patch_file\" 2>/dev/null || echo '')\"
    local target_dir=\"\$expected_dir\"
    
    if [ -n \"\$git_line\" ]; then
        local actual_path=\"\$(echo \"\$git_line\" | sed 's/diff --git a\\///' | cut -d' ' -f1)\"
        if [ -n \"\$actual_path\" ] && [ \"\$actual_path\" != \"a/\" ]; then
            target_dir=\"\$(dirname \"\$actual_path\")\"
        fi
    fi
    
    # Проверяем существование целевой директории
    if [ ! -d \"\$target_dir\" ]; then
        echo \"    ⚠ Директория не существует: \$target_dir\"
        return 1
    fi
    
    # Переходим в целевую директорию и применяем патч
    pushd \"\$target_dir\" > /dev/null 2>&1
    
    if git apply --check --whitespace=nowarn \"\$patch_file\" 2>/dev/null; then
        if git apply --whitespace=nowarn \"\$patch_file\"; then
            echo \"    ✅ Успешно применён\"
        else
            echo \"    ❌ Ошибка применения\"
            popd > /dev/null 2>&1
            return 1
        fi
    elif git apply --reverse --check \"\$patch_file\" 2>/dev/null; then
        echo \"    ℹ️ Уже применён\"
    else
        echo \"    ⚠ Конфликт или несовместимость\"
    fi
    
    popd > /dev/null 2>&1
    return 0
}

# Применяем патчи build/make (0001-0003)
echo '📁 Патчи build/make:'
for patch in \"\$PATCHES_TEMP/patches/build/make\"/*.patch; do
    [ -f \"\$patch\" ] || continue
    apply_patch \"\$patch\" \"build/make\"
done

# Применяем патчи build/soong (0002-0008)
echo ''
echo '📁 Патчи build/soong:'
for patch in \"\$PATCHES_TEMP/patches/build/soong\"/*.patch; do
    [ -f \"\$patch\" ] || continue
    apply_patch \"\$patch\" \"build/soong\"
done

# Применяем патчи vendor/miku (0009-0015)
echo ''
echo '📁 Патчи vendor/miku:'
for patch in \"\$PATCHES_TEMP/patches/vendor/miku\"/*.patch; do
    [ -f \"\$patch\" ] || continue
    apply_patch \"\$patch\" \"vendor/miku\"
done

# Очищаем временные файлы
rm -rf \"\$PATCHES_TEMP\"

echo ''
echo '=== Все патчи Miku UI применены ==='
echo ''

# ============================================
# НАЧАЛО СБОРКИ
# ============================================
echo '=== Starting Build ==='

# Настраиваем окружение и начинаем сборку
. build/envsetup.sh
lunch miku_LH7n-bp2a-userdebug
make installclean
make diva
"
