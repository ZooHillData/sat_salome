#!/bin/bash

echo "##########################################################################"
echo SIP + PyQt5_sip $VERSION
echo "##########################################################################"


echo  "*** build in SOURCE directory"
cd $SOURCE_DIR/sip-5.5.0

# we don't install in python directory -> modify environment as described in INSTALL file
mkdir -p $PRODUCT_INSTALL/lib/python${PYTHON_VERSION}/site-packages
export PATH=$(pwd)/bin:$PATH
export PYTHONPATH=$(pwd):$PYTHONPATH
export PYTHONPATH=${PRODUCT_INSTALL}/lib/python${PYTHON_VERSION}/site-packages:$PYTHONPATH

echo
echo "*** build with $PYTHONBIN"
$PYTHONBIN setup.py build
if [ $? -ne 0 ]
then
    echo "ERROR on build"
    exit 2
fi

echo
echo "*** install with $PYTHONBIN"
$PYTHONBIN setup.py install --prefix=$PRODUCT_INSTALL
if [ $? -ne 0 ]
then
    echo "ERROR on install"
    exit 3
fi

cd $SOURCE_DIR/PyQt5_sip-12.8.1

echo
echo "*** build with $PYTHONBIN"
$PYTHONBIN setup.py build
if [ $? -ne 0 ]
then
    echo "ERROR on build"
    exit 2
fi

echo
echo "*** install with $PYTHONBIN"
$PYTHONBIN setup.py install --prefix=$PRODUCT_INSTALL
if [ $? -ne 0 ]
then
    echo "ERROR on install"
    exit 3
fi

mkdir $PRODUCT_INSTALL/include
cp *.h $PRODUCT_INSTALL/include

cd $PRODUCT_INSTALL/bin
ln -sf sip5 sip

LINUX_DISTRIBUTION="$DIST_NAME$DIST_VERSION"
case $LINUX_DISTRIBUTION in
    DB10)
        cd $PRODUCT_INSTALL/lib/python3.7/site-packages
        ln -sf PyQt5_sip-12.8.1-py3.7-linux-x86_64.egg/PyQt5
        ;;
    *)
        ;;
esac

echo
echo "########## END"
