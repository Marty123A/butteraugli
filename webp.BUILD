# Decoder-only build of libwebp for butteraugli (WebPDecodeRGBA).
# Sources from src/dec, src/dsp (decode), src/utils (decode).

load("@rules_cc//cc:defs.bzl", "cc_library")

licenses(["notice"])

# Only link -lm on non-Windows; MSVC does not use it.
config_setting(
    name = "windows",
    constraint_values = ["@platforms//os:windows"],
)

_DEC_SRCS = [
    "src/dec/alpha_dec.c",
    "src/dec/buffer_dec.c",
    "src/dec/frame_dec.c",
    "src/dec/idec_dec.c",
    "src/dec/io_dec.c",
    "src/dec/quant_dec.c",
    "src/dec/tree_dec.c",
    "src/dec/vp8_dec.c",
    "src/dec/vp8l_dec.c",
    "src/dec/webp_dec.c",
]

_DSP_DEC_SRCS = [
    "src/dsp/alpha_processing.c",
    "src/dsp/cpu.c",
    "src/dsp/dec.c",
    "src/dsp/dec_clip_tables.c",
    "src/dsp/filters.c",
    "src/dsp/lossless.c",
    "src/dsp/rescaler.c",
    "src/dsp/upsampling.c",
    "src/dsp/yuv.c",
]

_UTILS_DEC_SRCS = [
    "src/utils/bit_reader_utils.c",
    "src/utils/color_cache_utils.c",
    "src/utils/filters_utils.c",
    "src/utils/huffman_utils.c",
    "src/utils/quant_levels_dec_utils.c",
    "src/utils/rescaler_utils.c",
    "src/utils/random_utils.c",
    "src/utils/thread_utils.c",
    "src/utils/utils.c",
]

# All headers included by the decoder sources (required for undeclared inclusion check).
_WEBP_HDRS = [
    "src/webp/decode.h",
    "src/webp/encode.h",
    "src/webp/format_constants.h",
    "src/webp/mux_types.h",
    "src/webp/types.h",
    "src/webp/config.h",
]
_DEC_HDRS = [
    "src/dec/alphai_dec.h",
    "src/dec/common_dec.h",
    "src/dec/vp8_dec.h",
    "src/dec/vp8i_dec.h",
    "src/dec/vp8li_dec.h",
    "src/dec/webpi_dec.h",
]
_DSP_HDRS = [
    "src/dsp/cpu.h",
    "src/dsp/dsp.h",
    "src/dsp/lossless.h",
    "src/dsp/lossless_common.h",
    "src/dsp/yuv.h",
]
_UTILS_HDRS = [
    "src/utils/bit_reader_utils.h",
    "src/utils/bit_reader_inl_utils.h",
    "src/utils/color_cache_utils.h",
    "src/utils/endian_inl_utils.h",
    "src/utils/filters_utils.h",
    "src/utils/huffman_utils.h",
    "src/utils/quant_levels_dec_utils.h",
    "src/utils/rescaler_utils.h",
    "src/utils/random_utils.h",
    "src/utils/thread_utils.h",
    "src/utils/utils.h",
]
# Encoder headers included by src/dsp/lossless.c (shared structures).
_ENC_HDRS = [
    "src/enc/backward_references_enc.h",
    "src/enc/histogram_enc.h",
]

cc_library(
    name = "webp",
    srcs = _DEC_SRCS + _DSP_DEC_SRCS + _UTILS_DEC_SRCS,
    hdrs = _WEBP_HDRS + _DEC_HDRS + _DSP_HDRS + _UTILS_HDRS + _ENC_HDRS,
    includes = ["src"],
    local_defines = ["HAVE_CONFIG_H=1"],
    # Force-include config.h first on MSVC so __builtin_bswap* macros are visible everywhere.
    copts = select({
        ":windows": ["/FIwebp/config.h"],
        "//conditions:default": [],
    }),
    linkopts = select({
        ":windows": [],
        "//conditions:default": ["-lm"],
    }),
    visibility = ["//visibility:public"],
)
