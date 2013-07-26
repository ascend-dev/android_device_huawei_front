#!/bin/bash
ROMZIP=$1     # path to zip
PATCHTYPE=$2   # ext or std

# checking arguments
if [ -z "$ROMZIP" ]
then
    echo 
    echo "Usage:"
    echo "   $0 <path_to_rom_zip_file> <std|ext>"
    exit 1
fi

if [ ! -f "$ROMZIP" ]
then
    echo 
    echo "ERROR: No such file: $ROMZIP"
    echo 
    echo "Usage:"
    echo "   $0 <path_to_rom_zip_file> <std|ext>"
    exit 2
fi

if [ -z "$PATCHTYPE" ]
then
    echo 
    echo "Missing patch type 'ext' or 'std'"
    echo 
    echo "Usage:"
    echo "   $0 <path_to_rom_zip_file> <std|ext>"
    exit 3
fi

if [ "$PATCHTYPE" != "std" -a "$PATCHTYPE" != "ext" ]
then
    echo 
    echo "Invalid patch type: $PATCHTYPE"
    echo 
    echo "Usage:"
    echo "   $0 <path_to_rom_zip_file> <std|ext>"
    exit 4
fi

# required commands
MISSINGCMDS=0
MKBOOTFS=$(which mkbootfs 2>/dev/null)
MKBOOTIMG=$(which mkbootimg 2>/dev/null)
UNPACKBOOTIMG=$(which unpackbootimg 2>/dev/null)
APKSIGN=$(which d2j-apk-sign.sh 2>/dev/null)

if [ -z "$MKBOOTFS" ]
then
    echo "ERROR: Missing command: mkbootfs"
    MISSINGCMDS=1
fi
if [ -z "$MKBOOTIMG" ]
then
    echo "ERROR: Missing command: mkbootimg"
    MISSINGCMDS=1
fi
if [ -z "$UNPACKBOOTIMG" ]
then
    echo "ERROR: Missing command: unpackbootimg"
    MISSINGCMDS=1
fi
if [ "$MISSINGCMDS" = "1" ]
then
    exit 5
fi

# get absolute path of rom file
OWD=`pwd`
cd `dirname $ROMZIP`
FULLROMZIP=`pwd`/`basename $ROMZIP`
TARGET=${FULLROMZIP%%.zip}_${PATCHTYPE}_patch.zip

# chdir to patch dir
cd $OWD
cd `dirname $0`
OWD=`pwd`
cd ./storage_patch

# remove old files if any 
rm -f boot.img system/etc/vold.fstab system/framework/framework-res.apk 2>/dev/null

# extract boot.img system/etc/vold.fstab and system/framework/framework-res.apk from zipped rom file
(unzip $FULLROMZIP boot.img) 2>/dev/null >/dev/null 
if [ $? -ne 0 ]
then
    echo "Error extracting boot.img from $FULLROMZIP"
    exit 6 
fi
mkdir -p system/etc 2>/dev/null
(unzip $FULLROMZIP system/etc/vold.fstab) 2>/dev/null >/dev/null
if [ $? -ne 0 ]
then
    echo "Error extracting system/etc/vold.fstab from $FULLROMZIP"
    exit 7 
fi
mkdir -p system/framework 2>/dev/null
(unzip $FULLROMZIP system/framework/framework-res.apk) 2>/dev/null >/dev/null
if [ $? -ne 0 ]
then
    echo "Error extracting system/framework/framework-res.apk from $FULLROMZIP"
    exit 8 
fi

# unpack boot.img and then unpack its ramdisk.gz
unpackbootimg -i boot.img
rm -rf ramdisk 2>/dev/null
mkdir ramdisk; cd ramdisk; gzip -dc ../boot.img-ramdisk.gz | cpio -mid ; cd ..

# copy in files
## init.front.rc to ramdisk
cp ../init.front.rc_${PATCHTYPE} ramdisk/init.front.rc
## vold.fstab to system/etc
cp ../vold.fstab_${PATCHTYPE} system/etc/vold.fstab

## storage_list.xml to system/framework/framework-res.apk/res/xml/
rm -rf res 2>/dev/null
mkdir -p res/xml
cp ../storage_list.xml_${PATCHTYPE}.enc res/xml/storage_list.xml
zip -r -0 system/framework/framework-res.apk res/xml/storage_list.xml
rm -rf res 2>/dev/null

## replace desc text in patch
if [ "$PATCHTYPE" = "std" ]
then
    sed -i 's/\(External\|Internal\)/Internal/' META-INF/com/google/android/updater-script
elif [ "$PATCHTYPE" = "ext" ]
then
    sed -i 's/\(External\|Internal\)/External/' META-INF/com/google/android/updater-script
fi

# repack boot.img
rm -f boot.img-ramdisk.gz
mkbootfs ramdisk | gzip > boot.img-ramdisk.gz
rm -rf ramdisk

rm -f boot.img
mkbootimg --kernel boot.img-zImage --ramdisk boot.img-ramdisk.gz --cmdline "`cat boot.img-cmdline`" --base `cat boot.img-base` --pagesize `cat boot.img-pagesize` -o boot.img
rm -f boot.img-*

# # (optional) sign framework-res.apk
# if [ ! -z "$APKSIGN" ]
# then
#     $APKSIGN system/framework/framework-res.apk
#     mv framework-res-signed.apk system/framework/framework-res.apk
# fi

# create patch
rm -f $TARGET
zip -r $TARGET boot.img META-INF system

if [ ! -z "$APKSIGN" ]
then
    rm -f *-signed.apk
    $APKSIGN $TARGET
    mv *-signed.apk $TARGET
fi

# clean up
sed -i 's/\(External\|Internal\)/External/' META-INF/com/google/android/updater-script
rm boot.img
find system -type f | xargs rm -f
echo "Done $TARGET"
