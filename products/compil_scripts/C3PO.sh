#!/bin/bash

echo "##########################################################################"
echo "C3PO" $VERSION
echo "##########################################################################"

echo  "*** build in SOURCE directory"
cd $SOURCE_DIR

mkdir -p $PRODUCT_INSTALL/lib/python${PYTHON_VERSION:0:3}/site-packages
export PATH=${PRODUCT_INSTALL}/bin:$PATH
export PYTHONPATH=$PWD:$PYTHONPATH
export PYTHONPATH=${PRODUCT_INSTALL}/lib/python${PYTHON_VERSION:0:3}/site-packages:$PYTHONPATH

echo
echo "*** build and install with $PYTHONBIN sources/setup.py install --prefix=$PRODUCT_INSTALL"
$PYTHONBIN sources/setup.py install --prefix=$PRODUCT_INSTALL
if [ $? -ne 0 ]
then
    echo "ERROR on build/install"
    exit 3
fi
cd $SOURCE_DIR

export LD_LIBRARY_PATH="${MEDCOUPLING_ROOT_DIR}/lib:${LD_LIBRARY_PATH}"
export PYTHONPATH="${MEDCOUPLING_ROOT_DIR}/${PYTHON_LIBDIR}:${PYTHONPATH}"
export PYTHONPATH="${MEDCOUPLING_ROOT_DIR}/lib:${PYTHONPATH}"
export PYTHONPATH="${MEDCOUPLING_ROOT_DIR}/bin:${PYTHONPATH}"
if [ -n "$MPI_ROOT_DIR" ]; then
    ctest .
else
    # these tests use MPI...
    ctest -E "Dussaix_seq|Dussaix_master_worker|Dussaix_collaborative|Listings_collaboratif"
fi
if [ $? -ne 0 ]
then
    echo "ERROR on ctest"
    exit 4
fi

echo
echo "########## END"