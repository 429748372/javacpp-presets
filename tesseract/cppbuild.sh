#!/bin/bash
# This file is meant to be included by the parent cppbuild.sh script
if [[ -z "$PLATFORM" ]]; then
    pushd ..
    bash cppbuild.sh "$@" tesseract
    popd
    exit
fi

TESSERACT_VERSION=4.0.0-beta.1
download https://github.com/tesseract-ocr/tesseract/archive/$TESSERACT_VERSION.tar.gz tesseract-$TESSERACT_VERSION.tar.gz

mkdir -p $PLATFORM
cd $PLATFORM
INSTALL_PATH=`pwd`
echo "Decompressing archives..."
tar --totals -xzf ../tesseract-$TESSERACT_VERSION.tar.gz
cd tesseract-$TESSERACT_VERSION
if [[ "${ACLOCAL_PATH:-}" == C:\\msys64\\* ]]; then
    export ACLOCAL_PATH=/mingw64/share/aclocal:/usr/share/aclocal
fi
bash autogen.sh

LEPTONICA_PATH=$INSTALL_PATH/../../../leptonica/cppbuild/$PLATFORM/

if [[ -n "${BUILD_PATH:-}" ]]; then
    PREVIFS="$IFS"
    IFS="$BUILD_PATH_SEPARATOR"
    for P in $BUILD_PATH; do
        if [[ -d "$P/include/leptonica" ]]; then
            LEPTONICA_PATH="$P"
        fi
    done
    IFS="$PREVIFS"
fi

LEPTONICA_PATH="${LEPTONICA_PATH//\\//}"

sedinplace 's/static string/static std::string/g' ccutil/unichar.h
sedinplace '/tiff/d' api/Makefile.am

case $PLATFORM in
    android-arm)
#        ANDROID_ROOT=${ANDROID_ROOT//14/21}
#        ANDROID_FLAGS=${ANDROID_FLAGS//14/21}
        patch -Np1 < ../../../tesseract-android.patch
        cp "$ANDROID_ROOT/usr/lib/crtbegin_so.o" "$ANDROID_ROOT/usr/lib/crtend_so.o" api
        "$ANDROID_BIN-ar" r api/librt.a "$ANDROID_ROOT/usr/lib/crtbegin_dynamic.o"
        ./configure --prefix=$INSTALL_PATH --host="arm-linux-androideabi" --with-sysroot="$ANDROID_ROOT" LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" AR="$ANDROID_BIN-ar" RANLIB="$ANDROID_BIN-ranlib" CPP="$ANDROID_BIN-cpp" CC="$ANDROID_BIN-gcc" CXX="$ANDROID_BIN-g++" STRIP="$ANDROID_BIN-strip" CPPFLAGS="-I$LEPTONICA_PATH/include/ $ANDROID_FLAGS" LDFLAGS="-L$ANDROID_ROOT/usr/lib/ -L$ANDROID_CPP/libs/armeabi/ -nostdlib -Wl,--fix-cortex-a8 -z text -L$LEPTONICA_PATH/lib/ -L./" LIBS="-llept -lgnustl_static -lgcc -ldl -lz -lm -lc"
        sed -i="" s/lstdc++/lgnustl_static/g libtool
        chmod -w libtool
        make -j $MAKEJ
        make install-strip
        ;;
    android-arm64)
        patch -Np1 < ../../../tesseract-android.patch
        cp "$ANDROID_ROOT/usr/lib/crtbegin_so.o" "$ANDROID_ROOT/usr/lib/crtend_so.o" api
        "$ANDROID_BIN-ar" r api/librt.a "$ANDROID_ROOT/usr/lib/crtbegin_dynamic.o"
        ./configure --prefix=$INSTALL_PATH --host="aarch64-linux-android" --with-sysroot="$ANDROID_ROOT" LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" AR="$ANDROID_BIN-ar" RANLIB="$ANDROID_BIN-ranlib" CPP="$ANDROID_BIN-cpp" CC="$ANDROID_BIN-gcc" CXX="$ANDROID_BIN-g++" STRIP="$ANDROID_BIN-strip" CPPFLAGS="-I$LEPTONICA_PATH/include/ $ANDROID_FLAGS" LDFLAGS="-L$ANDROID_ROOT/usr/lib/ -L$ANDROID_CPP/libs/arm64-v8a/ -nostdlib -z text -L$LEPTONICA_PATH/lib/ -L./" LIBS="-llept -lgnustl_static -lgcc -ldl -lz -lm -lc"
        sed -i="" s/lstdc++/lgnustl_static/g libtool
        chmod -w libtool
        make -j $MAKEJ
        make install-strip
        ;;
    android-x86)
