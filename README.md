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

# After editing the compiler source under zig/. This uses the known-good
# baseline compiler and writes the edited compiler to dev-stage3.
make build

# Rebuild the compiler and run the range-analysis guidepost.
make test
```

`make bootstrap` is the seed-verified path. It writes the known-good baseline
compiler to `zig/build/stage3/bin/zig`.

`make build` deliberately bypasses the seed: it uses that baseline compiler to
build the edited sources and writes the result to
`zig/build/dev-stage3/bin/zig`. Use it for changes which the committed seed
cannot compile.

## Bootstrap seed

The committed `zig/stage1/zig1.wasm` is the bootstrap seed. It must remain
tracked. Normal compiler changes do not require changing it.

After the edited compiler builds and passes tests, update the seed when the
change crosses a bootstrap-compatibility boundary:

```sh
make update-seed
```

That command intentionally changes the tracked seed artifact. Do not run it as
part of the ordinary edit/build/test loop.
