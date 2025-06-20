const std = @import("std");

const version: std.SemanticVersion = .{ .major = 1, .minor = 18, .patch = 0 };
const libcharset_version: std.SemanticVersion = .{ .major = 1, .minor = 5, .patch = 0 };

pub fn build(b: *std.Build) void {
    const upstream = b.dependency("libiconv", .{});
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(std.builtin.LinkMode, "linkage", "Link mode") orelse .static;
    const strip = b.option(bool, "strip", "Omit debug information");
    const pic = b.option(bool, "pie", "Produce Position Independent Code");

    const libcharset_h = b.addConfigHeader(.{
        .style = .{ .autoconf_at = upstream.path("libcharset/include/libcharset.h.build.in") },
        .include_path = "libcharset.h",
    }, .{ .HAVE_VISIBILITY = true });

    const public_libcharset_h = b.addConfigHeader(.{
        .style = .{ .autoconf_at = upstream.path("libcharset/include/libcharset.h.in") },
    }, .{});

    const localcharset_h = b.addConfigHeader(.{
        .style = .{ .autoconf_at = upstream.path("libcharset/include/localcharset.h.build.in") },
        .include_path = "localcharset.h",
    }, .{ .HAVE_VISIBILITY = true });

    const public_localcharset_h = b.addConfigHeader(.{
        .style = .{ .autoconf_at = upstream.path("libcharset/include/localcharset.h.in") },
    }, .{});

    const libcharset_config_header = b.addConfigHeader(.{
        .style = .{ .autoconf_undef = upstream.path("libcharset/config.h.in") },
    }, .{
        .ENABLE_RELOCATABLE = true,
        .HAVE_COPY_FILE_RANGE = null,
        .HAVE_DLFCN_H = if (target.result.os.tag == .windows) null else true,
        .HAVE_INTTYPES_H = true,
        .HAVE_LANGINFO_CODESET = if (target.result.os.tag == .windows) null else true,
        .HAVE_MACH_O_DYLD_H = null,
        .HAVE_MINIX_CONFIG_H = null,
        .HAVE_SETLOCALE = true,
        .HAVE_STDINT_H = true,
        .HAVE_STDIO_H = true,
        .HAVE_STDLIB_H = true,
        .HAVE_STRINGS_H = true,
        .HAVE_STRING_H = true,
        .HAVE_SYMLINK = if (target.result.os.tag == .windows) null else true,
        .HAVE_SYS_STAT_H = true,
        .HAVE_SYS_TYPES_H = true,
        .HAVE_UNISTD_H = true,
        .HAVE_VISIBILITY = true,
        .HAVE_WCHAR_H = true,
        .HAVE_WORKING_O_NOATIME = false,
        .HAVE_WORKING_O_NOFOLLOW = false,
        .HAVE__NSGETEXECUTABLEPATH = null,
        .INSTALLPREFIX = {},
        .LT_OBJDIR = ".libs/",
        .PACKAGE_BUGREPORT = "",
        .PACKAGE_NAME = "libcharset",
        .PACKAGE_STRING = b.fmt("libcharset {d}.{d}", .{ libcharset_version.major, libcharset_version.minor }),
        .PACKAGE_TARNAME = "libcharset",
        .PACKAGE_URL = "",
        .PACKAGE_VERSION = b.fmt("{d}.{d}", .{ libcharset_version.major, libcharset_version.minor }),
        .STDC_HEADERS = true,
        ._ALL_SOURCE = true,
        ._DARWIN_C_SOURCE = true,
        .__EXTENSIONS__ = true,
        ._GNU_SOURCE = true,
        ._HPUX_ALT_XOPEN_SOCKET_API = true,
        ._MINIX = null,
        ._NETBSD_SOURCE = true,
        ._OPENBSD_SOURCE = true,
        ._POSIX_SOURCE = null,
        ._POSIX_1_SOURCE = null,
        ._POSIX_PTHREAD_SEMANTICS = true,
        .__STDC_WANT_IEC_60559_ATTRIBS_EXT__ = true,
        .__STDC_WANT_IEC_60559_BFP_EXT__ = true,
        .__STDC_WANT_IEC_60559_DFP_EXT__ = true,
        .__STDC_WANT_IEC_60559_EXT__ = true,
        .__STDC_WANT_IEC_60559_FUNCS_EXT__ = true,
        .__STDC_WANT_IEC_60559_TYPES_EXT__ = true,
        .__STDC_WANT_LIB_EXT2__ = true,
        .__STDC_WANT_MATH_SPEC_FUNCS__ = true,
        ._TANDEM_SOURCE = true,
        ._XOPEN_SOURCE = null,
    });

    const libcharset = b.addLibrary(.{
        .name = "charset",
        .linkage = linkage,
        .version = .{ .major = 1, .minor = 0, .patch = 0 },
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .strip = strip,
            .pic = pic,
            .link_libc = true,
        }),
    });
    libcharset.installConfigHeader(public_libcharset_h);
    libcharset.installConfigHeader(public_localcharset_h);
    libcharset.root_module.addCMacro("BUILDING_LIBCHARSET", "1");
    libcharset.root_module.addCMacro("HAVE_CONFIG_H", "1");
    libcharset.root_module.addConfigHeader(libcharset_config_header);
    libcharset.root_module.addConfigHeader(libcharset_h);
    libcharset.root_module.addConfigHeader(localcharset_h);
    libcharset.root_module.addIncludePath(upstream.path("libcharset/lib"));
    libcharset.root_module.addIncludePath(upstream.path("libcharset"));
    libcharset.root_module.addIncludePath(upstream.path("libcharset/include"));
    libcharset.root_module.addCSourceFiles(.{
        .root = upstream.path("libcharset/lib"),
        .files = &.{
            "localcharset.c",
            "relocatable-stub.c",
        },
        .flags = &.{"-fvisibility=hidden"},
    });
    b.installArtifact(libcharset);

    const iconv_h = b.addConfigHeader(.{
        .style = .{ .autoconf_at = upstream.path("include/iconv.h.build.in") },
        .include_path = "iconv.h",
    }, .{
        .HAVE_VISIBILITY = true,
        .DLL_VARIABLE = {},
        .EILSEQ = {},
        .ICONV_CONST = {},
        .USE_MBSTATE_T = true,
        .BROKEN_WCHAR_H = false,
    });

    const libiconv_config_header = b.addConfigHeader(.{
        .style = .{ .autoconf_undef = upstream.path("lib/config.h.in") },
    }, .{
        .ENABLE_EXTRA = null,
        .ENABLE_RELOCATABLE = null,
        .mbstate_t = null,
        .HAVE_ICONV = if (target.result.os.tag == .windows or target.result.os.tag.isDarwin()) null else true,
        .HAVE_GETC_UNLOCKED = if (target.result.os.tag == .windows) null else true,
        .HAVE_LANGINFO_CODESET = if (target.result.os.tag == .windows) null else true,
        .HAVE_MBRTOWC = true,
        .HAVE_SETLOCALE = true,
        .HAVE_STDDEF_H = null,
        .HAVE_STDLIB_H = true,
        .HAVE_STRING_H = true,
        .HAVE_VISIBILITY = true,
        .HAVE_WCRTOMB = true,
        .HAVE_WORKING_O_NOFOLLOW = target.result.os.tag == .linux,
        .WORDS_LITTLEENDIAN = true,
        .INSTALLPREFIX = {},
        .@"inline" = null,
        .mode_t = null,
        .ssize_t = null,
    });

    const config_h = b.addConfigHeader(.{
        .style = .{ .autoconf_undef = upstream.path("config.h.in") },
    }, .{
        .AC_APPLE_UNIVERSAL_BUILD = null,
        .BITSIZEOF_PTRDIFF_T = if (target.result.os.tag == .wasi) false else null,
        .BITSIZEOF_SIG_ATOMIC_T = if (target.result.os.tag == .wasi) false else null,
        .BITSIZEOF_SIZE_T = if (target.result.os.tag == .wasi) false else null,
        .BITSIZEOF_WCHAR_T = if (target.result.os.tag == .wasi) false else null,
        .BITSIZEOF_WINT_T = if (target.result.os.tag == .wasi) false else null,
        .C_ALLOCA = null,
        .DOUBLE_SLASH_IS_DISTINCT_ROOT = null,
        .EILSEQ = null,
        .ENABLE_EXTRA = null,
        .ENABLE_NLS = if (target.result.os.tag == .linux) true else null,
        .ENABLE_RELOCATABLE = null,
        .FCNTL_DUPFD_BUGGY = null,
        .FUNC_REALPATH_NEARLY_WORKS = switch (target.result.os.tag) {
            .windows => null,
            .linux => if (target.result.isMuslLibC()) true else null,
            .macos => null,
            .wasi => null,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .FUNC_REALPATH_WORKS = switch (target.result.os.tag) {
            .windows => null,
            .linux => if (target.result.isGnuLibC()) true else null,
            .macos => null,
            .wasi => null,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .GNULIB_CANONICALIZE_LGPL = true,
        .GNULIB_CLOSE = true,
        .GNULIB_FSCANF = true,
        .GNULIB_FSTAT = true,
        .GNULIB_LOCALEDIR = {},
        .GNULIB_MSVC_NOTHROW = true,
        .GNULIB_PRINTF_ATTRIBUTE_FLAVOR_GNU = null,
        .GNULIB_SCANF = true,
        .GNULIB_SIGPIPE = true,
        .GNULIB_STAT = true,
        .GNULIB_STDIO_SINGLE_THREAD = true,
        .GNULIB_STRERROR = true,
        .GNULIB_TEST_CANONICALIZE_FILE_NAME = true,
        .GNULIB_TEST_CLOEXEC = true,
        .GNULIB_TEST_CLOSE = true,
        .GNULIB_TEST_DUP2 = true,
        .GNULIB_TEST_ENVIRON = true,
        .GNULIB_TEST_FCNTL = true,
        .GNULIB_TEST_FGETC = true,
        .GNULIB_TEST_FGETS = true,
        .GNULIB_TEST_FPRINTF = true,
        .GNULIB_TEST_FPUTC = true,
        .GNULIB_TEST_FPUTS = true,
        .GNULIB_TEST_FREAD = true,
        .GNULIB_TEST_FREE_POSIX = true,
        .GNULIB_TEST_FSCANF = true,
        .GNULIB_TEST_FSTAT = true,
        .GNULIB_TEST_FWRITE = true,
        .GNULIB_TEST_GETC = true,
        .GNULIB_TEST_GETCHAR = true,
        .GNULIB_TEST_GETDTABLESIZE = true,
        .GNULIB_TEST_GETPROGNAME = true,
        .GNULIB_TEST_MALLOC_POSIX = true,
        .GNULIB_TEST_MEMPCPY = true,
        .GNULIB_TEST_OPEN = true,
        .GNULIB_TEST_PRINTF = true,
        .GNULIB_TEST_PUTC = true,
        .GNULIB_TEST_PUTCHAR = true,
        .GNULIB_TEST_PUTS = true,
        .GNULIB_TEST_RAISE = true,
        .GNULIB_TEST_RAWMEMCHR = true,
        .GNULIB_TEST_READ = true,
        .GNULIB_TEST_READLINK = true,
        .GNULIB_TEST_REALLOC_POSIX = true,
        .GNULIB_TEST_REALPATH = true,
        .GNULIB_TEST_SCANF = true,
        .GNULIB_TEST_SIGPROCMASK = true,
        .GNULIB_TEST_STAT = true,
        .GNULIB_TEST_STRERROR = true,
        .GNULIB_TEST_VFPRINTF = true,
        .GNULIB_TEST_VPRINTF = true,
        .HAVE_ALLOCA = true,
        .HAVE_ALLOCA_H = switch (target.result.os.tag) {
            .windows => null,
            .linux => true,
            .macos => true,
            .wasi => true,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .HAVE_CANONICALIZE_FILE_NAME = switch (target.result.os.tag) {
            .windows => null,
            .linux => if (target.result.isGnuLibC()) true else null,
            .macos => null,
            .wasi => null,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .HAVE_CFLOCALECOPYPREFERREDLANGUAGES = null,
        .HAVE_CFPREFERENCESCOPYAPPVALUE = null,
        .HAVE_COPY_FILE_RANGE = null,
        .HAVE_CRTDEFS_H = if (target.result.os.tag == .windows) true else null,
        .HAVE_C_ALIGNASOF = null,
        .HAVE_C_BOOL = null,
        .HAVE_C_STATIC_ASSERT = null,
        .HAVE_C_VARARRAYS = true,
        .HAVE_DCGETTEXT = if (target.result.os.tag == .linux) true else null,
        .HAVE_DECL_CLEARERR_UNLOCKED = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => true,
            .wasi => true,
            .freebsd => true,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_ECVT = switch (target.result.os.tag) {
            .windows => true,
            .linux => true,
            .macos => true,
            .wasi => true,
            .freebsd => false,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_EXECVPE = switch (target.result.os.tag) {
            .windows => true,
            .linux => true,
            .macos => false,
            .wasi => false,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_FCLOSEALL = switch (target.result.os.tag) {
            .windows => true,
            .linux => target.result.isGnuLibC(),
            .macos => false,
            .wasi => false,
            .freebsd => true,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_FCVT = switch (target.result.os.tag) {
            .windows => true,
            .linux => true,
            .macos => true,
            .wasi => true,
            .freebsd => false,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_FEOF_UNLOCKED = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => true,
            .wasi => true,
            .freebsd => true,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_FERROR_UNLOCKED = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => true,
            .wasi => true,
            .freebsd => true,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_FFLUSH_UNLOCKED = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => false,
            .wasi => true,
            .freebsd => true,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_FGETS_UNLOCKED = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => false,
            .wasi => true,
            .freebsd => false,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_FPUTC_UNLOCKED = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => false,
            .wasi => true,
            .freebsd => true,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_FPUTS_UNLOCKED = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => false,
            .wasi => true,
            .freebsd => true,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_FREAD_UNLOCKED = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => false,
            .wasi => true,
            .freebsd => true,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_FWRITE_UNLOCKED = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => false,
            .wasi => true,
            .freebsd => true,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_GCVT = switch (target.result.os.tag) {
            .windows => true,
            .linux => true,
            .macos => true,
            .wasi => true,
            .freebsd => false,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_GETCHAR_UNLOCKED = if (target.result.os.tag == .windows) false else true,
        .HAVE_DECL_GETC_UNLOCKED = if (target.result.os.tag == .windows) false else true,
        .HAVE_DECL_GETDTABLESIZE = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => true,
            .wasi => false,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_GETW = true,
        .HAVE_DECL_PROGRAM_INVOCATION_NAME = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => false,
            .wasi => true,
            .freebsd => false,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_PROGRAM_INVOCATION_SHORT_NAME = switch (target.result.os.tag) {
            .windows => false,
            .linux => true,
            .macos => false,
            .wasi => true,
            .freebsd => false,
            .netbsd => false,
            else => @panic("unsupported OS"),
        },
        .HAVE_DECL_PUTCHAR_UNLOCKED = if (target.result.os.tag == .windows) false else true,
        .HAVE_DECL_PUTC_UNLOCKED = if (target.result.os.tag == .windows) false else true,
        .HAVE_DECL_PUTW = true,
        .HAVE_DECL_SETENV = if (target.result.os.tag == .windows) false else true,
        .HAVE_DECL_STRERROR_R = if (target.result.os.tag == .windows) false else true,
        .HAVE_DECL_WCSDUP = true,
        .HAVE_DECL__PUTENV = if (target.result.os.tag == .windows) true else false,
        .HAVE_DECL___ARGV = switch (target.result.os.tag) {
            .windows => true,
            .linux => false,
            .macos => null,
            .wasi => false,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .HAVE_DLFCN_H = if (target.result.os.tag == .windows) null else true,
        .HAVE_ENVIRON_DECL = switch (target.result.os.tag) {
            .windows => true,
            .linux => true,
            .macos => null,
            .wasi => true,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .HAVE_ERROR = switch (target.result.os.tag) {
            .windows => null,
            .linux => if (target.result.isGnuLibC()) true else null,
            .macos => null,
            .wasi => null,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .HAVE_ERROR_H = switch (target.result.os.tag) {
            .windows => true,
            .linux => if (target.result.isGnuLibC()) true else null,
            .macos => null,
            .wasi => null,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .HAVE_FACCESSAT = if (target.result.os.tag == .windows) null else true,
        .HAVE_FCNTL = if (target.result.os.tag == .windows) null else true,
        .HAVE_FEATURES_H = switch (target.result.os.tag) {
            .windows => null,
            .linux => true,
            .macos => null,
            .wasi => true,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .HAVE_FREE_POSIX = null,
        .HAVE_GETCWD = if (target.result.os.tag == .windows) null else true,
        .HAVE_GETC_UNLOCKED = if (target.result.os.tag == .windows) null else true,
        .HAVE_GETDTABLESIZE = switch (target.result.os.tag) {
            .windows => null,
            .linux => true,
            .macos => true,
            .wasi => null,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .HAVE_GETEXECNAME = null,
        .HAVE_GETPROGNAME = switch (target.result.os.tag) {
            .windows => null,
            .linux => null,
            .macos => true,
            .wasi => null,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .HAVE_GETTEXT = if (target.result.os.tag == .linux) true else null,
        .HAVE_ICONV = switch (target.result.os.tag) {
            .windows => null,
            .linux => true,
            .macos => null,
            .wasi => true,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .HAVE_INTTYPES_H = true,
        .HAVE_LANGINFO_CODESET = if (target.result.os.tag == .windows) null else true,
        .HAVE_LIMITS_H = true,
        .HAVE_LONG_LONG_INT = true,
        .HAVE_LSTAT = if (target.result.os.tag == .windows) null else true,
        .HAVE_MACH_O_DYLD_H = null,
        .HAVE_MALLOC_0_NONNULL = switch (target.result.os.tag) {
            .windows => true,
            .linux => true,
            .macos => null,
            .wasi => null,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .HAVE_MALLOC_POSIX = true,
        .HAVE_MALLOC_PTRDIFF = switch (target.result.os.tag) {
            .windows, .linux, .macos, .freebsd, .netbsd, .wasi => target.result.ptrBitWidth() > 32,
            else => @panic("unsupported OS"),
        },
        .HAVE_MBRTOWC = true,
        .HAVE_MBSINIT = if (target.result.os.tag == .windows) null else true,
        .HAVE_MBSTATE_T = true,
        .HAVE_MEMMOVE = true,
        .HAVE_MEMPCPY = switch (target.result.os.tag) {
            .windows => true,
            .linux => true,
            .macos => null,
            .wasi => true,
            .freebsd => true,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .HAVE_MINIX_CONFIG_H = null,
        .HAVE_MINMAX_IN_LIMITS_H = null,
        .HAVE_MINMAX_IN_SYS_PARAM_H = if (target.result.os.tag == .windows) null else true,
        .HAVE_MSVC_INVALID_PARAMETER_HANDLER = if (target.result.os.tag == .windows) true else null,
        .HAVE_RAISE = if (target.result.os.tag == .wasi) null else true,
        .HAVE_RAWMEMCHR = switch (target.result.os.tag) {
            .windows => null,
            .linux => if (target.result.isGnuLibC()) true else null,
            .macos => null,
            .wasi => null,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .HAVE_READLINK = if (target.result.os.tag == .windows) null else true,
        .HAVE_READLINKAT = if (target.result.os.tag == .windows) null else true,
        .HAVE_REALLOC_0_NONNULL = switch (target.result.os.tag) {
            .windows => null,
            .linux => if (target.result.isMuslLibC()) true else null,
            .macos => true,
            .wasi => null,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .HAVE_REALPATH = if (target.result.os.tag == .windows) null else true,
        .HAVE_SDKDDKVER_H = if (target.result.os.tag == .windows) true else null,
        .HAVE_SEARCH_H = true,
        .HAVE_SETDTABLESIZE = null,
        .HAVE_SETENV = if (target.result.os.tag == .windows) null else true,
        .HAVE_SETLOCALE = true,
        .HAVE_SIGNED_SIG_ATOMIC_T = null,
        .HAVE_SIGNED_WCHAR_T = null,
        .HAVE_SIGNED_WINT_T = null,
        .HAVE_SIGSET_T = switch (target.result.os.tag) {
            .windows => null,
            .linux => true,
            .macos => true,
            .wasi => null,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .HAVE_STDBOOL_H = true,
        .HAVE_STDCKDINT_H = true,
        .HAVE_STDINT_H = true,
        .HAVE_STDIO_H = true,
        .HAVE_STDLIB_H = true,
        .HAVE_STRERROR_R = if (target.result.os.tag == .windows) null else true,
        .HAVE_STRINGS_H = true,
        .HAVE_STRING_H = true,
        .HAVE_STRUCT_STAT_ST_ATIMENSEC = null,
        .HAVE_STRUCT_STAT_ST_ATIMESPEC_TV_NSEC = if (target.result.os.tag == .macos) true else null,
        .HAVE_STRUCT_STAT_ST_ATIM_ST__TIM_TV_NSEC = null,
        .HAVE_STRUCT_STAT_ST_ATIM_TV_NSEC = switch (target.result.os.tag) {
            .windows => null,
            .linux => true,
            .macos => null,
            .wasi => true,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .HAVE_STRUCT_STAT_ST_BIRTHTIMENSEC = null,
        .HAVE_STRUCT_STAT_ST_BIRTHTIMESPEC_TV_NSEC = switch (target.result.os.tag) {
            .windows => null,
            .linux => null,
            .macos => true,
            .wasi => null,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .HAVE_STRUCT_STAT_ST_BIRTHTIM_TV_NSEC = null,
        .HAVE_SYMLINK = if (target.result.os.tag == .windows) null else true,
        .HAVE_SYS_BITYPES_H = null,
        .HAVE_SYS_INTTYPES_H = null,
        .HAVE_SYS_PARAM_H = true,
        .HAVE_SYS_SOCKET_H = if (target.result.os.tag == .windows) null else true,
        .HAVE_SYS_STAT_H = true,
        .HAVE_SYS_TIME_H = true,
        .HAVE_SYS_TYPES_H = true,
        .HAVE_TSEARCH = true,
        .HAVE_UNISTD_H = true,
        .HAVE_UNISTRING_WOE32DLL_H = null,
        .HAVE_UNSIGNED_LONG_LONG_INT = true,
        .HAVE_VAR___PROGNAME = null,
        .HAVE_VISIBILITY = true,
        .HAVE_WCHAR_H = true,
        .HAVE_WCRTOMB = true,
        .HAVE_WINSOCK2_H = if (target.result.os.tag == .windows) true else null,
        .HAVE_WINT_T = true,
        .HAVE_WORKING_O_NOATIME = if (target.result.os.tag == .linux) true else false,
        .HAVE_WORKING_O_NOFOLLOW = if (target.result.os.tag == .linux) true else false,
        .HAVE__NSGETEXECUTABLEPATH = null,
        .HAVE__SET_INVALID_PARAMETER_HANDLER = if (target.result.os.tag == .windows) true else null,
        .HAVE___BUILTIN_EXPECT = true,
        .HAVE___HEADER_INLINE = if (target.result.os.tag == .macos) true else null,
        .HAVE___INLINE = true,
        .ICONV_CONST = {},
        .INSTALLPREFIX = {},
        .LSTAT_FOLLOWS_SLASHED_SYMLINK = if (target.result.os.tag == .linux) true else null,
        .LT_OBJDIR = ".libs/",
        .__USE_MINGW_ANSI_STDIO = true,
        .MUSL_LIBC = null,
        .NEED_SANITIZED_REALLOC = null,
        .OPEN_TRAILING_SLASH_BUG = null,
        .PACKAGE = "libiconv",
        .PACKAGE_BUGREPORT = "",
        .PACKAGE_NAME = "libiconv",
        .PACKAGE_STRING = b.fmt("libiconv {d}.{d}", .{ version.major, version.minor }),
        .PACKAGE_TARNAME = "libiconv",
        .PACKAGE_URL = "",
        .PACKAGE_VERSION = b.fmt("{d}.{d}", .{ version.major, version.minor }),
        .PROMOTED_MODE_T = @as(enum { int, mode_t }, switch (target.result.os.tag) {
            .windows => .int,
            .linux => .mode_t,
            .macos => .int,
            .wasi => .mode_t,
            .freebsd => .int,
            .netbsd => .mode_t,
            else => @panic("unsupported OS"),
        }),
        .PTRDIFF_T_SUFFIX = if (target.result.os.tag == .wasi) {} else null,
        .READLINK_TRAILING_SLASH_BUG = switch (target.result.os.tag) {
            .windows => null,
            .linux => null,
            .macos => true,
            .wasi => true,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .READLINK_TRUNCATE_BUG = switch (target.result.os.tag) {
            .windows => null,
            .linux => null,
            .macos => true,
            .wasi => true,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .REPLACE_FUNC_STAT_FILE = switch (target.result.os.tag) {
            .windows => null,
            .linux => null,
            .macos => true,
            .wasi => true,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .REPLACE_STRERROR_0 = switch (target.result.os.tag) {
            .windows => null,
            .linux => null,
            .macos => true,
            .wasi => true,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        .SIG_ATOMIC_T_SUFFIX = if (target.result.os.tag == .wasi) {} else null,
        .SIZE_T_SUFFIX = if (target.result.os.tag == .wasi) {} else null,
        .STACK_DIRECTION = null,
        .STAT_MACROS_BROKEN = null,
        .STDC_HEADERS = true,
        .STRERROR_R_CHAR_P = switch (target.result.os.tag) {
            .windows => null,
            .linux => if (target.result.isGnuLibC()) true else null,
            .macos => null,
            .wasi => null,
            .freebsd => null,
            .netbsd => null,
            else => @panic("unsupported OS"),
        },
        .TYPEOF_STRUCT_STAT_ST_ATIM_IS_STRUCT_TIMESPEC = switch (target.result.os.tag) {
            .windows => null,
            .linux => true,
            .macos => null,
            .wasi => true,
            .freebsd => true,
            .netbsd => true,
            else => @panic("unsupported OS"),
        },
        // .USER_LABEL_PREFIX = if (target.result.os.tag == .macos) ._ else {},
        ._ALL_SOURCE = true,
        ._DARWIN_C_SOURCE = true,
        .__EXTENSIONS__ = true,
        ._GNU_SOURCE = true,
        ._HPUX_ALT_XOPEN_SOCKET_API = true,
        ._MINIX = null,
        ._NETBSD_SOURCE = true,
        ._OPENBSD_SOURCE = true,
        ._POSIX_SOURCE = null,
        ._POSIX_1_SOURCE = null,
        ._POSIX_PTHREAD_SEMANTICS = true,
        .__STDC_WANT_IEC_60559_ATTRIBS_EXT__ = true,
        .__STDC_WANT_IEC_60559_BFP_EXT__ = true,
        .__STDC_WANT_IEC_60559_DFP_EXT__ = true,
        .__STDC_WANT_IEC_60559_EXT__ = true,
        .__STDC_WANT_IEC_60559_FUNCS_EXT__ = true,
        .__STDC_WANT_IEC_60559_TYPES_EXT__ = true,
        .__STDC_WANT_LIB_EXT2__ = true,
        .__STDC_WANT_MATH_SPEC_FUNCS__ = true,
        ._TANDEM_SOURCE = true,
        ._XOPEN_SOURCE = null,
        .USE_UNLOCKED_IO = .GNULIB_STDIO_SINGLE_THREAD,
        .VERSION = b.fmt("{d}.{d}", .{ version.major, version.minor }),
        .WCHAR_T_SUFFIX = if (target.result.os.tag == .wasi) {} else null,
        .WINT_T_SUFFIX = if (target.result.os.tag == .wasi) {} else null,
        .WORDS_BIGENDIAN = true,
        .WORDS_LITTLEENDIAN = true,
        ._FILE_OFFSET_BITS = @as(?i64, if (target.result.os.tag == .windows) 64 else null),
        ._ISOC11_SOURCE = null,
        ._LARGE_FILES = null,
        ._LINUX_SOURCE_COMPAT = true,
        ._TIME_BITS = null,
        ._USE_STD_STAT = true,
        .__MINGW_USE_VC2005_COMPAT = null,
        .__STDC_CONSTANT_MACROS = null,
        .__STDC_LIMIT_MACROS = null,
        .__STDC_NO_VLA__ = null,
        .gid_t = @as(?enum { int }, if (target.result.os.tag == .windows) .int else null),
        .mbstate_t = null,
        .mode_t = null,
        .nlink_t = @as(?enum { int }, if (target.result.os.tag == .windows) .int else null),
        .pid_t = null,
        .restrict = .__restrict__,
        .size_t = null,
        .ssize_t = null,
        .uid_t = @as(?enum { int }, if (target.result.os.tag == .windows) .int else null),
    });
    if (target.result.os.tag == .macos) {
        config_h.addValue("USER_LABEL_PREFIX", enum { @"_" }, ._);
    } else {
        config_h.addValue("USER_LABEL_PREFIX", void, {});
    }

    const public_iconv_h = b.addConfigHeader(.{
        .style = .{ .autoconf_at = upstream.path("include/iconv.h.in") },
    }, .{
        .DLL_VARIABLE = {},
        .EILSEQ = {},
        .ICONV_CONST = {},
        .USE_MBSTATE_T = true,
        .BROKEN_WCHAR_H = false,
    });

    const libiconv = b.addLibrary(.{
        .name = "iconv",
        .linkage = linkage,
        .version = .{ .major = 2, .minor = 7, .patch = 0 },
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .strip = strip,
            .pic = pic,
            .link_libc = true,
        }),
    });
    libiconv.installConfigHeader(public_iconv_h);
    libiconv.root_module.addConfigHeader(libcharset_h);
    libiconv.root_module.addConfigHeader(localcharset_h);
    libiconv.root_module.addConfigHeader(libiconv_config_header);
    libiconv.root_module.addIncludePath(upstream.path("lib"));
    libiconv.root_module.addConfigHeader(iconv_h);
    libiconv.root_module.addIncludePath(upstream.path("include"));
    libiconv.root_module.addConfigHeader(config_h);
    libiconv.root_module.addIncludePath(upstream.path(""));
    libiconv.root_module.addCMacro("BUILDING_LIBICONV", "1");
    libiconv.root_module.addCMacro("BUILDING_LIBCHARSET", "1");
    libiconv.root_module.addCMacro("HAVE_CONFIG_H", "1");
    libiconv.root_module.addCSourceFiles(.{
        .root = upstream.path("lib"),
        .files = &.{
            "iconv.c",
            "../libcharset/lib/localcharset.c",
            "compat.c",
        },
        .flags = &.{ "-fvisibility=hidden", "-Wno-parentheses-equality" },
    });
    b.installArtifact(libiconv);
}
