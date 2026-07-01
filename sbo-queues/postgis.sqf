python3-flit_core
python3-installer
python3-wheel
python3-pyproject-hooks
python3-build
abseil-cpp
protobuf3
protobuf-c

# should match prevoius listing in qgis-1-gdal-1.sqf
# postgresql18

python3-packaging-opt
# python3-meson-opt
python3-setuptools-opt
python3-pyproject-metadata
python3-mesonpy
python3-cython-opt
python3-numpy
proj
libgeotiff
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

# use same option as qgis-1-gdal-1.sqf
netcdf | HDF4=YES

graphviz
uriparser
libkml
xerces-c

gdal | OPENCL=yes JAVA=yes
# gdal | JAVA=yes

postgis | PGADMIN=yes
