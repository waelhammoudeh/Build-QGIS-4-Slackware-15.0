#!/bin/bash

set -e

# sbo4qgis.sh:
#
# Scripts writes necessary files in locally synchronized SlackBuild org repository
# to build QGIS application on Slackware 15.0.
# Necessary files are those that need adjustment or modification to produce a
# required (or optional) package for QGIS application and/or required for a
# package upgrade or down grade.
#
# Script modifies / writes new files in the following synchronized SBo repo
# directories:
# - python/pybind11
# - gis/libspatialindex
# - graphic/graphviz
# - academic/ITK
# - gis/qgis
#
# Script copies sbopkg queuefiles from "sbo-queues" directory to sbopkg queues
# directory.
#
# Script also creates 'sbopkg' local repository and populates it under 'gis'
# category with two packages directories; "grass" and "gdal-grass" (Drivers).
#
# Scripts uses files in this repository and file system structure needs to be
# kept as is for script to find its files.
# Script assumes file system structure below:
# .
# ├── gdal-grass
# ├── grass
# ├── java-Slackware-current
# ├── sbo-queues
# ├── scripts
# │   ├── graphviz.patch
# │   ├── libspatialindex-2.0.0.tar.gz.md5
# │   ├── qgis-3.44.11.tar.bz2.md5
# │   └── sbo4qgis.sh
# ├── package-list
# └── README.md
#
# Script writes progress to log file "/tmp/sbo4qgis.sh"
#
# THIS SCRIPT IS FOR ILLUSTRATION PURPOSE, THERE IS NO GUARANTEE OF ITS
# CORRECTNESS, USE AT YOUR OWN RISK.
#
#

EXIT_SUCCESS=0
E_MISSING_PARAM=1
E_INVALID_PARAM=2
E_NOTFOUND=3
E_EMPTY=4
E_FAILED_TEST=5
E_UNKNOWN=6


# CWD=$(pwd)

REPO=/var/lib/sbopkg/SBo/15.0
SBO_ROOT=/var/lib/sbopkg

SCRIPT_DIR="$(dirname $(realpath $0))"

GRASS_DIR="$(dirname ${SCRIPT_DIR})/grass"
DRIVER_DIR="$(dirname ${SCRIPT_DIR})/gdal-grass"
QUEUE_DIR="$(dirname ${SCRIPT_DIR})/sbo-queues"

scriptName=${scriptName:-$(basename "$0")}
logFile=${logFile:-/tmp/${scriptName%.sh}.log}

touch $logFile

log() {
    # Usage: log "message"
    # Writes to stdout and appends to log file with timestamp
    echo "$(date '+%F %T') [$scriptName] $*"
    echo "$(date '+%F %T') [$scriptName] $*" >> "$logFile"
}

log "$scriptName started"

