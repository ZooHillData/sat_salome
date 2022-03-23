#!/bin/bash

echo "##########################################################################"
echo "ParaView" $VERSION
echo "##########################################################################"


PVLIBVERSION=`echo ${VERSION} | awk -F. '{printf("%d.%d",$1,$2)}'`

CMAKE_OPTIONS=""

### common compiler and install settings
CMAKE_OPTIONS+=" -DCMAKE_INSTALL_PREFIX:STRING=${PRODUCT_INSTALL}"
CMAKE_OPTIONS+=" -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"
if [ -n "$SAT_DEBUG" ]; then
    CMAKE_OPTIONS+=" -DCMAKE_BUILD_TYPE:STRING=Debug"
else
    CMAKE_OPTIONS+=" -DCMAKE_BUILD_TYPE:STRING=Release"
fi
CMAKE_OPTIONS+=" -DCMAKE_CXX_FLAGS:STRING=-m64"
CMAKE_OPTIONS+=" -DCMAKE_C_FLAGS:STRING=-m64"

### common ParaView settings
CMAKE_OPTIONS+=" -DPARAVIEW_BUILD_SHARED_LIBS:BOOL=ON"
CMAKE_OPTIONS+=" -DCMAKE_INSTALL_LIBDIR:STRING=lib"
CMAKE_OPTIONS+=" -DBUILD_TESTING:BOOL=OFF"
CMAKE_OPTIONS+=" -DPARAVIEW_INSTALL_DEVELOPMENT_FILES:BOOL=ON"

### OpenGL settings
CMAKE_OPTIONS+=" -DOpenGL_GL_PREFERENCE:STRING=LEGACY"
CMAKE_OPTIONS+=" -DCATALYST_BUILD_STUB_IMPLEMENTATION:BOOL=ON"

echo "INFO: setting CATALYST"
CMAKE_OPTIONS+=" -DPARAVIEW_BUILD_PLUGIN_CatalystScriptGeneratorPlugin=ON"
CMAKE_OPTIONS+=" -DPARAVIEW_AUTOLOAD_PLUGIN_CatalystScriptGeneratorPlugin=ON"
CMAKE_OPTIONS+=" -DPARAVIEW_BUILD_CATALYST_ADAPTORS=ON"
CMAKE_OPTIONS+=" -DUSE_CATALYST:BOOL=ON"
CMAKE_OPTIONS+=" -DPARAVIEW_ENABLE_CATALYST=ON"

### spns #20550 - Headless mode
if [ -n "$PARAVIEW_HEADLESS_MODE" ]; then
    EGL_FOUND=false
    LINUX_DISTRIBUTION="$DIST_NAME$DIST_VERSION"
    case $LINUX_DISTRIBUTION in
        CO*|FD*)
            if [ -f /usr/include/EGL/egl.h ] && [ -f /usr/lib64/libEGL.so ] && [ -f /usr/lib64/libOpenGL.so ]
            then
                EGL_FOUND=true
            fi
            ;;
        *)
            ;;
    esac
    if [ $EGL_FOUND == "true" ]; then
        echo "WARNING: Building with headless mode support..."
        CMAKE_OPTIONS+=" -DVTK_OPENGL_HAS_EGL:BOOL=ON"
    else
        echo "FATAL: Headless mode cannot be set on node $LINUX_DISTRIBUTION! Please expand the PARAVIEW_HEADLESS_MODE section in script: $0"
        exit 1
    fi
fi

### Ray-tracing settings
if [ -n "$OSPRAY_ROOT_DIR" ]; then
    CMAKE_OPTIONS+=" -DPARAVIEW_ENABLE_RAYTRACING:BOOL=ON"
    CMAKE_OPTIONS+=" -DVTK_ENABLE_OSPRAY:BOOL=ON"
    CMAKE_OPTIONS+=" -Dospray_DIR:PATH=${OSPRAY_ROOT_DIR}/lib/cmake/ospray-${OSPRAY_VERSION}"
    CMAKE_OPTIONS+=" -Dembree_DIR:PATH=${EMBREE_ROOT_DIR}/lib/cmake/embree-${EMBREE_VERSION}"
