.PHONY: all bootstrap build configure test update-seed

ZIG_SOURCE := zig
ZIG_BUILD := $(ZIG_SOURCE)/build
ZIG_DEV := $(ZIG_BUILD)/stage3/bin/zig
FEATURE_TEST := test.zig
LLVM_PREFIX := $(shell llvm-config --prefix)
ZSTD_PREFIX := $(shell brew --prefix zstd)

all: build

# One-time setup after cloning, or after changing CMake/toolchain settings.
bootstrap: configure build

configure:
	cmake -S $(ZIG_SOURCE) -B $(ZIG_BUILD) -G Ninja \
		-DCMAKE_PREFIX_PATH="$(LLVM_PREFIX)" \
		-DCMAKE_EXE_LINKER_FLAGS="-L$(ZSTD_PREFIX)/lib"

# Incrementally rebuild the self-hosted compiler at zig/build/stage3/bin/zig.
# Use this after editing Zig compiler sources.
build:
	cmake --build $(ZIG_BUILD)

# Compile and run the range-analysis test file with the compiler built above.
test: build
	$(ZIG_DEV) run $(FEATURE_TEST)

# Maintainer-oriented: regenerate and replace the committed stage1 seed.
# Do this only when bootstrap compatibility actually requires it.
update-seed: build
	cd $(ZIG_SOURCE) && build/stage3/bin/zig build update-zig1
