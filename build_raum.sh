#!/bin/bash

# Colorize and add text parameters
red=$(tput setaf 1) # red
grn=$(tput setaf 2) # green
cya=$(tput setaf 6) # cyan
txtbld=$(tput bold) # Bold
bldred=${txtbld}$(tput setaf 1) # red
bldgrn=${txtbld}$(tput setaf 2) # green
bldblu=${txtbld}$(tput setaf 4) # blue
bldcya=${txtbld}$(tput setaf 6) # cyan
txtrst=$(tput sgr0) # Reset

DEVICE="$1"
THREADS="$2"
NICE="$3"
SYNC="$4"
CLEAN="$5"

# Build Date/Version
VERSION=`date +%Y%m%d`

# Directory where you wanna store build logs
LOGS="../build_logs"

SYSPATH="${PWD}/out/target/product/toro/system"

# Time of build startup
res1=$(date +%s.%N)

echo -e "${red}Building ${bldred}raumZero-$VERSION ${txtrst}";
echo -e ""
echo -e ""
echo -e  ${bldred}" ____ ____ _  _ _  _    ___  ____ ____ ____"
echo -e " |__/ |__| |  | |\/|      /  |___ |__/ |  |"
echo -e " |  \ |  | |__| |  |     /__ |___ |  \ |__|"
echo -e

# sync with latest sources
echo -e ""
if [ "$SYNC" == "sync" ]; then
echo -e "${bldred}Syncing latest raumZero manifest ${txtrst}"
   repo sync -j"$THREADS"
   echo -e ""
fi

# setup environment
if [ "$CLEAN" == "clean" ]; then
echo -e "${bldred}Cleaning up out folder ${txtrst}"
   make clobber;
else
echo -e "${bldred}Skipping out folder cleanup ${txtrst}"
fi

# use nice
if [ "$NICE" == "" ]; then
NICE="10"
elif [ "$NICE" == "0" ]; then
NICE="19"
else
NICE="$NICE"
fi

# setup environment
echo -e "${bldred}Setting up build environment ${txtrst}"
. build/envsetup.sh

# lunch device
echo -e ""
echo -e "${bldred}Lunching your device ${txtrst}"
lunch "full_$DEVICE-userdebug";

echo -e ""
echo -e "Creating working around symlink for Arch Linux lib usr/lib"
mkdir -p $SYSPATH/lib
mkdir -p $SYSPATH/usr
ln -s $SYSPATH/lib/ $SYSPATH/usr/lib

echo -e "Symlinked dirs created... "

echo " "

echo -e "${bldred}Starting raumZero build for $DEVICE ${txtrst}"

echo
echo "device=$DEVICE nice=$NICE threads=$THREADS "
# start compilation
# log builds by date + time
time nice -n"$NICE" make otapackage -j"$THREADS" 2>&1 | tee $LOGS/raumzero_$DEVICE.log;
echo -e ""

# finished? get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
