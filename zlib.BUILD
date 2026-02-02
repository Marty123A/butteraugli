package(default_visibility = ["//visibility:public"])

load("@rules_cc//cc:defs.bzl", "cc_library")

licenses(["notice"])  # BSD/MIT-like license (for zlib)

config_setting(
    name = "macos",
    constraint_values = ["@platforms//os:macos"],
)

cc_library(
    name = "zlib",
    srcs = [
        "adler32.c",
        "compress.c",
        "crc32.c",
        "crc32.h",
        "deflate.c",
        "deflate.h",
        "gzclose.c",
        "gzguts.h",
        "gzlib.c",
        "gzread.c",
        "gzwrite.c",
        "infback.c",
        "inffast.c",
        "inffast.h",
        "inffixed.h",
        "inflate.c",
        "inflate.h",
        "inftrees.c",
        "inftrees.h",
        "trees.c",
        "trees.h",
        "uncompr.c",
        "zconf.h",
        "zutil.c",
        "zutil.h",
    ],
    hdrs = ["zlib.h"],
    includes = ["."],
    # Ensure proper platform detection on modern systems
    local_defines = select({
        ":macos": ["HAVE_UNISTD_H", "HAVE_STDARG_H"],
        "//conditions:default": [],
    }),
)
