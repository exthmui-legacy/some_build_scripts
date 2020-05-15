#!/bin/sh

# 格式: 路径:repo
NEED_MERGE_REPOS="
build/make:android_build
external/bash:android_external_bash
frameworks/base:android_frameworks_base
frameworks/opt/net/ims:android_frameworks_opt_net_ims
packages/apps/AudioFX:android_packages_apps_AudioFX
packages/apps/Bluetooth:android_packages_apps_Bluetooth
packages/apps/DocumentsUI:android_packages_apps_DocumentsUI
packages/apps/LineageParts:android_packages_apps_LineageParts
packages/apps/Messaging:android_packages_apps_Messaging
packages/apps/Settings:android_packages_apps_Settings
packages/apps/TvSettings:android_packages_apps_TvSettings
system/core:android_system_core
device/lineage/sepolicy:android_device_lineage_sepolicy
lineage-sdk:android_lineage-sdk
"

basepath="$(cd $(dirname $0); pwd)"
rompath="$1"
FAIL_LIST=""

for repotext in $NEED_MERGE_REPOS
do
    OLD_IFS="$IFS"
    IFS=":"
    par=($repotext)
    IFS="$OLD_IFS"
    cd ${basepath}/${rompath}/${par[0]}
    echo "开始同步 ${par[1]}"
    if [ -z $(git remote | grep lineage) ]; then
        git remote add lineage https://github.com/LineageOS/${par[1]}
    fi
    git remote update
    git checkout exthm-10
    git merge lineage/lineage-17.1
    if [ $? -eq 0 ]; then
        git push exthm exthm-10
    else
        FAIL_LIST="$FAIL_LIST${par[1]}
"
    fi
done

echo "以下项目同步失败: 
$FAIL_LIST"
