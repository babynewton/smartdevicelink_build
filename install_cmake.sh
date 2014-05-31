#!/bin/bash
CMAKE_DIRECTORY=cmake-2.8.12.2
CMAKE_ARCHIVE=$CMAKE_DIRECTORY.tar.gz
test -f ./$CMAKE_ARCHIVE || wget http://www.cmake.org/files/v2.8/$CMAKE_ARCHIVE
tar -zxvf $CMAKE_ARCHIVE
cd $CMAKE_DIRECTORY
./configure
make
sudo make install
rm -rf $CMAKE_DIRECTORY $CMAKE_ARCHIVE
