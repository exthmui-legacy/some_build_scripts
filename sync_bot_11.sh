#!/bin/sh

# 格式: 路径:repo
NEED_MERGE_REPOS="
android:android
build/make:android_build
build/soong:android_build_soong
device/lineage/sepolicy:android_device_lineage_sepolicy
frameworks/base:android_frameworks_base
frameworks/av:android_frameworks_av
packages/apps/Settings:android_packages_apps_Settings
packages/apps/Messaging:android_packages_apps_Messaging
packages/apps/Backgrounds:android_packages_apps_Backgrounds
packages/apps/Dialer:android_packages_apps_Dialer
packages/apps/Contacts:android_packages_apps_Contacts
packages/apps/DeskClock:android_packages_apps_DeskClock
packages/apps/CarrierConfig:android_packages_apps_CarrierConfig
packages/apps/SetupWizard:android_packages_apps_SetupWizard
packages/apps/Trebuchet:android_packages_apps_Trebuchet
system/core:android_system_core
vendor/exthm:android_vendor_lineage
lineage-sdk:android_lineage-sdk
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
    git fetch lineage lineage-18.1
    git checkout exthm-11
    git merge lineage/lineage-18.1
    if [ $? -eq 0 ]; then
        git push review exthm-11:refs/for/exthm-11
        if [ $? -ne 0 ]; then
            FAIL_LIST="$FAIL_LIST${par[1]}\n"
        fi
    else
        FAIL_LIST="$FAIL_LIST${par[1]}\n"
    fi
done

echo -e "以下项目同步失败: \n$FAIL_LIST"
