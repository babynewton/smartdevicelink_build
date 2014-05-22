#!/bin/bash

function setup_common(){
	echo Checking for common updates
	found=false
	test -n `which gcc` || (sudo apt-get install build-essential && found=true)
	test -n `which g++` || (sudo apt-get install g++ && found=true)
	test -n `which cmake` || (sudo apt-get install cmake && found=true)
	test -d "/usr/include/bluetooth" || (sudo apt-get install libbluetooth-dev && found=true)
	test -n `which chromium-browser` || (sudo apt-get install chromium-browser && found=true)
	test -n `which openssl` || (sudo apt-get install openssl libssl-dev && found=true)
	test -n `which doxygen` || (sudo apt-get install doxygen && found=true)
	test -n `which graphviz` || (sudo apt-get install graphviz && found=true)
	if [ $found == false ]
	then
		echo Nothing to do
	fi
}

function setup_core_r1(){
	echo Checking for master updates
	echo Nothing to do
}

function setup_core(){
	echo Checking for release_3.0 updates
	found=false
	test -n `which mscgen` || (sudo apt-get install mscgen && found=true)
	test -d "/usr/include/log4cxx" || (sudo apt-get install liblog4cxx10-dev && found=true)
	test -n "pkg-config --cflags dbus-1" || (sudo apt-get install libdbus-1-dev && found=true)
	if [ $found == false ]
	then
		echo Nothing to do
	fi
}

function show_help(){
	echo "configure by Newton Kim, Copyleft from 2014"
	echo "USAGE: ./configure target options"
	echo "target:"
	for DIR in `ls .. -d`
	do
		test "$DIR" != "build" || continue
		echo "    $DIR"
	done
	echo "option:"
	echo "    -g, --debug    enables debugging information"
	echo "    -q, --with-qt  enables QT UI(only for releas 3.0)"
	echo "    -h, --help     shows this help screeen"
}

CMAKE_OPTION=""
QT_HMI=false
SHARED_LIBS=false
DEBUG_FLAG=false
for ARG in $@
do
	case $ARG in
		-g | --debug)
			DEBUG_FLAG=true
			;;
		-q | --with-qt)
			QT_HMI=true
			;;
		-h | --help)
			show_help
			exit 0
			;;
		-u | --with-usb)
			USB_SUPPORT=true
			;;
		-s | --with-shared)
			SHARED_LIBS=true
			;;
		-b | --with-bluetooth)
			BT_SUPPORT=true
			;;
		-m | --with-media)
			MEDIA_SUPPORT=true
			;;
		-*)
			echo "Err: Invalid argument $ARG"
			show_help
			exit 1
			;;
		*)
			if [ -d "../$ARG" ]
			then
				TARGET=$ARG
			else
				echo "Err: Invalid target $ARG"
				exit 1
			fi
			;;
	esac
done

if [ ! -n "$TARGET" ]
then
	echo "Err: No target has been specified"
	exit 1
fi

setup_common
setup_$TARGET

if [ "$QT_HMI" == true ]
then
	if [ "$TARGET" != "release_3.0" ]
	then
		echo "Err: QT HMI serves with release_3.0 only"
		exit 1
	fi
	CMAKE_OPTION+=" -DHMI2=ON"
fi

if [ "$DEBUG_FLAG" == true ]
then
	if [ "$TARGET" != "release_3.0" ]
	then
		echo "Err: Debug serves with release_3.0 only"
		exit 1
	fi
	CMAKE_OPTION+=" -DCMAKE_C_FLAGS_DEBUG"
fi

test "$SHARED_LIBS" != true || CMAKE_OPTION+=" -DBUILD_SHARED_LIBS"

CORES=`cat /proc/cpuinfo | grep processor | wc -l`
if [ -f "../$TARGET/SDL_Core/CMakeLists.txt" ]
then
	CMAKE_PATH=../../$TARGET/SDL_Core
elif [ -f "../$TARGET/CMakeLists.txt" ]
then
	CMAKE_PATH=../../$TARGET
else
	echo "CMakeLists.txt not found"
	exit 1
fi
sed "s#@release@#$TARGET#g;
	s#@cmake_option@#$CMAKE_OPTION#g;
	s#@cores@#$CORES#g;
	s#@cmake_path@#$CMAKE_PATH#g;
	" < Makefile.in > Makefile

exit 0
