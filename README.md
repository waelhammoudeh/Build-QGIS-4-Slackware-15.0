# Build QGIS on Slackware 15.0

This is an update for my recipe and script to reflect changes made to build scripts
on SlackBuilds.org repository, I was very glad to see those changes and thank you
for all maintainers.

This recipe was last tested to build QGIS version 3.44.11 on Slackware64 15.0 on
Tuesday June 30th/2026.

If you already built a working QGIS 3.44.11 package using my earlier recipe and
script, there is nothing new for you here.

If you tried and were unable to build a working QGIS package, you have your work
cut out for you! Then you need to remove ALL packages that were built before you
were forced to stop plus remove your local sbopkg directory with all its sub-directories.
Then do a new rsync with SlackBuilds repository using `sbopkg -r` command. You then
can follow instructions below to build QGIS.

I had to rebuild QGIS on my system from SlackBuilds.org recently, [sbopkg](https://sbopkg.org/)
program was utilized for this build. This was time consuming and this writing is here in hope
of helping somebody.

This build was done on a clean Slackware 15.0 installation updated recently with
slackpkg tool. (clean == no multilib and no any other packages).

In this process I built QGIS version 3.44.11 (currently at 3.44.1 on SBo), and
added a new package for "gdal-grass" drivers with its required SlackBuild files (this
was split from upstream).

Packages were built with their required and **most optional** packages. Some options
were passed to SlackBuild script for some packages.

Without specifics to hardware; you need a multi-core machine with decent amount
of memory and disk space plus internet connection for this build.

**To help speed up the build process,** consider mounting your `/tmp` directory
as a `tmpfs` filesystem if your system has sufficient RAM available. This can
significantly reduce disk I/O during package builds.

For example, on a system with 48 GB of RAM, I allocate 24 GB to `/tmp` by adding
the following entry to `/etc/fstab`:

```
tmpfs        /tmp        tmpfs        defaults,size=24G,mode=1777,nosuid,nodev 0 0
```

Adjust the `size=` parameter as appropriate for your system and workload.

I assume you have some knowledge of Slackware package handling, so there is not
much details here. In addition you need to install sbopkg and know its basic usage.
Read about sbopkg usage on [docs.slackware.com here](https://docs.slackware.com/howtos:slackware_admin:building_packages_with_sbopkg).

A Slackware package for sbopkg is [here](https://github.com/sbopkg/sbopkg/releases/download/0.38.3/sbopkg-0.38.3-noarch-1_wsr.tgz).

This build required changes to some files from SlackBuilds org. A bash script is
provided here to write those changed files to your system. See "sbo4qgis.sh" below.

This build recipe will not age well, as SlackBuild scripts and source packages
change over time. The instructions here were last tested during a successful QGIS
build on Tuesday June 30th/2026.

The versions of all packages used and produced during that build are listed in the
`package-list` file in this repository.

Since I do not upgrade software very often, this repository will not receive frequent
updates.


**About sbopkg:**

This is a great application to add to any slacker tool box. Even with the lack of
documentation it was a great help in building this large package. I may not have a
complete understanding of sbopkg usage and this is why this process seems to be
done the hard way! I start by explaining my simplified understanding of sbopkg.

Sbopkg has two interfaces, curses based and CLI, I use the CLI interface here, it
has many options - see the man page for full list. The important options I use are
quoted below from the manual page:

    -B   Process the packages or queues without prompting for confirmation first.

         If options are specified, the order of precedence will be: command line options,
         options specified in the repository and then queuefile options.


    -i PACKAGE(s)/QUEUE(s)
        Download, build, and install packages of the argument(s) from the active repository.

        See the -b option for details since, other than the installation, these two options
        operate similarly.

        Note that by carefully considering the order of the packages listed and/or using
        queuefiles, the user may be able  to  install  dependencies  in  the  right order
        before the final application is built.

    -k  When used together with -b, -d, or -i, this option tells sbopkg to skip (i.e.,
        don't process) any package it finds to be already installed.

        Please  note  that only a name comparison is performed, so when this option is
        specified sbopkg will also omit the build of different versions of installed packages.

    -V VERSION
        Set the repository and branch to use.

        For a list of valid versions, invoke sbopkg as

        # sbopkg -V ?

        See the sbopkg.conf(5) man page for more information about the ``local'' repository.

        The  VERSION  format  is repository/branch (e.g., SBo/xxxSWVERxxx).  If the repository
        is omitted, sbopkg will first look for the specified branch in the default repository.
        If that attempt fails, sbopkg will look for the first matching branch in any repository.

I use package specific build options (options passed to SlackBuild scripts) when
building few packages in my queuefiles, each time sbopkg sees an option, it prompts
for confirmation, to avoid that prompt I use -B option. As an example
for my usage to pass options to build script look in queuefile "qgis-1-gdal-1.sqf"
in the bottom of the file I pass "OPENCL=yes" and "JAVA=yes" to gdal.SlackBuild and
here is that line: (this is one of two you may need to adjust/edit by the way)
```
gdal | OPENCL=yes JAVA=yes
```
If -B option is not used, sbopkg will prompt you to confirm passing "OPENCL=yes"
and "JAVA=yes" options to gdal SlackBuild script.

By default sbopkg will build and install ALL packages in a queuefile; the -k option
changes this behaviour - which is what I want most of the time - with this option
use if a package is installed, sbopkg does not build it again.

The -i option is to build and install the package in one go, I build a package to
install it and most likely it is required to build the next package. This option
is used in almost all my sbopkg calls. You could just build a package without
installation with the -b option.

The -V option is used to tell sbopkg which repository to use in that command, we
use this when building packages from our local repository.

When using multiple options, the order they are listed is important, the three I
use the most should be listed in this order { -B -k -i queuefile }, if -V is used it
must be the first option listed.

Sbopkg allows you to change files and build your own packages, it does that through
the **concept of local and original** file. The original file is the unchanged retrieved
file from SBo server. Every time a file is retrieved from the server an md5 for it
is calculated and recorded by sbopkg. Every time this file is used, sbopkg checks
its md5, if it does not match its record, then the file is deleted and a new copy
is retrieved from the server.

You can stop this behaviour by adding the **magic ".sbopkg" extension** to your
changed file name. That is suppose we changed a build script file such as the
"qgis.SlackBuild" file to change version number for example, to prevent sbopkg
from removing our changed file we must rename it with ".sbopkg" extension
appended to its original name like: "qgis.SlackBuild.sbopkg", to sbopkg this is a
local file, it will not remove it. This concept applies to all files in the package
directory: "qgis.info" becomes "qgis.info.sbopkg", even "doinst.sh" can be changed
to "doinst.sh.sbopkg" and so on. In the last case you need to make change to you
SlackBuild script to take effect such as:

  cat $CWD/doinst.sh.sbopkg  > $PKG/install/doinst.sh


When sbopkg builds a package with any local file in its directory, it will prompt
you for (L)ocal or (O)riginal file usage for that file, if there are multiple files
with ".sbopkg" in that directory, you will get prompted for each one of them, and
no, using -B option does not change the prompt in this case.

The manual page (man sbopkg) option -V tells you a little about local directory. You
can add your own packages in a local directory - under categories like SBo server.
The program recognizes local directory under only one path and that is under its
root directory; this path is: "/var/lib/sbopkg/local/local" that is not a typo, path
ends with two local entries!, it is not unusual to have the last "local" entry as
a link to another directory on your file system.

The log files from sbopkg are very useful, however they are huge, you want to enable
when needed only.


Building packages in this process is done using sbopkg queuefiles, find those in
"sbo-queues" directory in this repository. Initial queuefiles were generated with
**"sqg"** tool included with "sbopkg" package then edited to include optional packages
along with some SlackBuild script options for some packages.

**You may need to adjust my SlackBuild options in some queuefiles** namely the options
"OPENCL=yes" and "JAVA=yes" for gdal package, and "OPENCL=yes" for qgis package.
Those options depend on your hardware and your "Java" installation.


## Prepare Your System:

**Install and Configure Sbopkg:**

If you have a previous installation of "sbopkg" on your system, remove "SBo/15.0"
directory and sub-directories to start with a fresh unmodified repository. This
is because `sbopkg -r` does not remove modified files with .sbopkg extension.


If you did not install sbopkg yet; download the ready made Slackware [sbopkg package](https://github.com/sbopkg/sbopkg/releases/download/0.38.3/sbopkg-0.38.3-noarch-1_wsr.tgz) and install it in your system.

Configure and synchronize with SlackBuilds.org repository with:
```
  ~# sbopkg -r
```

this creates default directories and configuration files and downloads SlackBuilds
repository to your computer (size about 382 MB). Do this only **once** during this
process.

**Add an export** line/statement in your "/etc/sbopkg/sbopkg.conf" to set the value for
number of jobs (parallel build) using MAKEFLAGS environment variable such as:

export MAKEFLAGS="-j*n*"

replace *n* with value to use on your system - it is **not** always "$($(nproc) + 1)".

I have a machine with nproc=72 and use "27" as *n* value in this export line:
```
# added for global number of jobs W.H.
export MAKEFLAGS="-j27"
```

Use my script "sbo4qgis.sh" to populate your local SBo repository with changed files,
copy queuefiles and setup local personal repository for you with my two new packages
for "grass" and "gdal-grass" drivers.


**Update Slackware 15.0:**

Some source code uses fortran, make sure your system has "gcc-gfortran" package
installed, if not install it with:
```
  ~# slackpkg install gcc-gfortran
```

Update and upgrade Slackware64 15.0 with "slackpkg":

```
  ~# slackpkg update
  ~# slackpkg upgrade-all
```

**Non-sbopkg installs:**

Start the build process by installing "postgresql18" and Oracle "Jdk" without
sbopkg.

If postgresql is not installed in your system read the installation instructions found
in README file in directory "/var/lib/sbopkg/SBo/15.0/system/postgresql18/" follow
instruction to create group and user "postgres" and **uncomment line** with postgresql18
in queuefiles "qgis-1-gda-1.sqf" and "postgis.sqf".

Any Postgresql version >= 14.23 is okay. You may want the version in queuefiles to
match that installed in your system.

Postgresql is an optional package for GDAL; however it is required for QGIS
(it requires postgis)

Java is an optional package for GDAL. I install Oracle Java SDK version 25.0 using
Pat's build script from **slackware-current** not 15.0. Get Pat's Java SlackBuild
script from [here](https://mirror.slackbuilds.org/slackware/slackware64-current/extra/java/)
and the source code from [Oracle site](https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.tar.gz)
JDK-25 is the current long term support version.
I did not try any other Java for this build.


**Changes and sbo4qgis.sh script:**

Three packages required changes for their build to go through for different reasons.
In addition a new SlackBuild script for "gdal-grass" drivers was added. The script
"sbo4qgis.sh" will write ALL required files to your system, maintain the file system
structure found on the repository since the script uses files included there.

**Applied fixes:**

  - ITK.SlackBuild (InsightToolkit)

    Problem: build failed during cmake configuration

    Fix: changed cmake setting "-DITK_USE_SYSTEM_LIBRARIES" from ON to OFF.

  - qgis.SlackBuild:

    Problem: in addition to upgrade package; the Help box list items were dead.

    Fix: make a link to "doc" directory instead of moving it.

  - libspatialindex.SlackBuild

    Problem: newer QGIS do not build against version >= 2.1.0

    Fix: down graded package to version 2.0.0

**Options you may need to adjust in queuefiles:**

After you run "sbo4qgis.sh" script you need to apply your own changes to my queuefiles
now in your sbopkg queues directory: "/var/lib/sbopkg/queues/" for options I have
set or not set that do not agree with your system.

Option lines that you may need to adjusment are listed below along with the queuefiles
they are in. Note that each option should match across ALL queuefiles.


```
# postgresql18
in queuefiles: "qgis-1-gdal-1.sqf" and "postgis.sqf"
```
```
# gdal | OPENCL=yes JAVA=yes
in queuefiles: "qgis-1-gdal-1.sqf", "qgis-2-gdal-2.sqf" "postgis.sqf" "qgis-9-optional.sqf"
```

```
# qgis | OPENCL=yes
in queuefile: "qgis-8-qgis.sqf"
```

## Avoid a bang on start:
**Wrong source filename for libecwj2 Package:**
Sbopkg downloads source files to its cache directory, the source for this package
gets the funny name **download** then sbopkg throws an error! One way to avoid
this error is to download the source with sbopkg -d switch (option) which fetches
the source for the specified package in its info file then rename the file after
the transfer, this is done with the following two commands:
```
  ~# sbopkg -B -d libecwj2
```
When prompted answer (N)o to abort
```
  ~# mv /var/cache/sbopkg/download /var/cache/sbopkg/libecwj2-3.3-2006-09-06.zip
```

Use sbopkg to process copied queuefiles - only those starting with qgis-n-* -
where *n* is a number from 0 to 9 **in this order**. Other queuefiles are nested inside
those numbered ones, do not remove them.

Here is a list of all commands to all queuefiles:
```
  # sbopkg -B -i qgis-0-devel.sqf       ---> NO -k

  # sbopkg -B -k -i qgis-1-gdal-1.sqf

  # sbopkg -B -i qgis-2-gdal-2.sqf       ---> NO -k

  # sbopkg -B -k -i qgis-3-grass-1.sqf

  # sbopkg -B -k -i qgis-4-grass-2.sqf

  # sbopkg -B -k -i qgis-5-grass-3.sqf

  # sbopkg -i grass
```

After building grass package execute commands below:
```
  # echo /opt/grass/lib > /etc/ld.so.conf.d/grass.conf && ldconfig
```

then continue with the rest of queuefiles below:

```
  # sbopkg -V local -B -i qgis-6-gdal-grass.sqf

  # sbopkg -B -k -i qgis-7-req.sqf

  # sbopkg -B -k -i qgis-8-qgis.sqf

  # sbopkg -B -k -i qgis-9-optional.sqf

```

Total packages built in this process were 154 packages on my system.

Wael Hammoudeh

June 30/2026
