# Decoder-only build of dav1d for butteraugli.
# This is a simplified build focusing on core decoder functionality.

load("@rules_cc//cc:defs.bzl", "cc_library")

licenses(["notice"])

config_setting(
    name = "windows",
    constraint_values = ["@platforms//os:windows"],
)

# Core decoder sources from dav1d meson.build
_DAV1D_SRCS = [
    "src/cdf.c",
    "src/cpu.c",
    "src/data.c",
    "src/decode.c",
    "src/dequant_tables.c",
    "src/getbits.c",
    "src/intra_edge.c",
    "src/itx_1d.c",
    "src/lf_mask.c",
    "src/lib.c",
    "src/log.c",
    "src/mem.c",
    "src/msac.c",
    "src/obu.c",
    "src/pal.c",
    "src/picture.c",
    "src/qm.c",
    "src/ref.c",
    "src/refmvs.c",
    "src/scan.c",
    "src/tables.c",
    "src/thread_task.c",
    "src/warpmv.c",
    "src/wedge.c",
    # Windows threading support
    "src/win32/thread.c",
    # Template sources (compiled for each bitdepth)
    "src/cdef_apply_tmpl.c",
    "src/cdef_tmpl.c",
    "src/fg_apply_tmpl.c",
    "src/filmgrain_tmpl.c",
    "src/ipred_prepare_tmpl.c",
    "src/ipred_tmpl.c",
    "src/itx_tmpl.c",
    "src/lf_apply_tmpl.c",
    "src/loopfilter_tmpl.c",
    "src/looprestoration_tmpl.c",
    "src/lr_apply_tmpl.c",
    "src/mc_tmpl.c",
    "src/recon_tmpl.c",
]

_DAV1D_HDRS = [
    "include/dav1d/dav1d.h",
    "include/dav1d/version.h",
    "include/dav1d/picture.h",
    "include/dav1d/data.h",
    "include/dav1d/headers.h",
    "include/dav1d/common.h",
    "include/common/attributes.h",
    "include/common/bitdepth.h",
    "include/common/dump.h",
    "include/common/frame.h",
    "include/common/intops.h",
    "include/common/validate.h",
    "src/cdef.h",
    "src/cdef_apply.h",
    "src/cdf.h",
    "src/cpu.h",
    "src/ctx.h",
    "src/data.h",
    "src/decode.h",
    "src/dequant_tables.h",
    "src/env.h",
    "src/internal.h",
    "src/fg_apply.h",
    "src/filmgrain.h",
    "src/getbits.h",
    "src/intra_edge.h",
    "src/ipred.h",
    "src/ipred_prepare.h",
    "src/itx.h",
    "src/itx_1d.h",
    "src/lf_apply.h",
    "src/lf_mask.h",
    "src/levels.h",
    "src/log.h",
    "src/loopfilter.h",
    "src/looprestoration.h",
    "src/lr_apply.h",
    "src/mc.h",
    "src/mem.h",
    "src/msac.h",
    "src/obu.h",
    "src/pal.h",
    "src/picture.h",
    "src/qm.h",
    "src/recon.h",
    "src/ref.h",
    "src/refmvs.h",
    "src/thread.h",
    "src/thread_data.h",
    "src/thread_task.h",
    "src/wedge.h",
    "src/scan.h",
    "src/tables.h",
    "src/warpmv.h",
    "vcs_version.h",
    "config.h",
]

cc_library(
    name = "dav1d",
    srcs = _DAV1D_SRCS,
    hdrs = _DAV1D_HDRS,
    includes = ["include", "."],
    # dav1d requires C11 for atomics support
    # MSVC needs /std:c17 with /experimental:c11atomics for C11 atomics
    copts = select({
        ":windows": ["/std:c17", "/experimental:c11atomics"],
        "//conditions:default": ["-std=c11"],
    }),
    local_defines = [
        "CONFIG_8BPC=1",
        "CONFIG_16BPC=0",  # Disable 16-bit support (we only build 8-bit sources)
        "BITDEPTH=8",  # Default bitdepth for template sources (8-bit only for simplicity)
    ],
    linkopts = select({
        ":windows": [],
        "//conditions:default": ["-lm", "-lpthread"],
    }),
    visibility = ["//visibility:public"],
)
