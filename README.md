# Range-aware Zig compiler experiment

This repository vendors a Zig compiler source snapshot in `zig/` and contains
a guidepost program in `test.zig`.

## Prerequisites (macOS/Homebrew)

- Xcode Command Line Tools
- CMake and Ninja
- LLVM, Clang, and LLD development libraries
- zstd

For a Homebrew setup, make sure `llvm-config` is on `PATH`, for example:

```sh
brew install cmake ninja llvm zstd
export PATH="$(brew --prefix llvm)/bin:$PATH"
```

## Development workflow

```sh
# First build after cloning, or after changing CMake/toolchain settings.
make bootstrap

# After editing the compiler source under zig/.
make build

# Rebuild the compiler and run the range-analysis guidepost.
make test
```

## Bootstrap seed

The committed `zig/stage1/zig1.wasm` is the bootstrap seed. It must remain
tracked. Normal compiler changes do not require changing it.

Only update the seed when a change crosses a bootstrap-compatibility boundary:

```sh
make update-seed
```

That command intentionally changes the tracked seed artifact. Do not run it as
part of the ordinary edit/build/test loop.
