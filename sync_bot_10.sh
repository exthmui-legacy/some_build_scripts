#!/bin/sh

# 格式: 路径:repo
NEED_MERGE_REPOS="
android:android
build/make:android_build
external/bash:android_external_bash
frameworks/base:android_frameworks_base
frameworks/av:android_frameworks_av
packages/apps/AudioFX:android_packages_apps_AudioFX
packages/apps/Bluetooth:android_packages_apps_Bluetooth
packages/apps/Dialer:android_packages_apps_Dialer
packages/apps/Contacts:android_packages_apps_Contacts
packages/apps/DeskClock:android_packages_apps_DeskClock
packages/apps/DocumentsUI:android_packages_apps_DocumentsUI
packages/apps/LineageParts:android_packages_apps_LineageParts
packages/apps/Messaging:android_packages_apps_Messaging
packages/apps/Settings:android_packages_apps_Settings
packages/apps/SetupWizard:android_packages_apps_SetupWizard
packages/apps/TvSettings:android_packages_apps_TvSettings
packages/services/Telephony:android_packages_services_Telephony
packages/apps/CarrierConfig:android_packages_apps_CarrierConfig
packages/apps/PermissionController:android_packages_apps_PackageInstaller
packages/apps/Trebuchet:android_packages_apps_Trebuchet
system/core:android_system_core
device/lineage/sepolicy:android_device_lineage_sepolicy
lineage-sdk:android_lineage-sdk
vendor/exthm:android_vendor_lineage
system/netd:android_system_netd
"
# frameworks/opt/net/ims:android_frameworks_opt_net_ims
# packages/apps/Updater:android_packages_apps_Updater

rompath="$(realpath $1)"
FAIL_LIST=""

for repotext in $NEED_MERGE_REPOS
do
    OLD_IFS="$IFS"
    IFS=":"
    par=($repotext)
    IFS="$OLD_IFS"
    cd ${rompath}/${par[0]}
    echo "开始同步 ${par[1]}"
    if [ -z $(git remote | grep lineage) ]; then
        git remote add lineage https://github.com/LineageOS/${par[1]}
    fi
    git remote update
    git checkout exthm-10
    git merge lineage/lineage-17.1
    if [ $? -eq 0 ]; then
        git push review exthm-10:refs/for/exthm-10
        if [ $? -ne 0 ]; then
            FAIL_LIST="$FAIL_LIST${par[1]}\n"
        fi
    else
        FAIL_LIST="$FAIL_LIST${par[1]}\n"
    fi
done

echo -e "以下项目同步失败: \n$FAIL_LIST"
