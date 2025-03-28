# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=ExampleKernel by osm0sis @ xda-developers
kernel.for=KernelForDriver
kernel.compiler=SDPG
kernel.made=dotkit @fakedotkit
kernel.version=44xxx
kernel.type=xxx
message.word=blablabla
build.date=2077
build.type=stable
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=X00TD
device.name2=X00T
device.name3=Zenfone Max Pro M1 (X00TD)
device.name4=ASUS_X00TD
device.name5=ASUS_X00T
supported.versions=9-13
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

# shell variables
BLOCK=/dev/block/platform/soc/c0c4000.sdhci/by-name/boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;
NO_BLOCK_DISPLAY=1;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

# Mount partitions as rw
mount /system;
mount /vendor;
mount -o remount,rw /system;
mount -o remount,rw /vendor;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chmod -R 755 $ramdisk/sbin;
chmod -R root:root $ramdisk/*;
# end attributes

## AnyKernel install
dump_boot;

# Check if boot img has Magisk Patched
cd $split_img;
if [ ! "$magisk_patched" ]; then
  $bin/magiskboot cpio ramdisk.cpio test;
  magisk_patched=$?;
fi;
if [ $((magisk_patched & 3)) -eq 1 ]; then
	if [ "$REG" = "IDN" ];then
	ui_print "! Magisk Terdeteksi, Tidak Perlu Menginstall Magisk lagi !";
	elif [ "$REG" = "EN" ];then
	ui_print "! Magisk Detected, U don't need to reinstall Magisk !";
	fi;
	WITHMAGISK=Y
fi;
cd $home

# begin ramdisk changes

#Remove old kernel stuffs from ramdisk
rm -rf $ramdisk/init.special_power.sh
rm -rf $ramdisk/init.darkonah.rc
rm -rf $ramdisk/init.spectrum.rc
rm -rf $ramdisk/init.spectrum.sh
rm -rf $ramdisk/init.boost.rc
rm -rf $ramdisk/init.trb.rc
rm -rf $ramdisk/init.azure.rc
rm -rf $ramdisk/init.PBH.rc
rm -rf $ramdisk/init.Pbh.rc
rm -rf $ramdisk/init.overdose.rc

backup_file init.rc;

remove_line init.rc "import /init.darkonah.rc";
remove_line init.rc "import /init.spectrum.rc";
remove_line init.rc "import /init.boost.rc";
remove_line init.rc "import /init.trb.rc"
remove_line init.rc "import /init.azure.rc"
remove_line init.rc "import /init.PbH.rc"
remove_line init.rc "import /init.Pbh.rc"
remove_line init.rc "import /init.overdose.rc"

# rearm perfboostsconfig.xml
if [ ! -f /vendor/etc/perf/perfboostsconfig.xml ]; then
	mv /vendor/etc/perf/perfboostsconfig.xml.bak /vendor/etc/perf/perfboostsconfig.xml;
	mv /vendor/etc/perf/perfboostsconfig.xml.bkp /vendor/etc/perf/perfboostsconfig.xml;
fi

# rearm commonresourceconfigs.xml
if [ ! -f /vendor/etc/perf/commonresourceconfigs.xml ]; then
	mv /vendor/etc/perf/commonresourceconfigs.xml.bak /vendor/etc/perf/commonresourceconfigs.xml;
	mv /vendor/etc/perf/commonresourceconfigs.xml.bkp /vendor/etc/perf/commonresourceconfigs.xml;
fi

# rearm targetconfig.xml
if [ ! -f /vendor/etc/perf/targetconfig.xml ]; then
	mv /vendor/etc/perf/targetconfig.xml.bak /vendor/etc/perf/targetconfig.xml;
	mv /vendor/etc/perf/targetconfig.xml.bkp /vendor/etc/perf/targetconfig.xml;
fi

# rearm targetresourceconfigs.xml
if [ ! -f /vendor/etc/perf/targetresourceconfigs.xml ]; then
	mv /vendor/etc/perf/targetresourceconfigs.xml.bak /vendor/etc/perf/targetresourceconfigs.xml;
	mv /vendor/etc/perf/targetresourceconfigs.xml.bkp /vendor/etc/perf/targetresourceconfigs.xml;
fi

# rearm powerhint.xml
if [ ! -f /vendor/etc/powerhint.xml ]; then
	mv /vendor/etc/powerhint.xml.bak /vendor/etc/powerhint.xml;
	mv /vendor/etc/powerhint.xml.bkp /vendor/etc/powerhint.xml;
fi

# Put Android Version on cmdline
android_ver=$(file_getprop /system/build.prop ro.build.version.release);
patch_cmdline androidboot.version androidboot.version=$android_ver

# Switch Vibration Type
NLVib() {
if [ "$REG" = "IDN" ];then
ui_print "- Tipe Driver Getaran: NLV";
elif [ "$REG" = "EN" ];then
ui_print "- Vibrate Driver Type: NLV";
fi;
patch_cmdline led.vibration led.vibration=0
}

if [ "`$BB grep -w "selected.1=1" /tmp/aroma-data/nlvib.prop`" ];then
	if [ "$android_ver" -lt "11" ];then
	if [ "$REG" = "IDN" ];then
	ui_print "! Versi Android tidak didukung untuk LV. NLV diatur sebagai default !";
	elif [ "$REG" = "EN" ];then
	ui_print "! Unsupported Android Version for LV. NLV is set as default !";
	fi;
	NLVib
	else
	if [ "$REG" = "IDN" ];then
	ui_print "- Tipe Driver Getaran: LV";
	elif [ "$REG" = "EN" ];then
	ui_print "- Vibrate Driver Type: LV";
	fi;
	patch_cmdline led.vibration led.vibration=1
	fi;
else
	NLVib
fi;

# Overclock CPU & GPU
if [ "`$BB grep -w "selected.1=1" /tmp/aroma-data/overclock.prop`" ];then
	if [ "$REG" = "IDN" ];then
	ui_print "- CPU di-Overclock";
	elif [ "$REG" = "EN" ];then
	ui_print "- Overclock CPU Freq";
	fi;
	patch_cmdline overclock.cpu overclock.cpu=1
elif [ "`$BB grep -w "selected.1=2" /tmp/aroma-data/overclock.prop`" ];then
	if [ "$REG" = "IDN" ];then
	ui_print "- CPU tidak di-Overclock";
	elif [ "$REG" = "EN" ];then
	ui_print "- Use Stock CPU Freq";
	fi;
	patch_cmdline overclock.cpu overclock.cpu=0
fi;

if [ "`$BB grep -w "selected.2=1" /tmp/aroma-data/overclock.prop`" ];then
	if [ "$REG" = "IDN" ];then
	ui_print "- GPU di-Overclock";
	elif [ "$REG" = "EN" ];then
	ui_print "- Overclock GPU Freq";
	fi;
	patch_cmdline overclock.gpu overclock.gpu=1
elif [ "`$BB grep -w "selected.2=2" /tmp/aroma-data/overclock.prop`" ];then
	if [ "$REG" = "IDN" ];then
	ui_print "- GPU tidak di-Overclock";
	elif [ "$REG" = "EN" ];then
	ui_print "- Use Stock GPU Freq";
	fi;
	patch_cmdline overclock.gpu overclock.gpu=0
fi;

# end ramdisk changes

write_boot;
## end install

