TARGET = MasterPDFEditor.dylib
TINYHOOK = tinyhook
TINYHOOK_LIB_ARM64 = $(TINYHOOK)/libtinyhook_arm64.a
TINYHOOK_LIB_X86_64 = $(TINYHOOK)/libtinyhook_x86_64.a
TARGET_ARM64 = $(TARGET:.dylib=_arm64.dylib)
TARGET_X86_64 = $(TARGET:.dylib=_x86_64.dylib)

all: $(TARGET)

$(TINYHOOK_LIB_ARM64): $(TINYHOOK)/Makefile
	$(MAKE) -C $(TINYHOOK) clean
	$(MAKE) -C $(TINYHOOK) static ARCH=arm64 NO_EXPORT=1 CFLAGS="-arch arm64 -Iinclude -fvisibility=hidden -Os -Wall -Wshadow -DNO_EXPORT"
	mv $(TINYHOOK)/libtinyhook.a $@

$(TINYHOOK_LIB_X86_64): $(TINYHOOK)/Makefile
	$(MAKE) -C $(TINYHOOK) clean
	$(MAKE) -C $(TINYHOOK) static ARCH=x86_64 NO_EXPORT=1 CFLAGS="-arch x86_64 -Iinclude -fvisibility=hidden -Os -Wall -Wshadow -DNO_EXPORT"
	mv $(TINYHOOK)/libtinyhook.a $@

$(TARGET_ARM64): main.m $(TINYHOOK_LIB_ARM64)
	clang -arch arm64 \
		-framework Foundation \
		-fobjc-arc \
		main.m \
		-L$(TINYHOOK) -ltinyhook_arm64 \
		-I$(TINYHOOK) \
		-dynamiclib \
		-o $@ \
		-current_version 1.0 \
		-compatibility_version 1.0

$(TARGET_X86_64): main.m $(TINYHOOK_LIB_X86_64)
	clang -arch x86_64 \
		-framework Foundation \
		-fobjc-arc \
		main.m \
		-L$(TINYHOOK) -ltinyhook_x86_64 \
		-I$(TINYHOOK) \
		-dynamiclib \
		-o $@ \
		-current_version 1.0 \
		-compatibility_version 1.0

$(TARGET): $(TARGET_ARM64) $(TARGET_X86_64)
	lipo -create -output $@ $^

clean:
	$(MAKE) -C $(TINYHOOK) clean
	rm -f $(TARGET) $(TARGET_ARM64) $(TARGET_X86_64) $(TINYHOOK_LIB_ARM64) $(TINYHOOK_LIB_X86_64)

.PHONY: all clean