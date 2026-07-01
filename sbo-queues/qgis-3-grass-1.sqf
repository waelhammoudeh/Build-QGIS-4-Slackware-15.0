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

# libsvm below:
OpenBLAS
doctest
xsimd
python3-flit_core
python3-installer
python3-wheel
python3-pyproject-hooks
python3-build
python3-packaging-opt
python3-setuptools-opt
python3-pyproject-metadata
python3-mesonpy
python3-cython-opt
python3-numpy
python3-gast
python3-beniget
python3-pythran
python3-typing-extensions
python3-flit_scm
python3-exceptiongroup
python3-calver
python3-trove-classifiers
python-zipp
python-importlib_metadata
python3-setuptools-scm-opt
python3-pluggy
python3-pathspec
python3-editables
python3-hatchling
python3-hatch_vcs
python3-scikit-build-core
pybind11
python3-scipy
libsvm
