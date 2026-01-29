# Decoder-only build of libavif for butteraugli.
# Sources from src/ directory, decoder-focused.

load("@rules_cc//cc:defs.bzl", "cc_library")

licenses(["notice"])

config_setting(
    name = "windows",
    constraint_values = ["@platforms//os:windows"],
)

# Core decoder sources from libavif
_AVIF_SRCS = [
    "src/alpha.c",
    "src/avif.c",
    "src/colr.c",
    "src/colrconvert.c",
    "src/diag.c",
    "src/exif.c",
    "src/gainmap.c",
    "src/io.c",
    "src/mem.c",
    "src/obu.c",
    "src/properties.c",
    "src/rawdata.c",
    "src/read.c",
    "src/reformat.c",
    # Exclude libyuv-dependent files (we don't have libyuv)
    # "src/reformat_libsharpyuv.c",  # Requires libsharpyuv
    # "src/reformat_libyuv.c",  # Requires libyuv
    # "src/scale.c",  # Requires libyuv
    "src/stream.c",
    "src/utils.c",
    # Codec support - dav1d decoder
    "src/codec_dav1d.c",
    # Stub implementations for libyuv functions
    "src/avif_stubs.c",
]

# Headers needed by decoder
# Public headers and internal headers that are included by source files.
# All headers are under include/avif/ in the libavif archive.
# Bazel requires these to be in hdrs for dependency tracking.
_AVIF_HDRS = [
    "include/avif/avif.h",
    "include/avif/avif_cxx.h",
    "include/avif/internal.h",
]

cc_library(
    name = "avif",
    srcs = _AVIF_SRCS,
    hdrs = _AVIF_HDRS,
    # Include path: all headers are under include/avif/
    includes = ["include"],
    deps = [
        "@dav1d_archive//:dav1d",
    ],
    local_defines = [
        "AVIF_CODEC_DAV1D=1",
        # Disable libyuv/libsharpyuv features (we don't have these libraries)
        "AVIF_LOCAL_LIBYUV=0",
        "AVIF_LOCAL_LIBSHARPYUV=0",
    ],
    # Don't require internal headers to be explicitly listed if they're in include path
    # Bazel will find them automatically when compiling sources
    linkopts = select({
        ":windows": [],
        "//conditions:default": ["-lm", "-lpthread"],
    }),
    visibility = ["//visibility:public"],
)
