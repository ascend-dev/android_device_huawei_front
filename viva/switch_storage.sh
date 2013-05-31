#!/bin/bash
cd `dirname $0`
if [ "$1" = "ext" ]
then
    cp init.viva.rc_ext ramdisk/init.viva.rc
    cp storage_list.xml_ext ./overlay/frameworks/base/core/res/res/xml/storage_list.xml
    cp vold.fstab_ext vold.fstab
elif [ "$1" = "extonly" ]
then
    cp init.viva.rc_extonly ramdisk/init.viva.rc
    cp storage_list.xml_ext ./overlay/frameworks/base/core/res/res/xml/storage_list.xml
    cp vold.fstab_ext vold.fstab
elif [ "$1" = "std" ]
then
    cp init.viva.rc_std ramdisk/init.viva.rc
    cp storage_list.xml_std ./overlay/frameworks/base/core/res/res/xml/storage_list.xml
    cp vold.fstab_std vold.fstab
else
    echo "Usage: $0 [ext|extonly|std]"
fi
