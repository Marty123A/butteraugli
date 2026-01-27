"""Module extension that provides png, zlib, and jpeg archives for Bzlmod."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _jpeg_archive_impl(ctx):
    """Fetch jpeg and add jconfig.h so we avoid genrule/bash on Windows."""
    ctx.download_and_extract(
        url = [
            "https://mirror.bazel.build/www.ijg.org/files/jpegsrc.v9b.tar.gz",
            "http://www.ijg.org/files/jpegsrc.v9b.tar.gz",
        ],
        sha256 = "240fd398da741669bf3c90366f58452ea59041cacc741a489b99f2f6a0bad052",
        stripPrefix = "jpeg-9b",
    )
    ctx.file("jconfig.h", content = ctx.read(Label("//:jconfig.h")))
    ctx.file("BUILD.bazel", content = ctx.read(Label("//:jpeg.BUILD")))

jpeg_archive = repository_rule(
    implementation = _jpeg_archive_impl,
)

def _png_archive_impl(ctx):
    """Fetch libpng and add pnglibconf.h from scripts/pnglibconf.h.prebuilt."""
    ctx.download_and_extract(
        url = [
            "https://mirror.bazel.build/github.com/glennrp/libpng/archive/v1.6.34.tar.gz",
            "https://github.com/glennrp/libpng/archive/v1.6.34.tar.gz",
        ],
        sha256 = "e45ce5f68b1d80e2cb9a2b601605b374bdf51e1798ef1c2c2bd62131dfcf9eef",
        stripPrefix = "libpng-1.6.34",
    )
    # libpng needs pnglibconf.h; use prebuilt to avoid subprocess on Windows.
    ctx.file("pnglibconf.h", content = ctx.read("scripts/pnglibconf.h.prebuilt"))
    ctx.file("BUILD.bazel", content = ctx.read(Label("//:png.BUILD")))

png_archive = repository_rule(
    implementation = _png_archive_impl,
)

def _webp_archive_impl(ctx):
    """Fetch libwebp and add minimal src/webp/config.h for decoder build."""
    ctx.download_and_extract(
        url = [
            "https://mirror.bazel.build/github.com/webmproject/libwebp/archive/refs/tags/v1.3.2.tar.gz",
            "https://github.com/webmproject/libwebp/archive/refs/tags/v1.3.2.tar.gz",
        ],
        # SHA256 for github.com/webmproject/libwebp/archive/refs/tags/v1.3.2.tar.gz
        sha256 = "c2c2f521fa468e3c5949ab698c2da410f5dce1c5e99f5ad9e70e0e8446b86505",
        stripPrefix = "libwebp-1.3.2",
    )
    # Minimal config.h for decoder (no SIMD, no extra deps).
    # Use preprocessor so MSVC gets intrinsics and GCC/Clang use builtins (avoids ctx.os caching).
    config_h = """/* Minimal config for butteraugli decoder-only build */
#ifndef WEBP_CONFIG_H_
#define WEBP_CONFIG_H_
#define HAVE_CONFIG_H 1
#ifdef _MSC_VER
#include <stdlib.h>
#define __builtin_bswap16(x) _byteswap_ushort(x)
#define __builtin_bswap32(x) _byteswap_ulong(x)
#define __builtin_bswap64(x) _byteswap_uint64(x)
#else
#define HAVE_BUILTIN_BSWAP16 1
#define HAVE_BUILTIN_BSWAP32 1
#define HAVE_BUILTIN_BSWAP64 1
#endif
#endif
"""
    ctx.file("src/webp/config.h", content = config_h)
    ctx.file("BUILD.bazel", content = ctx.read(Label("//:webp.BUILD")))

webp_archive = repository_rule(
    implementation = _webp_archive_impl,
)

def _butteraugli_deps_impl(mctx):
    # Order: zlib first (png depends on it), then png and jpeg.
    http_archive(
        name = "zlib_archive",
        build_file = "@//:zlib.BUILD",
        sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
        strip_prefix = "zlib-1.2.11",
        urls = [
            "https://mirror.bazel.build/zlib.net/zlib-1.2.11.tar.gz",
            "https://zlib.net/zlib-1.2.11.tar.gz",
        ],
    )
    png_archive(name = "png_archive")
    jpeg_archive(name = "jpeg_archive")
    webp_archive(name = "webp_archive")

butteraugli_deps = module_extension(
    implementation = _butteraugli_deps_impl,
)
