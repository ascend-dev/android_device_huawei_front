#!/bin/bash
cd `dirname $0`
if [ "$1" = "ext" ]
then
    cp init.front.rc_ext ramdisk/init.front.rc
    cp storage_list.xml_ext ./overlay/frameworks/base/core/res/res/xml/storage_list.xml
    cp vold.fstab_ext vold.fstab
elif [ "$1" = "extonly" ]
then
    cp init.front.rc_extonly ramdisk/init.front.rc
    cp storage_list.xml_ext ./overlay/frameworks/base/core/res/res/xml/storage_list.xml
    cp vold.fstab_ext vold.fstab
elif [ "$1" = "std" ]
then
    cp init.front.rc_std ramdisk/init.front.rc
    cp storage_list.xml_std ./overlay/frameworks/base/core/res/res/xml/storage_list.xml
    cp vold.fstab_std vold.fstab
else
    echo "Usage: $0 [ext|extonly|std]"
fi
