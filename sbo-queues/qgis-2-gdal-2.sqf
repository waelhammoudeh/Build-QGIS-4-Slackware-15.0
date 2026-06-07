# rebuilt OpenSceneGraph so it includes - generates - gdal plugin
OpenSceneGraph | BUILD=2

# above rebuild may affect SFCGAL and gdal
# so we rebuild SFCGAL and gdal

SFCGAL | BUILD=2

# gdal | JAVA=yes BUILD=2
gdal | OPENCL=yes JAVA=yes BUILD=2
