load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

config_setting(
    name = "windows",
    constraint_values = ["@platforms//os:windows"],
)

# MSVC does not support -Wno-sign-compare; use /wd4018 (signed/unsigned) and /wd4389 (compare).
_MSVC_COPTS = ["/wd4018", "/wd4389", "/D_CRT_SECURE_NO_WARNINGS"]
_GCC_CLANG_COPTS = ["-Wno-sign-compare", "-D_CRT_SECURE_NO_WARNINGS"]

cc_library(
    name = "butteraugli_lib",
    srcs = [
        "butteraugli/butteraugli.cc",
        "butteraugli/butteraugli.h",
    ],
    hdrs = [
        "butteraugli/butteraugli.h",
    ],
    copts = select({
        ":windows": _MSVC_COPTS,
        "//conditions:default": _GCC_CLANG_COPTS,
    }),
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "butteraugli",
    srcs = ["butteraugli/butteraugli_main.cc"],
    copts = select({
        ":windows": _MSVC_COPTS,
        "//conditions:default": _GCC_CLANG_COPTS,
    }),
    visibility = ["//visibility:public"],
    deps = [
        ":butteraugli_lib",
        "@jpeg_archive//:jpeg",
        "@png_archive//:png",
        "@webp_archive//:webp",
        "@avif_archive//:avif",
    ],
)
