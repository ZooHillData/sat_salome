#!/bin/bash

echo "##########################################################################"
echo "PERSALYS" $VERSION
echo "##########################################################################"

if [ -n "$SAT_HPC" ]  && [ -n "$MPI_ROOT_DIR" ]; then
    echo "WARNING: setting CC and CXX environment variables and target MPI wrapper"
    CMAKE_OPTIONS+=" -DCMAKE_CXX_COMPILER:STRING=${MPI_CXX_COMPILER}"
    CMAKE_OPTIONS+=" -DCMAKE_C_COMPILER:STRING=${MPI_C_COMPILER}"
    CMAKE_OPTIONS+=" -DMPI_C_FOUND=$MPI_C_FOUND"
fi

CMAKE_OPTIONS=""
CMAKE_OPTIONS+=" -DCMAKE_INSTALL_PREFIX:STRING=$PRODUCT_INSTALL"
CMAKE_OPTIONS+=" -DCMAKE_INSTALL_LIBDIR:STRING=lib"
CMAKE_OPTIONS+=" -DADAO_ROOT_DIR=$ADAO_ROOT_DIR"
CMAKE_OPTIONS+=" -DBOOST_ROOT:PATH=$BOOST_ROOT_DIR"
CMAKE_OPTIONS+=" -DGUI_ROOT_DIR=$GUI_ROOT_DIR"
CMAKE_OPTIONS+=" -DSalomeGUI_DIR=$GUI_ROOT_DIR/adm_local/cmake_files"
CMAKE_OPTIONS+=" -DKERNEL_ROOT_DIR=$KERNEL_ROOT_DIR"
CMAKE_OPTIONS+=" -DSalomeKERNEL_DIR=$KERNEL_ROOT_DIR/salome_adm/cmake_files"
CMAKE_OPTIONS+=" -DOpenTURNS_DIR=$OT_ROOT_DIR/lib/cmake/openturns"
CMAKE_OPTIONS+=" -DPy2cpp_DIR=$PY2CPP_ROOT_DIR//lib/cmake/py2cpp"

# strangely Centos 8 fails to guess qwt installation
if [[ $DIST_NAME == "CO" && $DIST_VERSION == "8" && "$SAT_qwt_IS_NATIVE" == "1" ]]; then
    CMAKE_OPTIONS+=" -DQWT_LIBRARY=/usr/lib64/libqwt-qt5.so"
    CMAKE_OPTIONS+=" -DQWT_INCLUDE_DIR=/usr/include/qt5/qwt"
elif [ "$SAT_qwt_IS_NATIVE" != "1" ]; then
    CMAKE_OPTIONS+=" -DQWT_LIBRARY=$QWT_ROOT_DIR/lib/libqwt.so"
    CMAKE_OPTIONS+=" -DQWT_INCLUDE_DIR=$QWT_ROOT_DIR/include"
fi

if [[ "$DIST_NAME$DIST_VERSION" == "CO8" ]]; then
    CMAKE_OPTIONS+=" -DUSE_SPHINX=OFF" # missing tex-preview LateX package for CentOS 8
elif [ "$DIST_NAME$DIST_VERSION" == "FD36" ]; then
    CMAKE_OPTIONS+=" -DUSE_SPHINX=OFF" #
else
    CMAKE_OPTIONS+=" -DUSE_SPHINX=ON"
fi
CMAKE_OPTIONS+=" -DSPHINX_ROOT_DIR=$SPHINX_ROOT_DIR"
CMAKE_OPTIONS+=" -DYACS_ROOT_DIR=$YACS_ROOT_DIR"
CMAKE_OPTIONS+=" -DSalomeYACS_DIR=$YACS_ROOT_DIR/adm/cmake"
CMAKE_OPTIONS+=" -Dydefx_DIR=$YDEFX_ROOT_DIR/salome_adm/cmake_files"
CMAKE_OPTIONS+=" -DAdaoCppLayer_INCLUDE_DIR=$ADAO_INTERFACE_ROOT_DIR/include"
CMAKE_OPTIONS+=" -DAdaoCppLayer_ROOT_DIR=$ADAO_INTERFACE_ROOT_DIR"
CMAKE_OPTIONS+=" -DUSE_SALOME=ON"
if [ ! -z "$TBB_ROOT" ]; then
    CMAKE_OPTIONS+=" -DTBB_ROOT=$TBB_ROOT_DIR"
    CMAKE_OPTIONS+=" -DTBB_INCLUDE_DIR=$TBB_ROOT_DIR/include"
fi
CMAKE_OPTIONS+=" -DPYTHON_EXECUTABLE=$PYTHONBIN"

CMAKE_OPTIONS+=" -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE"
if [ "$SAT_Python_IS_NATIVE" != "1" ]; then
    CMAKE_OPTIONS+=" -DPYTHON_LIBRARY=$PYTHON_ROOT_DIR/lib/libpython$PYTHON_VERSION.so"
fi

if [ "$SAT_Sphinx_IS_NATIVE" != "1" ]; then
    CMAKE_OPTIONS+=" -DSPHINX_ROOT_DIR:FILEPATH=$SPHINX_ROOT_DIR"
    CMAKE_OPTIONS+=" -DSPHINX_EXECUTABLE:FILEPATH=$SPHINX_ROOT_DIR/bin/sphinx-build"
fi

CMAKE_OPTIONS+=" -DCMAKE_FIND_ROOT_PATH=ON"
CMAKE_OPTIONS+=" -DSWIG_EXECUTABLE:PATH=$(which swig)"
if [ "${SAT_cgns_IS_NATIVE}" != "1" ]
then
    CMAKE_OPTIONS+=" -DCGNS_INCLUDE_DIR:PATH=${CGNS_ROOT_DIR}/include"
    CMAKE_OPTIONS+=" -DCGNS_LIBRARY:PATH=${CGNS_ROOT_DIR}/lib/libcgns.so"
fi
if [ -n "$SAT_DEBUG" ]; then
    CMAKE_OPTIONS+=" -DCMAKE_BUILD_TYPE:STRING=Debug"
else
    CMAKE_OPTIONS+=" -DCMAKE_BUILD_TYPE:STRING=Release"
fi

echo
echo "*** cmake" $CMAKE_OPTIONS
cmake $CMAKE_OPTIONS $SOURCE_DIR
if [ $? -ne 0 ]
then
    echo "ERROR on cmake"
    exit 1
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

