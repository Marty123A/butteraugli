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

butteraugli_deps = module_extension(
    implementation = _butteraugli_deps_impl,
)
