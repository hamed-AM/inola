#!.local/bin/bash
#
# Try downloading multiple times before crashing whole pipeline
#
#   $ ./download-multi-try downloader lockfile input-url downloaded-name
#
# Due to temporary network problems, a download may fail suddenly, but
# succeed in a second try a few seconds later. Without this script that
# temporary glitch in the network will permanently crash the pipeline and
# it can't continue. The job of this script is to be patient and try the
# download multiple times before crashing the whole pipeline.
#
# LOCK FILE: Since there is ultimately only one network port to the outside
# world, downloading is done much faster in serial, not in parallel. But
# the pipeline's processing may be done in parallel (with multiple threads
# needing to download different files at the same time). Therefore, this
# script uses the `flock' program to only do one download at a time. To
# benefit from it, any call to this script must be given the same lock
# file.
#
# Original author:
#     Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Contributing author(s):
# Copyright (C) 2019, Mohammad Akhlaghi.
#
# This script is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This script is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details. See <http://www.gnu.org/licenses/>.





# Script settings
# ---------------
# Stop the script if there are any errors.
set -e





# Input arguments and necessary sanity checks.
inurl="$3"
outname="$4"
lockfile="$2"
downloader="$1"
if [ "x$downloader" = x ]; then
    echo "$0: downloader (first argument) not given."; exit 1;
fi
if [ "x$lockfile" = x ]; then
    echo "$0: lock file (second argument) not given."; exit 1;
fi
if [ "x$inurl" = x ]; then
    echo "$0: full input URL (third argument) not given."; exit 1;
fi
if [ "x$outname" = x ]; then
    echo "$0: output name (fourth argument) not given."; exit 1;
fi





# Try downloading multiple times before crashing
counter=0
maxcounter=10
while [ ! -f "$outname" ]; do

    # Increment the counter. We need the `counter=' part here because
    # without it the evaluation of arithmetic expression will be like and
    # error and the script is set to crash on errors.
    counter=$((counter+1))

    # If we have passed a maximum number of trials, just exit with
    # a failed code.
    if (( counter > maxcounter )); then
        echo
	echo "Failed $maxcounter download attempts: $outname"
        echo
	exit 1
    fi

    # If this isn't the first attempt print a notice and wait a little for
    # the next trail.
    if (( counter > 1 )); then
	tstep=$((counter*5))
        echo "Download trial $counter for '$outname' in $tstep seconds."
        sleep $tstep
    fi

    # Attempt downloading the file (one-at-a-time).
    flock "$lockfile" bash -c \
          "if ! $downloader -O$outname $inurl; then rm -f $outname; fi"
done





# Return successfully
exit 0