else
    echo "WARNING: Paraview will be built without OSPRAY support!"
    CMAKE_OPTIONS+=" -DPARAVIEW_ENABLE_RAYTRACING:BOOL=OFF"
    CMAKE_OPTIONS+=" -DPARAVIEW_ENABLE_OSPRAY:BOOL=OFF"
fi

### VTK general settings
if [ -n "$SALOME_USE_64BIT_IDS" ]
then
    echo "WARNING: user requested VTK 64 bits encoding..."
    CMAKE_OPTIONS+=" -DVTK_USE_64BIT_IDS:BOOL=ON"
else
    CMAKE_OPTIONS+=" -DVTK_USE_64BIT_IDS:BOOL=OFF"
fi
CMAKE_OPTIONS+=" -DVTK_PYTHON_SITE_PACKAGES_SUFFIX=site-packages"
CMAKE_OPTIONS+=" -DVTKm_INSTALL_LIB_DIR=lib/paraview-${PVLIBVERSION}"

CMAKE_OPTIONS+=" -DVTK_REPORT_OPENGL_ERRORS:BOOL=OFF"

CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_VTK_RenderingLOD:INTERNAL=YES"
CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_VTK_FiltersCore:INTERNAL=YES"
CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_VTK_CommonCore:INTERNAL=YES"
CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_VTK_IOCore:INTERNAL=YES"
CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_VTK_IOEnSight:INTERNAL=YES"
CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_VTK_IOInfovis:INTERNAL=YES"

### TBB settings (in case of a system installation, TBB will be detected automatically)
if [ -n "$TBB_ROOT_DIR" ]
then
    CMAKE_OPTIONS+=" -DTBB_ROOT:PATH=${TBB_ROOT_DIR}"
fi

### Qt settings
CMAKE_OPTIONS+=" -DPARAVIEW_USE_QT:BOOL=ON"
CMAKE_OPTIONS+=" -DVTK_BUILD_QT_DESIGNER_PLUGIN:BOOL=OFF"

### Python settings
CMAKE_OPTIONS+=" -DPARAVIEW_USE_PYTHON:BOOL=ON"
CMAKE_OPTIONS+=" -DVTK_WRAP_PYTHON:BOOL=ON"
if [ "${PYTHON_ROOT_DIR}" != "/usr" ]
then
    CMAKE_OPTIONS+=" -DPython3_INCLUDE_DIR:STRING=${PYTHON_ROOT_DIR}/include/python${PYTHON_VERSION}"
    CMAKE_OPTIONS+=" -DPython3_LIBRARY:STRING=${PYTHON_ROOT_DIR}/lib/libpython${PYTHON_VERSION}.so"
fi
CMAKE_OPTIONS+=" -DVTK_PYTHON_FULL_THREADSAFE:BOOL=ON"
CMAKE_OPTIONS+=" -DVTK_NO_PYTHON_THREADS:BOOL=OFF"
CMAKE_OPTIONS+=" -DVTK_PYTHON_VERSION:STRING=3"

### Java settings
CMAKE_OPTIONS+=" -DVTK_WRAP_JAVA:BOOL=OFF"

### MPI settings
if [ -n "$SAT_HPC" ]
then
    CMAKE_OPTIONS+=" -DPARAVIEW_USE_MPI:BOOL=ON"
    if [ -n "$MPI_ROOT_DIR" ]; then
	CMAKE_OPTIONS+=" -DCMAKE_CXX_COMPILER:STRING=${MPI_CXX_COMPILER}"
	CMAKE_OPTIONS+=" -DCMAKE_C_COMPILER:STRING=${MPI_C_COMPILER}"
    fi
    CMAKE_OPTIONS+=" -DVTK_SMP_IMPLEMENTATION_TYPE=OpenMP -DVTKm_ENABLE_OPENMP=ON"
    CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_VTK_FiltersParallelMPI=YES"
    CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_VTK_ParallelMPI=YES"
    CMAKE_OPTIONS+=" -DMPI_C_FOUND=${MPI_C_FOUND}"
