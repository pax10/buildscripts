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

DATE=`date +"%Y%m%d"`

DEVICE="$1"
NICE="$2"
THREADS="$3"
SYNC="$4"
CLEAN="$5"

# Directory where you wanna store build logs
LOGS="../build_logs"

SYSPATH="${PWD}/out/target/product/toro/system"

# Time of build startup
res1=$(date +%s.%N)

# sync with latest sources
echo -e ""
if [ "$SYNC" == "sync" ]
then
echo -e "${bldblu}Syncing latest ${txtrst}"
   repo sync -j"$THREADS"
   echo -e ""
fi

# setup environment
if [ "$CLEAN" == "clean" ]
then
echo -e "${bldblu}Scrubbing the out dir ${txtrst}"
   make clobber;
else
echo -e "${bldblu}Ok... no scrubbing out ${txtrst}"
fi

# setup environment
echo -e "${bldblu}Setting up build environment ${txtrst}"
. build/envsetup.sh

echo -e ""
echo -e "${bldblu}Starting cfX build for $DEVICE ${txtrst}"

# lunch build
lunch full_"$DEVICE"-codefirex ;
echo -e ""

echo -e ""
echo -e "Checking for usr/lib.."
if [ -d $SYSPATH/usr/lib ]; then
    echo -e "lib usr/lib already exist... moving on"
else
    echo -e "Creating working around symlink for Arch Linux lib usr/lib"
    mkdir -p $SYSPATH/usr
    ln -s $SYSPATH/lib/ $SYSPATH/usr/lib
    echo -e "Symlinked dirs... moving on"
fi
echo " "

# start build
echo -e "starting build now..."
echo -e "---------------------"
echo -e "device=$DEVICE nice=$NICE threads=$THREADS"
echo -e "__________________________"
echo -e ""
time nice -n"$NICE" make otapackage -j"$THREADS" 2>&1 | tee $LOGS/full_$DEVICE-codefirex.log


# Get Package Name
sed -i -e 's/raumzero_//' $OUT/system/build.prop
VERSION=`sed -n -e'/ro.cfx.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGE=$OUT/$VERSION.zip

 finished? get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"

