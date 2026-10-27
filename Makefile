.PHONY: all bootstrap bootstrap-build build dev-build configure test update-seed

ZIG_SOURCE := zig
ZIG_BUILD := $(ZIG_SOURCE)/build
ZIG_BOOTSTRAP := $(ZIG_BUILD)/stage3/bin/zig
ZIG_DEV := $(ZIG_BUILD)/dev-stage3/bin/zig
DEV_CACHE := $(abspath $(ZIG_BUILD)/dev-cache)
DEV_GLOBAL_CACHE := $(abspath $(ZIG_BUILD)/dev-global-cache)
FEATURE_TEST := test.zig
LLVM_PREFIX := $(shell llvm-config --prefix)
ZSTD_PREFIX := $(shell brew --prefix zstd)

all: build

# One-time, seed-verified build after cloning or changing CMake/toolchain
# settings. It produces the known-good baseline compiler at ZIG_BOOTSTRAP.
bootstrap: configure bootstrap-build

configure:
	cmake -S $(ZIG_SOURCE) -B $(ZIG_BUILD) -G Ninja \
		-DCMAKE_PREFIX_PATH="$(LLVM_PREFIX)" \
		-DCMAKE_EXE_LINKER_FLAGS="-L$(ZSTD_PREFIX)/lib"

# Re-run the CMake/bootstrap pipeline. This intentionally uses zig1.wasm.
bootstrap-build:
	cmake --build $(ZIG_BUILD)

# Build the edited compiler with the previously bootstrapped stage3 compiler.
# The result is separate from the baseline, so it can overwrite no bootstrap
# artifact and can be rebuilt even when the committed seed cannot compile the
# edited sources.
build: dev-build

dev-build:
	@test -x "$(ZIG_BOOTSTRAP)" || { echo "missing baseline compiler; run 'make bootstrap' first"; exit 1; }
	mkdir -p $(DEV_CACHE) $(DEV_GLOBAL_CACHE)
	cd $(ZIG_SOURCE) && ZIG_LOCAL_CACHE_DIR="$(DEV_CACHE)" ZIG_GLOBAL_CACHE_DIR="$(DEV_GLOBAL_CACHE)" \
		build/stage3/bin/zig build --zig-lib=lib \
		--cache-dir build/dev-cache \
		--prefix build/dev-stage3 \
		-Dversion-string="$$(sed -nE 's/^pub const version:.*\"([^\"]+)\";.*/\1/p' build/config.zig)" \
		-Dtarget=native -Dcpu=native -Denable-llvm -Dconfig_h=build/config.h

# Compile and run the range-analysis test file with the edited compiler.
test: dev-build
	$(ZIG_DEV) run $(FEATURE_TEST)

# Regenerate and replace the committed stage1 seed from the edited compiler.
# Run this only after dev-build and tests demonstrate the feature works.
update-seed: dev-build
	cd $(ZIG_SOURCE) && build/dev-stage3/bin/zig build update-zig1