elif [ -n "$VTK_SMP_IMPLEMENTATION_TYPE" ]
then
    echo "WARNING: VTK_SMP_IMPLEMENTATION_TYPE environment variable was found...."
    CMAKE_OPTIONS+=" -DPARAVIEW_USE_MPI:BOOL=OFF"
    CMAKE_OPTIONS+=" -DCMAKE_CXX_COMPILER:STRING=`which g++`"
    CMAKE_OPTIONS+=" -DCMAKE_C_COMPILER:STRING=`which gcc`"
    if [[ $VTK_SMP_IMPLEMENTATION_TYPE = "sequential" ]]
    then
        echo "WARNING: sequential approach will be used..."
        CMAKE_OPTIONS+=" -DPARAVIEW_USE_MPI:BOOL=OFF"
        CMAKE_OPTIONS+=" -DCMAKE_CXX_COMPILER:STRING=`which g++`"
        CMAKE_OPTIONS+=" -DCMAKE_C_COMPILER:STRING=`which gcc`"
    elif [[ $VTK_SMP_IMPLEMENTATION_TYPE = "TBB" ]]
    then
        echo "WARNING: VTK_SMP_IMPLEMENTATION_TYPE was set to: TBB..."
        CMAKE_OPTIONS+=" -DVTK_SMP_IMPLEMENTATION_TYPE=TBB -DVTKm_ENABLE_TBB:BOOL=ON"
    elif [[ $VTK_SMP_IMPLEMENTATION_TYPE = "OpenMP" ]]
    then
        echo "WARNING: VTK_SMP_IMPLEMENTATION_TYPE was set to: OpenMP..."
        CMAKE_OPTIONS+=" -DVTK_SMP_IMPLEMENTATION_TYPE=OpenMP -DVTKm_ENABLE_OPENMP:BOOL=ON"
    else
        echo "ERROR: Unknown ${VTK_SMP_IMPLEMENTATION_TYPE} option.... aborting!"
        exit 1
    fi
else
    echo "WARNING: MPI will not be supported!"
    CMAKE_OPTIONS+=" -DPARAVIEW_USE_MPI:BOOL=OFF"
    CMAKE_OPTIONS+=" -DCMAKE_CXX_COMPILER:STRING=`which g++`"
    CMAKE_OPTIONS+=" -DCMAKE_C_COMPILER:STRING=`which gcc`"
fi

### HDF5 settings
CMAKE_OPTIONS+=" -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5:BOOL=ON"
###CMAKE_OPTIONS+=" -DHDF5_DIR:PATH=${HDF5_ROOT_DIR}/share/cmake/hdf5"
CMAKE_OPTIONS+=" -DHDF5_USE_STATIC_LIBRARIES:BOOL=OFF"
CMAKE_OPTIONS+=" -DHDF5_ROOT:PATH=${HDF5_ROOT_DIR}"
CMAKE_OPTIONS+=" -DHDF5_hdf5_LIBRARY_RELEASE=${HDF5_ROOT_DIR}/lib"
CMAKE_OPTIONS+=" -DHDF5_hdf5_hl_LIBRARY_RELEASE=${HDF5_ROOT_DIR}/lib/libhdf5_hl.so"
CMAKE_OPTIONS+=" -DHDF5_hdf5_CXX_LIBRARY_RELEASE=${HDF5_ROOT_DIR}/lib/libhdf5_cpp.so"
CMAKE_OPTIONS+=" -DHDF5_HL_LIBRARY=${HDF5_ROOT_DIR}/lib/libhdf5_hl.so"
CMAKE_OPTIONS+=" -DHDF5_C_INCLUDE_DIR=${HDF5_ROOT_DIR}/include"
CMAKE_OPTIONS+=" -DHDF5_HL_LIBRARY=${HDF5_ROOT_DIR}/lib/libhdf5_hl.so"
CMAKE_OPTIONS+=" -DHDF5_C_LIBRARY=${HDF5_ROOT_DIR}/lib/libhdf5.so"
CMAKE_OPTIONS+=" -DHDF5_INCLUDE_DIR=${HDF5_ROOT_DIR}/include"
### CGNS
CMAKE_OPTIONS+=" -DVTK_MODULE_USE_EXTERNAL_ParaView_cgns:BOOL=ON"
if [ "$CGNS_ROOT_DIR" != "/usr" ]
then
    CMAKE_OPTIONS+=" -DCGNS_INCLUDE_DIR:PATH=${CGNS_ROOT_DIR}/include"
    CMAKE_OPTIONS+=" -DCGNS_LIBRARY:PATH=${CGNS_ROOT_DIR}/lib/libcgns.so"