# --- chk_directories ---
# directory exist and non-empty
# Usage: chk_directories dir1 [dir2 ...]
chk_directories() {

    if [[ $# -eq 0 ]]; then
        log "Error: missing argument(s) in chk_directories()"
        return $E_MISSING_PARAM
    fi

    for dir in "$@"; do
        if [ ! -d "$dir" ]; then
            log "Error: Directory not found: $dir"
            return $E_NOTFOUND
        fi

        if [[ -z $(find "$dir" -mindepth 1 -print -quit 2>/dev/null) ]]; then
            log "Error: Directory is empty: $dir"
            return $E_EMPTY
        fi

    done

    return $EXIT_SUCCESS
}

check_sbopkg_installation() {

    local SBOPKG_DIR=/var/lib/sbopkg
    local SBOPKG_CONF=/etc/sbopkg/sbopkg.conf
    local SBO_EXEC=/usr/sbin/sbopkg

    log "Checking sbopkg installation..."

    # directory exists and is not empty
    if [[ ! -d "$SBOPKG_DIR" ]]; then
        log "Could not find sbopkg directory: $SBOPKG_DIR"
        return $E_FAILED_TEST
    fi

    if [[ -z $(find "$SBOPKG_DIR" -mindepth 1 -print -quit 2>/dev/null) ]]; then
        log "sbopkg directory is empty: $SBOPKG_DIR"
        return $E_FAILED_TEST
    fi

    # configuration file exists and is not empty
    if [[ ! -s "$SBOPKG_CONF" ]]; then
        log "Missing or empty sbopkg configuration file: $SBOPKG_CONF"
        return $E_FAILED_TEST
    fi

   # executable file exists
   if [[ ! -x "$SBO_EXEC" ]]; then
       log "Missing executable file: $SBO_EXEC"
       return $E_NOTFOUND
    fi

    log "Installation checked okay"

    return $EXIT_SUCCESS
}

# SBo Slackware 15.0 repo is required:
# check for non-empty directory: /var/lib/sbopkg/SBo/15.0
# repo must be synchronized; it must have ALL of the following files (non-empty):
# ChangeLog.txt, CHECKSUMS.md5, CHECKSUMS.md5.asc, README, SLACKBUILDS.TXT,
# TAGS.txt and TAGS.txt.gz
#
check_sbo_repository() {

    local REPO=/var/lib/sbopkg/SBo/15.0

    local REQUIRED_FILES=(
        ChangeLog.txt
        CHECKSUMS.md5
        CHECKSUMS.md5.asc
        README
        SLACKBUILDS.TXT
        TAGS.txt
        TAGS.txt.gz
    )

    log "Checking SBo repository..."

    if [[ ! -d "$REPO" ]]; then
        log "Could not find SBo repository directory: $REPO"
        return $E_NOTFOUND
    fi

    if [[ -z $(find "$REPO" -mindepth 1 -print -quit 2>/dev/null) ]]; then
        log "SBo repository directory is empty: $REPO"
        return $E_EMPTY
    fi

    local file

    for file in "${REQUIRED_FILES[@]}"; do
        if [[ ! -s "$REPO/$file" ]]; then
            log "Missing or empty required repository file: $REPO/$file"
            return $E_NOTFOUND
        fi
    done

    log "SBo repository appears synchronized."

    return $EXIT_SUCCESS
}

# lots of files to add & maybe all files we change need to be included here
check_own_files() {

    local OWN_FILES=(
       libspatialindex-2.0.0.tar.gz.md5
       qgis-3.44.11.tar.bz2.md5
       graphviz.patch

    )

    log "Ckecking our own files..."

    for file in "${OWN_FILES[@]}"; do
        if [[ ! -s "${SCRIPT_DIR}/$file" ]]; then
            log "Missing or empty own file: "${SCRIPT_DIR}"/$file"
            log "Please place and run script from same directory with md5 and patch files."
            return $E_NOTFOUND
        fi
    done

    log "Our own files checked okay"

    return $EXIT_SUCCESS

}

write_pkg_sb_info() {

    if (( $# != 2 )); then
        log "Usage: write_pkg_sb_info PACKAGE CATEGORY"
        return $E_MISSING_PARAM
    fi

    local PKG=$1
    local CAT=$2
    local PKG_DIR="$REPO/$CAT/$PKG"

    log ""
    log "Package is: $PKG"
    log "Category is: $CAT"
    log "Package Directory is: $PKG_DIR"


    chk_directories "$PKG_DIR" || return $?

    cd "$PKG_DIR" || return $?

    #
    # Find matching md5 file in script directory
    #
    local md5file

    md5file=$(find "${SCRIPT_DIR}" -maxdepth 1 -type f \
        -name "${PKG}-*.md5" | head -1)

    if [[ -z "$md5file" ]]; then
        log "Could not find md5 file for package: $PKG"
        return $E_NOTFOUND
    fi

    #
    # Read checksum and archive name
    #
    local NEW_MD5
    local ARCHIVE

    read -r NEW_MD5 ARCHIVE < "$md5file"

    log "NEW MD5 is: $NEW_MD5"

    #
    # Extract version from archive name
    #
    local NEW_VER

    NEW_VER=${ARCHIVE#$PKG-}
    NEW_VER=${NEW_VER%.tar.gz}
    NEW_VER=${NEW_VER%.tar.xz}
    NEW_VER=${NEW_VER%.tar.bz2}

    log "PACKAGE $PKG NEW VERSIION is $NEW_VER"

    #
    # Extract old version from current .info
    #
    local OLD_VER

    OLD_VER=$(grep '^VERSION=' "$PKG.info" |
        cut -d '"' -f2)

    log "Package    : $PKG"
    log "Old version: $OLD_VER"
    log "New version: $NEW_VER"

    sed \
        -e "s/$OLD_VER/$NEW_VER/g" \
        -e "s/^MD5SUM=.*/MD5SUM=\"$NEW_MD5\"/" \
        "$PKG.info" > "$PKG.info.sbopkg"

    sed \
        "s/$OLD_VER/$NEW_VER/g" \
        "$PKG.SlackBuild" > "$PKG.SlackBuild.sbopkg"

    log "Wrote $PKG.SlackBuild.sbopkg and $PKG.info.sbopkg files"

    return $EXIT_SUCCESS
}


check_sbopkg_installation || exit $?

check_sbo_repository     || exit $?

# check own directories and files
chk_directories $GRASS_DIR $DRIVER_DIR || exit $?

check_own_files || exit $?

# all checks went okay ... start work
log "$scriptName: All checks went okay, congratulation."
log ""

# fix bug in graphviz.SlackBuild failing to build when R statistical package is installed
# reason is some cpp error below:
# gv_R.cpp: In function ‘SEXPREC* SWIG_MakePtr(void*, const char*, int)’:
# gv_R.cpp:1023:3: error: ‘SET_S4_OBJECT’ was not declared in this scope; did you mean ‘NEW_OBJECT’?
# looked to me like very involved to fix!
# fix: build graphviz by disabling R support with --enable-r=no added to ./configure step
#
# copy original SlackBuild to local SlackBuild then modify local copy
ORIGNAL_SB=$REPO/graphics/graphviz/graphviz.SlackBuild
LOCAL_SB=$ORIGNAL_SB.sbopkg

# patch our local SlackBuild using patch in this directory
cp $ORIGNAL_SB $LOCAL_SB
patch -N $LOCAL_SB < "${SCRIPT_DIR}"/graphviz.patch

# fix bug in pybind11.SlackBuild
# script builds okay when package is not installed and produces skelton package
# when installed; second time it is built it hoses down your good package
# fix by adding --force-reinstall option to python3 install call

# copy original SlackBuild to local SlackBuild then modify local copy
ORIGNAL_SB=$REPO/python/pybind11/pybind11.SlackBuild
LOCAL_SB=$ORIGNAL_SB.sbopkg

cp $ORIGNAL_SB $LOCAL_SB
sed -i 's|python3 -m pip install dist/\*\.whl|python3 -m pip install --force-reinstall dist/*.whl|' \
        $LOCAL_SB

# fix ITK.SlackBuild (InsightToolkit)
# package build fails during cmake configuration
# fix by changing -DITK_USE_SYSTEM_LIBRARIES cmake setting from ON to OFF
ORIGNAL_SB=$REPO/academic/ITK/ITK.SlackBuild
LOCAL_SB=$ORIGNAL_SB.sbopkg

cp $ORIGNAL_SB $LOCAL_SB
sed -i 's/-DITK_USE_SYSTEM_LIBRARIES=ON/-DITK_USE_SYSTEM_LIBRARIES=OFF/' $LOCAL_SB

# we upgrade QGIS version (currently at 3.44.1 on SBo repo.) to version 3.44.11
# to do that we write new info and SlackBuild files using existing files and
# new information included in our qgis md5 file (qgis-3.44.11.tar.bz2.md5) in
# this directory with this script.
write_pkg_sb_info "qgis" "gis"

# newer versions of QGIS do not build against libspatialindex >= 2.1.0 for a bug
# in the library. We down grade libspatialindex from currently used by SBo 2.1.0
# to version 2.0.0
write_pkg_sb_info "libspatialindex" "gis"

# fix QGIS help box
# list items do not work
# fix make a link to directory instead of moving it
# build script was modified earlier, we modify this copy
LOCAL_SB=$REPO/gis/qgis/qgis.SlackBuild.sbopkg
sed -i 's|mv $PKG/usr/share/$PRGNAM/doc|ln -s $PKG/usr/share/$PRGNAM/doc|' $LOCAL_SB

# copy queuefiles
cp -a $QUEUE_DIR/* $SBO_ROOT/queues

log "Copied queuefiles to $SBO_ROOT/queues directory"

# create local repository and copy new directories for grass and gdal-grass drivers

SBO_ROOT=/var/lib/sbopkg

mkdir -p $SBO_ROOT/local/WH/gis
cp -a $GRASS_DIR $SBO_ROOT/local/WH/gis
cp -a $DRIVER_DIR $SBO_ROOT/local/WH/gis

# this should take care of most cases ...any others!
if [[ -d "$SBO_ROOT/local/local" && ! -L "$SBO_ROOT/local/local" ]]; then
    log "There is a local repository in your sbopkg setup, make sure to"
    log "include grass and gdal-grass directories in your repository"

elif [[ -L "$SBO_ROOT/local/local" && \
      "$(readlink "$SBO_ROOT/local/local")" != "$SBO_ROOT/local/WH" ]]; then
    log "There is a local repository in your sbopkg that does not point to WH"
    log "You need to include grass and gdal-grass directories in your"
    log "repository, or change the link to point to $SBO_ROOT/local/WH."
    log "Warning: Incomplete local repository setup."

else
    if [[ ! -L  "$SBO_ROOT/local/local" ]]; then
	ln -s "$SBO_ROOT/local/WH" "$SBO_ROOT/local/local"
	log "link created"
    fi
fi

log ""
log "Script $scriptName is done okay."
log ""

exit $EXIT_SUCCESS
