#!/bin/bash

echo -e "****************************************"
echo -e "* exTHmUI编译脚本/ exTHmUI Build Script *"
echo -e "*      Author: together08,cjybyjk      *"
echo -e "*           Date:2020-05-14            *"
echo -e "****************************************"
echo "Usage: $0 <android_source_dir> <device_codename> <choise_sync_or_no(y/n)>"
echo "请确保dt,kt及vt均以存在！"

# Define variables
android_source=$1
codename=$2
log=$3
sync="$4"
if [ "" = "$android_source" ]; then
  read -p "源码目录: " android_source
  echo "输入的源码目录: $android_source"
fi
if [ "" = "$codename" ]; then
  read -p "设备代号: " codename
  echo "输入的设备代号为: $codename"
fi
if [ "" = "$sync" ]; then
  read -p "是否Sync(y/n): " sync
  echo "选择为: $sync"
fi

# Clone source code
if [ $sync = "y" ];then
    repo sync -j8 --force-sync --fail-fast
    cd $android_source
    repo init -u https://github.com/exthmui/android.git -b exthm-10 --depth=1
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags -f --force-sync --no-clone-bundle --no-tags --fail-fast
    if [ $? -eq 0 ]; then
	      echo "sync succeed!"
    else
	      echo "sync failed,retring..."
		    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
    fi
else
	echo "Sync canceled."
fi

# Start build
out_dir_base="$android_source/out/target/product"
out_dir="$out_dir_base/$codename"

echo "Starting build..."
if [ $? -eq 0 ]; then
    source build/envsetup.sh
    lunch exthm_$codename-userdebug | tee $codename_log.txt
    mka bacon -j$(nproc --all)
    echo "Build Finished."
    echo "The zip file is in $out_dir.Go to this dir and flash the rom."
    echo "The log's name is $codename_log.txt."
else
    echo "Build failed!You can check the log file:$codename_log.txt to debug."
fi    
