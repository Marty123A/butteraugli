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
            "https://mirror.bazel.build/github.com/pnggroup/libpng/archive/refs/tags/v1.6.43.tar.gz",
            "https://github.com/pnggroup/libpng/archive/refs/tags/v1.6.43.tar.gz",
        ],
        sha256 = "fecc95b46cf05e8e3fc8a414750e0ba5aad00d89e9fdf175e94ff041caf1a03a",
        stripPrefix = "libpng-1.6.43",
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

def _dav1d_archive_impl(ctx):
    """Fetch dav1d AV1 decoder and generate config.h and version.h."""
    ctx.download_and_extract(
        url = [
            "https://mirror.bazel.build/github.com/videolan/dav1d/archive/refs/tags/1.4.3.tar.gz",
            "https://github.com/videolan/dav1d/archive/refs/tags/1.4.3.tar.gz",
        ],
        # SHA256 for github.com/videolan/dav1d/archive/refs/tags/1.4.3.tar.gz
        sha256 = "88a023e58d955e0886faf49c72940e0e90914a948a8e60c1326ce3e09e7a6099",
        stripPrefix = "dav1d-1.4.3",
    )
    # Generate version.h from version.h.in (API version 7.0.0 for dav1d 1.4.3)
    version_h = """#ifndef DAV1D_VERSION_H
#define DAV1D_VERSION_H

#ifdef __cplusplus
extern "C" {
#endif

#define DAV1D_API_VERSION_MAJOR 7
#define DAV1D_API_VERSION_MINOR 0
#define DAV1D_API_VERSION_PATCH 0

#define DAV1D_API_MAJOR(v) (((v) >> 16) & 0xFF)
#define DAV1D_API_MINOR(v) (((v) >> 8) & 0xFF)
#define DAV1D_API_PATCH(v) (((v) >> 0) & 0xFF)

#ifdef __cplusplus
}
#endif

#endif
"""
    ctx.file("include/dav1d/version.h", content = version_h)
    # Generate vcs_version.h (version 1.4.3)
    vcs_version_h = """/* auto-generated, do not edit */
#ifndef DAV1D_VERSION
#define DAV1D_VERSION "1.4.3"
#endif
"""
    ctx.file("vcs_version.h", content = vcs_version_h)
    # Generate config.h for decoder build with platform detection
    # NOTE: We disable architecture-specific SIMD optimizations for simplicity
    # (no ARCH_X86, ARCH_AARCH64, etc.) to avoid needing assembly sources
    config_h = """#ifndef DAV1D_CONFIG_H
#define DAV1D_CONFIG_H

#define CONFIG_8BPC 1
#define CONFIG_16BPC 0
#define BITDEPTH 8

/* Disable architecture-specific SIMD optimizations (use C fallbacks only)
 * This avoids needing to include arch-specific assembly/intrinsics sources */
#define ARCH_X86 0
#define ARCH_X86_32 0
#define ARCH_X86_64 0
#define ARCH_AARCH64 0
#define ARCH_ARM 0
#define ARCH_PPC64LE 0
#define ARCH_RISCV 0
#define ARCH_LOONGARCH 0

/* Platform-specific settings */
#if defined(_WIN32)
/* Windows has memalign via _aligned_malloc */
#define HAVE_ALIGNED_MALLOC 1
#define UNICODE 1
#define _UNICODE 1
#define _CRT_SECURE_NO_WARNINGS 1
#elif defined(__APPLE__)
/* macOS/iOS - no malloc.h, use posix_memalign from stdlib.h */
#define HAVE_UNISTD_H 1
#define HAVE_POSIX_MEMALIGN 1
#define HAVE_CLOCK_GETTIME 1
#else
/* Linux and other Unix */
#define HAVE_UNISTD_H 1
#define HAVE_POSIX_MEMALIGN 1
#define HAVE_CLOCK_GETTIME 1
#endif

/* Threading support */
#if !defined(_WIN32)
#define HAVE_PTHREAD_H 1
#endif

#endif
"""
    ctx.file("config.h", content = config_h)
    ctx.file("BUILD.bazel", content = ctx.read(Label("//:dav1d.BUILD")))

