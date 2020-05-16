#!/bin/bash
####################################################
#       Auto Android sync and build bash command script          #
#       自动Android源码同步编译脚本Ver 2.0                    #
#       writen by kiRa Rumia  Date:05/12/2020  1:02PM          #
####################################################
echo "==================="
echo "Build Bash Command"
echo "==================="
exthm_root="~/exthmui/exthm-10/"
read -p "Enter device name:" device_name
cd ${exthm_root}
read -p "Do you want to sync sourcecode?(y/n)" sync
if [ $sync = "y" ];then
repo sync -j8 --force-sync --fail-fast
if [ $? -eq 0 ]; then
	    echo "sync succeed!"
    else
	    echo "sync failed,retring..."
		repo sync -j8 --force-sync --fail-fast
	fi
else
	echo "Cancel sync"
fi
out_dir_base="~/exthmui/exthm-10/out/target/product"
out_dir="${out_dir_base}/${device_name}"
target_dir="~/zip_package"
source build/make/envsetup.sh
breakfast $device_name
mka bacon -j32 | tee {$device_name}_log.txt
if [ $? -eq 0 ]; then
    echo "build succeed!copying zip package file..."
    if [ ! -d $target_dir ];then
    cp ${out_dir}/exthm-10.0-*.zip ${target_dir}/
         if [ $? -eq 0 ];then
             echo "File copied successfully!go to ${target_dir} to flash it!"
         else
             echo "File copy failed!"
         fi
    else
         echo "Creating target package dir..."
         mkdir ${target_dir}
         cp ${out_dir}/exthm-10.0-*.zip ${target_dir}/
         if [ $? -eq 0];then
             echo "File copied successfully!go to ${target_dir} to flash it!"
         else
             echo "File copy failed!"
         fi
    fi
else
    echo "build failed!you can check the log file to debug."
fi
