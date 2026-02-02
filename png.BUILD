# Description:
#   libpng is the official PNG reference library.

load("@rules_cc//cc:defs.bzl", "cc_library")

licenses(["notice"])  # BSD/MIT-like license

config_setting(
    name = "macos",
    constraint_values = ["@platforms//os:macos"],
)

config_setting(
    name = "windows",
    constraint_values = ["@platforms//os:windows"],
)

cc_library(
    name = "png",
    srcs = [
        "png.c",
        "pngerror.c",
        "pngget.c",
        "pngmem.c",
        "pngpread.c",
        "pngread.c",
        "pngrio.c",
        "pngrtran.c",
        "pngrutil.c",
        "pngset.c",
        "pngtrans.c",
        "pngwio.c",
        "pngwrite.c",
        "pngwtran.c",
        "pngwutil.c",
    ],
    hdrs = [
        "png.h",
        "pngconf.h",
        "pngdebug.h",
        "pnginfo.h",
        "pnglibconf.h",
        "pngpriv.h",
        "pngstruct.h",
    ],
    includes = ["."],
    # Disable ARM NEON optimizations to avoid needing arm/ source files
    # This uses pure C implementation which works on all platforms
    local_defines = select({
        ":macos": ["PNG_ARM_NEON_OPT=0"],
        "//conditions:default": [],
    }),
    linkopts = select({
        ":windows": [],
        "//conditions:default": ["-lm"],
    }),
    visibility = ["//visibility:public"],
    deps = ["@zlib_archive//:zlib"],
)