fi
CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_ParaView_cgns:INTERNAL=YES"
CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_ParaView_VTKExtensionsCGNSReader:INTERNAL=YES"
CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_ParaView_VTKExtensionsCGNSWriter:INTERNAL=YES"

### VisIt Database bridge settings
CMAKE_OPTIONS+=" -DPARAVIEW_ENABLE_VISITBRIDGE:BOOL=ON"

### Boost settings
CMAKE_OPTIONS+=" -DBOOST_ROOT:PATH=${BOOST_ROOT_DIR}"
CMAKE_OPTIONS+=" -DBoost_NO_BOOST_CMAKE:BOOL=ON"
CMAKE_OPTIONS+=" -DBoost_NO_SYSTEM_PATHS:BOOL=ON"

### gl2ps settings
CMAKE_OPTIONS+=" -DVTK_MODULE_USE_EXTERNAL_VTK_gl2ps:BOOL=OFF"

### libxml2 settings
if [ -n "$LIBXML2_ROOT_DIR" ]
then
    # with a native libxml2, do not use these options
    CMAKE_OPTIONS+=" -DVTK_MODULE_USE_EXTERNAL_VTK_libxml2:BOOL=ON"
    if [ "${LIBXML2_ROOT_DIR}" != "/usr" ]
    then
        CMAKE_OPTIONS+=" -DLIBXML2_INCLUDE_DIR:STRING=${LIBXML2_ROOT_DIR}/include/libxml2"
        CMAKE_OPTIONS+=" -DLIBXML2_LIBRARIES:STRING=${LIBXML2_ROOT_DIR}/lib/libxml2.so"
        CMAKE_OPTIONS+=" -DLIBXML2_XMLLINT_EXECUTABLE=${LIBXML2_ROOT_DIR}/bin/xmllint"
    fi
fi

### freetype settings
CMAKE_OPTIONS+=" -DVTK_MODULE_USE_EXTERNAL_VTK_freetype:BOOL=ON"
if [ -n "$FREETYPE_ROOT_DIR" ]
then
    # with a native freetype, do not use these options
    CMAKE_OPTIONS+=" -DFREETYPE_INCLUDE_DIRS:STRING=${FREETYPE_ROOT_DIR}/include/freetype2"
    CMAKE_OPTIONS+=" -DFREETYPE_LIBRARY:STRING=${FREETYPE_ROOT_DIR}/lib/libfreetype.so"
fi

### Extra options
CMAKE_OPTIONS+=" -DPARAVIEW_PLUGINS_DEFAULT:BOOL=ON"
CMAKE_OPTIONS+=" -DPARAVIEW_PLUGIN_ENABLE_Moments:BOOL=OFF"
CMAKE_OPTIONS+=" -DPARAVIEW_PLUGIN_ENABLE_SLACTools:BOOL=OFF"
CMAKE_OPTIONS+=" -DPARAVIEW_PLUGIN_ENABLE_PacMan:BOOL=OFF"
CMAKE_OPTIONS+=" -DPARAVIEW_PLUGIN_ENABLE_pvblot:BOOL=OFF"

