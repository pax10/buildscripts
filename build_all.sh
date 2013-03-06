#!/bin/bash

ydate=$(date -d '1 day ago' +"%m/%d/%Y")
sdate="$2"
cdate=`date +"%m_%d_%Y"`
DATE=`date +"%Y%m%d"`
rdir=`pwd`
RELEASE="$1"
OFFICIAL="$3"
LOGS="$HOME/android/build_logs"


# Remove previous build info
echo "Removing previous build.prop"
rm out/target/product/d2att/system/build.prop;
rm out/target/product/d2tmo/system/build.prop;
rm out/target/product/d2vzw/system/build.prop;
rm out/target/product/grouper/system/build.prop;
rm out/target/product/mako/system/build.prop;
rm out/target/product/i9100/system/build.prop;
rm out/target/product/i9100g/system/build.prop;
rm out/target/product/i9300/system/build.prop;
rm out/target/product/maguro/system/build.prop;
rm out/target/product/toro/system/build.prop;
rm out/target/product/t0lte/system/build.prop;

if [ "$RELEASE" == "official" ]
then
    echo "Building Official Release";
    export RB_BUILD="$OFFICIAL"
else
    echo "Building Nightly"
fi

echo "Generating Changelog"

# Generate Changelog

# Check the date start range is set
if [ -z "$sdate" ]; then
    sdate=${ydate}
fi

# Find the directories to log
find $rdir -name .git | sed 's/\/.git//g' | sed 'N;$!P;$!D;$d' | while read line
do
    cd $line
    # Test to see if the repo needs to have a changelog written.
    log=$(git log --pretty="%an - %s" --no-merges --since=$sdate --date-order)
    project=$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//')
    if [ -z "$log" ]; then
        echo "Nothing updated on $project, skipping"
    else
        # Prepend group project ownership to each project.
        origin=`grep "$project" $rdir/.repo/manifest.xml | awk {'print $4'} | cut -f2 -d '"'`
        if [ "$origin" = "aokp" ]; then
            proj_credit=AOKP
        elif [ "$origin" = "aosp" ]; then
            proj_credit=AOSP
        elif [ "$origin" = "cm" ]; then
            proj_credit=CyanogenMod
        elif [ "$origin" = "faux" ]; then
            proj_credit=Faux123
        elif [ "$origin" = "bajee" ]; then
            proj_credit=RootBox
        elif [ "$origin" = "rootbox" ]; then
            proj_credit=RootBox
        else
            proj_credit=""
        fi
        # Write the changelog
        echo "$proj_credit Project name: $project" >> "$rdir"/changelog.txt
        echo "$log" | while read line
        do
             echo "  •$line" >> "$rdir"/changelog.txt
        done
        echo "" >> "$rdir"/changelog.txt
    fi
done

# Create Version Changelog
if [ "$RELEASE" == "nightly" ]
then
    echo "Generating and Uploading Changelog for Nightly"
    cp changelog.txt changelog_"$DATE".txt
    scp "$rdir"/changelog_"$DATE".txt Bajee@upload.goo.im:~/public_html/Nightlies/Changelogs
else
    echo "Generating and Uploading Changelog for Official Release"
    cp changelog.txt changelog_"$RB_BUILD".txt
    scp "$rdir"/changelog_"$RB_BUILD".txt Bajee@upload.goo.im:~/public_html/RootBox_Changelogs
fi

# Build RootBox Mako (Nexus 4)
. build/envsetup.sh;
brunch rootbox_mako-userdebug | tee $LOGS/rootbox_mako-userdebug-$(date +'%Y%m%d-%T').log;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmako=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-mako-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" Bajee@upload.goo.im:~/public_html/Nightlies/mako
else
    find "$OUT" -name *RootBox-JB-mako-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" Bajee@upload.goo.im:~/public_html/RootBox_mako_jb
fi


# Build RootBox Grouper
brunch rootbox_grouper-userdebug | tee $LOGS/rootbox_grouper-userdebug-$(date +'%Y%m%d-%T').log;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION2=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEgrouper=$OUT/$VERSION2.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-grouper-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEgrouper" Bajee@upload.goo.im:~/public_html/Nightlies/grouper
else
    find "$OUT" -name *RootBox-JB-grouper-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEgrouper" Bajee@upload.goo.im:~/public_html/RootBox_grouper_jb
fi

# Build RootBox SGH-I747
brunch rootbox_d2att-userdebug | tee $LOGS/rootbox_d2att-userdebug-$(date +'%Y%m%d-%T').log;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION3=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2att=$OUT/$VERSION3.zip

# Move the changelog into zip  & upload zip to Goo.im