#        ANDROID_ROOT=${ANDROID_ROOT//14/21}
#        ANDROID_FLAGS=${ANDROID_FLAGS//14/21}
        patch -Np1 < ../../../tesseract-android.patch
        cp "$ANDROID_ROOT/usr/lib/crtbegin_so.o" "$ANDROID_ROOT/usr/lib/crtend_so.o" api
        "$ANDROID_BIN-ar" r api/librt.a "$ANDROID_ROOT/usr/lib/crtbegin_dynamic.o"
        ./configure --prefix=$INSTALL_PATH --host="i686-linux-android" --with-sysroot="$ANDROID_ROOT" LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" AR="$ANDROID_BIN-ar" RANLIB="$ANDROID_BIN-ranlib" CPP="$ANDROID_BIN-cpp" CC="$ANDROID_BIN-gcc" CXX="$ANDROID_BIN-g++" STRIP="$ANDROID_BIN-strip" CPPFLAGS="-I$LEPTONICA_PATH/include/ $ANDROID_FLAGS" LDFLAGS="-L$ANDROID_ROOT/usr/lib/ -L$ANDROID_CPP/libs/x86/ -nostdlib -z text -L$LEPTONICA_PATH/lib/ -L./" LIBS="-llept -lgnustl_static -lgcc -ldl -lz -lm -lc"
        sed -i="" s/lstdc++/lgnustl_static/g libtool
        chmod -w libtool
        make -j $MAKEJ
        make install-strip
        ;;
    android-x86_64)
        patch -Np1 < ../../../tesseract-android.patch
        cp "$ANDROID_ROOT/usr/lib64/crtbegin_so.o" "$ANDROID_ROOT/usr/lib64/crtend_so.o" api
        "$ANDROID_BIN-ar" r api/librt.a "$ANDROID_ROOT/usr/lib64/crtbegin_dynamic.o"
        ./configure --prefix=$INSTALL_PATH --host="x86_64-linux-android" --with-sysroot="$ANDROID_ROOT" LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" AR="$ANDROID_BIN-ar" RANLIB="$ANDROID_BIN-ranlib" CPP="$ANDROID_BIN-cpp" CC="$ANDROID_BIN-gcc" CXX="$ANDROID_BIN-g++" STRIP="$ANDROID_BIN-strip" CPPFLAGS="-I$LEPTONICA_PATH/include/ $ANDROID_FLAGS" LDFLAGS="-L$ANDROID_ROOT/usr/lib64/ -L$ANDROID_CPP/libs/x86_64/ -nostdlib -z text -L$LEPTONICA_PATH/lib/ -L./" LIBS="-llept -lgnustl_static -lgcc -ldl -lz -lm -lc"
        sed -i="" s/lstdc++/lgnustl_static/g libtool
        chmod -w libtool
        make -j $MAKEJ
        make install-strip
        ;;
    linux-x86)
        #patch -Np1 < ../../../tesseract-linux.patch
        ./configure --prefix=$INSTALL_PATH CC="$OLDCC -m32" CXX="$OLDCXX -m32" LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" CPPFLAGS="-I$LEPTONICA_PATH/include/" LDFLAGS="-L$LEPTONICA_PATH/lib/ -Wl,-rpath,$LEPTONICA_PATH/lib/" LIBS="-llept"
        make -j $MAKEJ
        make install-strip
        ;;
    linux-armhf)
        #patch -Np1 < ../../../tesseract-linux.patch
        ./configure --prefix=$INSTALL_PATH --host=arm-linux-gnueabihf CC="arm-linux-gnueabihf-gcc" CXX="arm-linux-gnueabihf-g++" LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" CPPFLAGS="-I$LEPTONICA_PATH/include/" LDFLAGS="-L$LEPTONICA_PATH/lib/ -Wl,-rpath,$LEPTONICA_PATH/lib/" LIBS="-llept"
        make -j $MAKEJ
        make install-strip
        ;;
    linux-arm64)
        #patch -Np1 < ../../../tesseract-linux.patch
        ./configure --prefix=$INSTALL_PATH --host=aarch64-linux-gnu CC="aarch64-linux-gnu-gcc" CXX="aarch64-linux-gnu-g++" LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" CPPFLAGS="-I$LEPTONICA_PATH/include/" LDFLAGS="-L$LEPTONICA_PATH/lib/ -Wl,-rpath,$LEPTONICA_PATH/lib/" LIBS="-llept"
        make -j $MAKEJ
        make install-strip
        ;;
    linux-x86_64)
        #patch -Np1 < ../../../tesseract-linux.patch
        ./configure --prefix=$INSTALL_PATH CC="$OLDCC -m64" CXX="$OLDCXX -m64" LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" CPPFLAGS="-I$LEPTONICA_PATH/include/" LDFLAGS="-L$LEPTONICA_PATH/lib/ -Wl,-rpath,$LEPTONICA_PATH/lib/" LIBS="-llept"
        make -j $MAKEJ
        make install-strip
        ;;
    linux-ppc64le)
        #patch -Np1 < ../../../tesseract-linux.patch
        MACHINE_TYPE=$( uname -m )
        if [[ "$MACHINE_TYPE" =~ ppc64 ]]; then
          ./configure --prefix=$INSTALL_PATH CC="$OLDCC -m64" CXX="$OLDCXX -m64" LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" CPPFLAGS="-I$LEPTONICA_PATH/include/" LDFLAGS="-L$LEPTONICA_PATH/lib/ -Wl,-rpath,$LEPTONICA_PATH/lib/" LIBS="-llept"
        else
          ./configure --prefix=$INSTALL_PATH --host=powerpc64le-linux-gnu CC=powerpc64le-linux-gnu-gcc CXX=powerpc64le-linux-gnu-g++ LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" CPPFLAGS="-I$LEPTONICA_PATH/include/" LDFLAGS="-L$LEPTONICA_PATH/lib/ -Wl,-rpath,$LEPTONICA_PATH/lib/" LIBS="-llept"
        fi
        make -j $MAKEJ
        make install-strip
        ;;
    macosx-*)
        patch -Np1 < ../../../tesseract-macosx.patch
        ./configure --prefix=$INSTALL_PATH LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" CPPFLAGS="-I$LEPTONICA_PATH/include/" LDFLAGS="-L$LEPTONICA_PATH/lib/ -Wl,-rpath,$LEPTONICA_PATH/lib/" LIBS="-llept"
        make -j $MAKEJ
        make install-strip
        ;;
    windows-x86)
        #patch -Np1 < ../../../tesseract-windows.patch
        cp vs2010/port/* ccutil/
        ./configure --prefix=$INSTALL_PATH --host="i686-w64-mingw32" CC="gcc -m32" CXX="g++ -m32 -fpermissive" LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" CPPFLAGS="-I$LEPTONICA_PATH/include/" LDFLAGS="-L$LEPTONICA_PATH/lib/" LIBS="-llept"
        make -j $MAKEJ
        make install-strip
        ;;
    windows-x86_64)
        #patch -Np1 < ../../../tesseract-windows.patch
        cp vs2010/port/* ccutil/
        ./configure --prefix=$INSTALL_PATH --host="x86_64-w64-mingw32" CC="gcc -m64" CXX="g++ -m64 -fpermissive" LEPTONICA_CFLAGS="-I$LEPTONICA_PATH/include/leptonica/" LEPTONICA_LIBS="-L$LEPTONICA_PATH/lib/ -llept" CPPFLAGS="-I$LEPTONICA_PATH/include/" LDFLAGS="-L$LEPTONICA_PATH/lib/" LIBS="-llept"
        make -j $MAKEJ
        make install-strip
        ;;
    *)
        echo "Error: Platform \"$PLATFORM\" is not supported"
        ;;
esac

cd ../..
