#!/bin/bash

# Colorize and add text parameters
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset

DEVICE="$1"
SYNC="$2"
THREADS="$3"
CLEAN="$4"


# Build Date/Version
VERSION=`date +%Y%m%d`

# Directory where you wanna store build logs
LOGS="$HOME/android/build_logs"

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
if [ "$SYNC" == "sync" ]
then
   echo -e "${bldred}Syncing latest linaro+raumZero sources ${txtrst}"
   echo -e "$(repo sync -j${THREADS})"
   echo -e ""
fi

# setup environment
if [ "$CLEAN" == "clean" ]
then
   echo -e "${bldred}Cleaning up out folder ${txtrst}"
   echo -e "$(make clobber)";
else
  echo -e "${bldred}Skipping out folder cleanup ${txtrst}"
fi


# setup environment
echo -e "${bldred}Setting up build environment ${txtrst}"
echo -e "$(source build/envsetup.sh)"

# lunch device
echo -e ""
echo -e "${bldred}Lunching your device ${txtrst}"
echo -e "$(lunch "raumzero_${DEVICE}-userdebug")";

echo -e ""

echo -e "${bldred}Starting raumZero build for ${DEVICE} ${txtrst}"

# start compilation
# log builds by date + time
echo -e "$(time mka raumzero_${DEVICE}-userdebug -j${THREADS} 2>&1 | tee ${LOGS}/rZ_${DEVICE}-$(date +'%Y%m%d-%T').log)";
echo -e ""

# finished? get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
