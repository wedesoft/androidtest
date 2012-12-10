# http://geosoft.no/development/android.html
.SUFFIXES: .java .class .dex .keystore .apk .c .o
NDK = $(HOME)/android-ndk-r8b
SDK = $(HOME)/android-sdk-linux
TOOLCHAIN = /tmp/ndk-hello
SYSROOT = $(TOOLCHAIN)/sysroot
GCC = $(TOOLCHAIN)/bin/arm-linux-androideabi-gcc
STRIP = $(TOOLCHAIN)/bin/arm-linux-androideabi-strip
CFLAGS = -march=armv7-a -mfloat-abi=softfp -I$(SYSROOT)/usr/include
LDFLAGS = -Wl,--fix-cortex-a8 -L$(SYSROOT)/usr/lib
JAVA_HOME = /usr/lib/jvm/java-6-openjdk

BUILD_SRC = src/com/wedesoft/androidtest/R.java
SRC = $(filter-out $(BUILD_SRC),$(wildcard src/com/wedesoft/androidtest/*.java))
OBJS = $(subst src,obj,$(SRC:java=class) $(BUILD_SRC:java=class))

all: bin/AndroidTest.signed.apk

bin/AndroidTest.signed.apk: bin/AndroidTest.unsigned.apk 
	$(JAVA_HOME)/bin/jarsigner -keystore AndroidTest.keystore -storepass password -keypass password -signedjar $@ $< AndroidTestKey

bin/AndroidTest.unsigned.apk: AndroidManifest.xml $(BUILD_SRC) $(OBJS) bin/classes.dex
	$(SDK)/platform-tools/aapt package -v -f -M AndroidManifest.xml -S res -I $(SDK)/platforms/android-10/android.jar -F $@ bin

bin/classes.dex: $(BUILD_SRC) $(OBJS)
	$(SDK)/platform-tools/dx --dex --output=$@ obj lib

src/com/wedesoft/androidtest/R.java:
	$(SDK)/platform-tools/aapt package -v -f -m -S res -J src -M AndroidManifest.xml -I $(SDK)/platforms/android-10/android.jar

AndroidTest.keystore:
	$(JAVA_HOME)/bin/keytool -genkeypair -validity 10000 -dname "CN=Wedesoft, L=London, S=United Kingdom, C=UK" -keystore $@ -storepass password -keypass password -alias AndroidTestKey -keyalg RSA -v

obj/com/wedesoft/androidtest/%.class: src/com/wedesoft/androidtest/%.java
	$(JAVA_HOME)/bin/javac -d obj -classpath $(SDK)/platforms/android-10/android.jar:obj -sourcepath src $<

.c.o:
	$(GCC) $(CFLAGS) -o $@ -c $<

clean:
	rm -f $(BUILD_SRC) bin/*.dex obj/com/wedesoft/androidtest/*.class

$(TOOLCHAIN):
	$(NDK)/build/tools/make-standalone-toolchain.sh --install-dir=$@

