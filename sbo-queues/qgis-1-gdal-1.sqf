# installed Orocale jdk-25 using Pat's build script from Slackware-current. (NOTE **CURRENT)

# Note sbopkg downloaded source file with name "download" into its cache directory!
# had to rename source file to:libecwj2-3.3-2006-09-06.zip
# the name is from the link on the slackbuilds.org page and libecwj2.info file.

libecwj2

python3-flit_core
python3-installer
python3-pyproject-hooks
python3-build
python3-packaging-opt
python3-wheel
# python3-meson-opt
python3-setuptools-opt
python3-pyproject-metadata
python3-mesonpy
python3-cython-opt
python3-numpy
proj

proj-data

libgeotiff

cppunit
lua

podofo
libminizip
freexl
geos
librttopo
libspatialite
cmake-opt
libaec
hdf5
hdf
netcdf | HDF4=YES

gts
DevIL

pangox-compat
gtkglext

# graphviz FAILED to build with R version 4.6.0 installed
# build graphviz BEFORE R.
graphviz
uriparser
libkml
xerces-c

# IMPORTANT: If postgresql is not installed, create group and user for postgres
# and uncomment line below.
# See file: /var/lib/sbopkg/SBo/15.0/system/postgresql18/README
# postgresql18

# sbopkg queue file for OpenSceneGraph, enable optional packages (most of them)

fox-toolkit

# moved gtkglext BEFORE graphviz
# pangox-compat
# gtkglext

libgta

laszip
libLAS

# nvidia-texture-tools plugin to be created by OpenSceneGraph
nvidia-texture-tools

dcmtk
collada-dom
OpenSceneGraph

# include optional packages for SFCGAL ;; OpenSenceGraph
# @SFCGAL.sqf

CGAL5
SFCGAL

# avoid libheif build for slackware 15.0

# OPENCL=yes (requires either nvidia-driver or amd-app-sdk with suitable GPU hardware to run).

# to enable opencl uncomment line AND comment out the other line.
gdal | OPENCL=yes JAVA=yes
# gdal | JAVA=yes
