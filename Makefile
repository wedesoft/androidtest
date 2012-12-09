.SUFFIXES: .java .class
# http://geosoft.no/development/android.html
NDK = $(HOME)/android-ndk-r8b
SDK = $(HOME)/android-sdk-linux
TOOLCHAIN = /tmp/ndk-hello
SYSROOT = $(TOOLCHAIN)/sysroot
GCC = $(TOOLCHAIN)/bin/arm-linux-androideabi-gcc
STRIP = $(TOOLCHAIN)/bin/arm-linux-androideabi-strip
CFLAGS = -march=armv7-a -mfloat-abi=softfp -I$(SYSROOT)/usr/include
LDFLAGS = -Wl,--fix-cortex-a8 -L$(SYSROOT)/usr/lib
JAVA_HOME = /usr/lib/jvm/java-6-openjdk

JARS = $(wildcard src/com/wedesoft/androidtest/*.java)
OBJS = $(JARS:java=class)

test: $(OBJS)

all: $(TOOLCHAIN)

src/com/wedesoft/androidtest/R.java:
	$(SDK)/platform-tools/aapt package -v -f -m -S res -J src -M AndroidManifest.xml -I $(SDK)/platforms/android-10/android.jar

key:
	$(JAVA_HOME)/bin/keytool -genkeypair -validity 10000 -dname "CN=Wedesoft, O=Wedesoft, L=London, S=United Kingdom, C=UK" -keystore AndroidTest.keystore -storepass password -keypass password -alias AndroidTestKey -keyalg RSA -v

#hello: hello.o
#	$(GCC) $(LDFLAGS) -o $@ hello.o
#	$(STRIP) -s $@

.c.o:
	$(GCC) $(CFLAGS) -o $@ -c $<

.java.class:
	$(JAVA_HOME)/bin/javac -d obj -classpath $(SDK)/platforms/android-10/android.jar:obj -sourcepath src $<

clean:
	rm -f *.o .*.un~

$(TOOLCHAIN):
	$(NDK)/build/tools/make-standalone-toolchain.sh --install-dir=$@

