# grass ver. 8.4.2 requirements
# this file started as pdal.sqf

# pdal queue file


# lapack package requires blas
blas
lapack

# use libsvm.sqf file. has a lot of python packages - some installed!
# use -k option with sbopkg call ;; -k MUST be first option as:
# ~$ sbopkg -k -i grass-req.sqf
# @libsvm

# failed to build libsvm.sqf on python3-scipy build !!
# run sbopkg -i libsvm.sqf alone went successfully

unixODBC

R

# gtest is needed for pdal
gtest


# install libdraco
ghc_filesystem
tinygltf
libdraco

# jsoncpp and laszip are recommended in pdal README file
# laszip installed already, install jsoncpp
jsoncpp

python3-dateutil

# this is time consuming build - moved out.
# @wxPython4

@python3-matplotlib
@termcolor

pdal