if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-d2att-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2att" Bajee@upload.goo.im:~/public_html/Nightlies/d2att
else
    find "$rdir"/out/target/product -name *RootBox-JB-d2att-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2att" Bajee@upload.goo.im:~/public_html/RootBox_d2att_jb
fi

# Build RootBox SGH-T999
brunch rootbox_d2tmo-userdebug | tee $LOGS/rootbox_d2tmo-userdebug-$(date +'%Y%m%d-%T').log;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION4=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2tmo=$OUT/$VERSION4.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-d2tmo-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2tmo" Bajee@upload.goo.im:~/public_html/Nightlies/d2tmo
else
    find "$OUT" -name *RootBox-JB-d2tmo-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2tmo" Bajee@upload.goo.im:~/public_html/RootBox_d2tmo_jb
fi

# Build RootBox SGH-I535
brunch rootbox_d2vzw-userdebug | tee $LOGS/rootbox_d2vzw-userdebug-$(date +'%Y%m%d-%T').log;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION5=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2vzw=$OUT/$VERSION5.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-d2vzw-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2vzw" Bajee@upload.goo.im:~/public_html/Nightlies/d2vzw
else
    find "$OUT" -name *RootBox-JB-d2vzw-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2vzw" Bajee@upload.goo.im:~/public_html/RootBox_d2vzw_jb
fi

# Build RootBox GT-I9100
brunch rootbox_i9100-userdebug | tee $LOGS/rootbox_i9100-userdebug-$(date +'%Y%m%d-%T').log;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION6=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100=$OUT/$VERSION6.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-i9100-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100" Bajee@upload.goo.im:~/public_html/Nightlies/i9100
else
    find "$OUT" -name *RootBox-JB-i9100-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100" Bajee@upload.goo.im:~/public_html/RootBox_i9100_jb
fi

# Build RootBox GT-I9100G
brunch rootbox_i9100g-userdebug | tee $LOGS/rootbox_i9100g-userdebug-$(date +'%Y%m%d-%T').log;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION7=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100g=$OUT/$VERSION7.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-i9100g-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100g" Bajee@upload.goo.im:~/public_html/Nightlies/i9100g
else
    find "$OUT" -name *RootBox-JB-i9100g-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100g" Bajee@upload.goo.im:~/public_html/RootBox_i9100g_jb
fi

# Build RootBox GT-I9300
brunch rootbox_i9300-userdebug | tee $LOGS/rootbox_i9300-userdebug-$(date +'%Y%m%d-%T').log;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION8=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9300=$OUT/$VERSION8.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-i9300-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Bajee@upload.goo.im:~/public_html/Nightlies/i9300
else
    find "$OUT" -name *RootBox-JB-i9300-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Bajee@upload.goo.im:~/public_html/RootBox_i9300_jb
fi

# Build RootBox Maguro
brunch rootbox_maguro-userdebug | tee $LOGS/rootbox_maguro-userdebug-$(date +'%Y%m%d-%T').log;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION9=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmaguro=$OUT/$VERSION9.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    echo "No Nightly for Maguro"
else
    find "$OUT" -name *RootBox-JB-maguro-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmaguro" Bajee@upload.goo.im:~/public_html/RootBox_maguro_jb
fi

# Build RootBox Toro
brunch rootbox_toro-userdebug | tee $LOGS/rootbox_toro-userdebug-$(date +'%Y%m%d-%T').log;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION10=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEtoro=$OUT/$VERSION10.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-toro-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoro" Bajee@upload.goo.im:~/public_html/Nightlies/toro
else
    find "$OUT" -name *RootBox-JB-toro-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoro" Bajee@upload.goo.im:~/public_html/RootBox_toro_jb
fi

# Build RootBox GT-N7105
brunch rootbox_t0lte-userdebug | tee $LOGS/rootbox_t0lte-userdebug-$(date +'%Y%m%d-%T').log;

# Get Package Name
sed -i -e 's/rootbox_//' $OUT/system/build.prop
VERSION11=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEt0lte=$OUT/$VERSION11.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *RootBox-JB-t0lte-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lte" Bajee@upload.goo.im:~/public_html/Nightlies/t0lte
else
    find "$OUT" -name *RootBox-JB-t0lte-*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lte" Bajee@upload.goo.im:~/public_html/RootBox_t0lte_jb
fi

# Remove Changelogs
if [ "$RELEASE" == "nightly" ]
then
    rm "$rdir"/changelog.txt
    rm "$rdir"/changelog_"$DATE".txt
else
    rm "$rdir"/changelog.txt
    rm "$rdir"/changelog_"$RB_BUILD".txt
fi

echo "RootBox packages built, Changelog generated and everything uploaded to server!"


exit 0

