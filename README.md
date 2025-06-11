[![CI](https://github.com/allyourcodebase/libiconv/actions/workflows/ci.yaml/badge.svg)](https://github.com/allyourcodebase/libiconv/actions)

# libiconv

This is [GNU libiconv](https://www.gnu.org/software/libiconv/), packaged for [Zig](https://ziglang.org/).

## Installation

First, update your `build.zig.zon`:

```
# Initialize a `zig build` project if you haven't already
zig init
zig fetch --save git+https://github.com/allyourcodebase/libiconv.git
```

You can then import `libiconv` in your `build.zig` with:

```zig
const libiconv_dependency = b.dependency("libiconv", .{
    .target = target,
    .optimize = optimize,
});
your_exe.linkLibrary(libiconv_dependency.artifact("iconv"));
```

Be aware that iconv is already available on most targets when linking libc. A notable exception is Windows.