dav1d_archive = repository_rule(
    implementation = _dav1d_archive_impl,
)

def _avif_archive_impl(ctx):
    """Fetch libavif and configure for decoder-only build."""
    ctx.download_and_extract(
        url = [
            "https://mirror.bazel.build/github.com/AOMediaCodec/libavif/archive/refs/tags/v1.3.0.tar.gz",
            "https://github.com/AOMediaCodec/libavif/archive/refs/tags/v1.3.0.tar.gz",
        ],
        # SHA256 for github.com/AOMediaCodec/libavif/archive/refs/tags/v1.3.0.tar.gz
        sha256 = "0a545e953cc049bf5bcf4ee467306a2f113a75110edf59e61248873101cd26c1",
        stripPrefix = "libavif-1.3.0",
    )
    # Create stub implementations for libyuv functions
    # These stubs match libavif v1.3.0 API
    avif_stubs = """/* Stub implementations for libavif functions that require libyuv/libsharpyuv */
#include "avif/avif.h"

avifResult avifImageRGBToYUVLibYUV(avifImage * image, const avifRGBImage * rgb) {
    (void)image; (void)rgb;
    return AVIF_RESULT_NOT_IMPLEMENTED;
}

avifResult avifImageYUVToRGBLibYUV(const avifImage * image, avifRGBImage * rgb) {
    (void)image; (void)rgb;
    return AVIF_RESULT_NOT_IMPLEMENTED;
}

avifResult avifImageRGBToYUVLibSharpYUV(avifImage * image, const avifRGBImage * rgb) {
    (void)image; (void)rgb;
    return AVIF_RESULT_NOT_IMPLEMENTED;
}

avifResult avifRGBImageToF16LibYUV(const avifRGBImage * rgb, avifRGBImage * rgb16) {
    (void)rgb; (void)rgb16;
    return AVIF_RESULT_NOT_IMPLEMENTED;
}

/* Internal scaling function with size limits - called by avifImageScale and internally */
avifResult avifImageScaleWithLimit(avifImage * image, uint32_t dstWidth, uint32_t dstHeight,
                                   uint32_t imageSizeLimit, uint32_t imageDimensionLimit,
                                   avifDiagnostics * diag) {
    (void)image; (void)dstWidth; (void)dstHeight;
    (void)imageSizeLimit; (void)imageDimensionLimit; (void)diag;
    return AVIF_RESULT_NOT_IMPLEMENTED;
}

/* avifImageScale scales the YUV/A planes in-place. Public API in libavif 1.3.0 */
avifResult avifImageScale(avifImage * image, uint32_t dstWidth, uint32_t dstHeight, avifDiagnostics * diag) {
    (void)image; (void)dstWidth; (void)dstHeight; (void)diag;
    return AVIF_RESULT_NOT_IMPLEMENTED;
}

void avifRGBImagePremultiplyAlphaLibYUV(avifRGBImage * rgb) {
    (void)rgb;
}

void avifRGBImageUnpremultiplyAlphaLibYUV(avifRGBImage * rgb) {
    (void)rgb;
}
"""
    ctx.file("src/avif_stubs.c", content = avif_stubs)
    ctx.file("BUILD.bazel", content = ctx.read(Label("//:avif.BUILD")))

avif_archive = repository_rule(
    implementation = _avif_archive_impl,
)

def _butteraugli_deps_impl(mctx):
    # Order: zlib first (png depends on it), then png and jpeg.
    http_archive(
        name = "zlib_archive",
        build_file = "@//:zlib.BUILD",
        sha256 = "9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23",
        strip_prefix = "zlib-1.3.1",
        urls = [
            "https://mirror.bazel.build/zlib.net/zlib-1.3.1.tar.gz",
            "https://zlib.net/zlib-1.3.1.tar.gz",
            "https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz",
        ],
    )
    png_archive(name = "png_archive")
    jpeg_archive(name = "jpeg_archive")
    webp_archive(name = "webp_archive")
    dav1d_archive(name = "dav1d_archive")
    avif_archive(name = "avif_archive")

butteraugli_deps = module_extension(
    implementation = _butteraugli_deps_impl,
)