# allow additional plugins
CMAKE_OPTIONS+=" -DVTK_ALL_NEW_OBJECT_FACTORY:BOOL=ON"

# Openturns:
if [ -n "$OT_VERSION" ]; then
    function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }
    if version_ge $OT_VERSION "1.17" ; then
        echo "INFO: Adding OpenTURNS version ${OT_VERSION} support..."
        CMAKE_OPTIONS+=" -DPARAVIEW_ENABLE_OPENTURNS=ON"
        CMAKE_OPTIONS+=" -DOpenTURNS_DIR=$OT_ROOT_DIR/lib/cmake/openturns"
    else
        echo "WARNING: OpenTURNS ${OT_VERSON} is not supported with current ParaView build..."
    fi
else
    echo "WARNING: No OpenTURNS environment variable is found..."
fi

# GDAL see bos #26944
if [ -n "$GDAL_ROOT_DIR" ]; then
    echo "INFO: switching ON GDAL"
    CMAKE_OPTIONS+=" -DPARAVIEW_ENABLE_GDAL:BOOL=ON"
    if [ "$GDAL_ROOT_DIR" != "/usr" ]; then
        CMAKE_OPTIONS+=" -DGDAL_ROOT_DIR=$GDAL_ROOT_DIR"
	CMAKE_OPTIONS+=" -DGDAL_LIBRARY=$GDAL_ROOT_DIR/lib/libgdal.so"
	CMAKE_OPTIONS+=" -DGDAL_INCLUDE_DIR=$GDAL_ROOT_DIR/include"
    fi
    CMAKE_OPTIONS+=" -DPARAVIEW_GENERATE_PROXY_DOCUMENTATION:BOOL=ON"
    CMAKE_OPTIONS+=" -DPARAVIEW_PLUGIN_ENABLE_GeographicalMap:BOOL=ON"
fi

# NETCDF see bos #26944
if [ -n "$NETCDF_ROOT_DIR" ]; then
    echo "INFO: switching ON NETCDF"
    CMAKE_OPTIONS+=" -DVTK_MODULE_USE_EXTERNAL_VTK_netcdf:BOOL=ON"
    if [ "NETCDF_ROOT_DIR" != "/usr" ]; then
        CMAKE_OPTIONS+=" -DNETCDF_ROOT_DIR=$NETCDF_ROOT_DIR"
	CMAKE_OPTIONS+=" -Dnetcdf_DIR=$NETCDF_ROOT_DIR/lib/cmake/netCDF"
#        CMAKE_OPTIONS+=" -DCMAKE_PREFIX_PATH=$NETCDF_ROOT_DIR/lib/cmake/netCDF"
    fi
    CMAKE_OPTIONS+=" -DVTK_MODULE_ENABLE_VTK_FiltersParallelGeometry=YES"
fi

echo
echo "*** cmake" ${CMAKE_OPTIONS}
cmake ${CMAKE_OPTIONS} $SOURCE_DIR
if [ $? -ne 0 ]
then
    echo "ERROR on cmake"
    exit 1
fi

# SPN #18779
MEMTOTAL=$(cat /proc/meminfo | grep MemTotal | awk ' {print $2}')
MEMTHRESHOLD=15000000
if [ "$MEMTOTAL" -lt "$MEMTHRESHOLD" ] || [ -n "$SAT_PARAVIEW_FORCE_MAKE_J1" ]; then
    echo "WARNING: ParaView build requires large memory for VTKm compilation step..."
    echo "WARNING: ParaView build requires large memory for VTKm compilation step..."
    echo "WARNING: Available RAM is smaller than 16GB... using -j 1"
    MAKE_OPTIONS="-j 1 "
fi

echo
echo "*** make" $MAKE_OPTIONS
make $MAKE_OPTIONS
if [ $? -ne 0 ]
then
    echo "ERROR on make"
    exit 2
fi

echo
echo "*** make install"
make install
if [ $? -ne 0 ]
then
    echo "ERROR on make install"
    exit 3
fi

echo
echo "########## END"
