#!/bin/bash
export ANDROID_HOME=/home/martin/quest2/sdk
PATH=$PATH:$ANDROID_HOME/build-tools/29.0.3
PATH=$PATH:/home/martin/quest2/ndk/android-ndk-r25b/toolchains/llvm/prebuilt/linux-x86_64/bin
export NDK_HOME=/home/martin/quest2/ndk/android-ndk-r25b
export OVR_HOME=/home/martin/quest2/ovr/

rm -rf build
mkdir -p build
pushd build > /dev/null
javac\
	-classpath $ANDROID_HOME/platforms/android-29/android.jar\
	-d .\
	../src/main/java/com/makepad/hello_quest/*.java
dx --dex --output classes.dex .
mkdir -p lib/arm64-v8a
pushd lib/arm64-v8a > /dev/null
aarch64-linux-android29-clang\
    -march=armv8-a\
    -shared\
    -I $NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/\
    -I $OVR_HOME/VrApi/Include\
    -L $NDK_HOME/platforms/android-29/arch-arm64/usr/lib\
    -L $OVR_HOME/VrApi/Libs/Android/arm64-v8a/Debug\
    -landroid\
    -llog\
    -lvrapi\
    -lEGL \
    -lGLESv3 \
    -o libmain.so\
   ../../../src/main/cpp/*.c
cp $OVR_HOME/VrApi/Libs/Android/arm64-v8a/Debug/libvrapi.so .
popd > /dev/null
aapt\
	package\
	-F hello_quest.apk\
	-I $ANDROID_HOME/platforms/android-29/android.jar\
	-M ../src/main/AndroidManifest.xml\
	-f
aapt add hello_quest.apk classes.dex
aapt add hello_quest.apk lib/arm64-v8a/libmain.so
aapt add hello_quest.apk lib/arm64-v8a/libvrapi.so
apksigner\
	sign\
	-ks ~/.android/debug.keystore\
	--ks-key-alias androiddebugkey\
	--ks-pass pass:android\
	hello_quest.apk
popd > /dev/null
