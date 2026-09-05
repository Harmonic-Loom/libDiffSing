#pragma once

/**
 * @file Platforms.h
 * @brief 编译器检测、平台判断、指令集检测和导出宏定义.
 */

/** @name 编译器检测 */
/** @{ */

/**
 * 下列编译器宏采用布尔风格：命中时定义为 1，未命中时不定义。
 */

/**
 * @def DS_CLANG
 * @brief 当前编译器为 Clang 时定义为 1.
 */

/**
 * @def DS_CLANG_CL
 * @brief 当前编译器为 Clang-CL 时定义为 1.
 */

/**
 * @def DS_GCC
 * @brief 当前编译器为 GCC 或兼容 GCC 的编译器时定义为 1.
 */

/**
 * @def DS_MSVC
 * @brief 当前编译器为 MSVC 时定义为 1.
 */

/**
 * @def DS_INTEL
 * @brief 当前编译器为 Intel C++ 编译器时定义为 1.
 */

/**
 * @def DS_MINGW
 * @brief 当前编译器工具链为 MinGW 时定义为 1.
 */

/**
 * @def DS_EMSCRIPTEN
 * @brief 当前编译器工具链为 Emscripten 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_CLANG 1
#define DS_CLANG_CL 1
#define DS_GCC 1
#define DS_MSVC 1
#define DS_INTEL 1
#define DS_MINGW 1
#define DS_EMSCRIPTEN 1
#elif defined(__clang__)
#define DS_CLANG 1
#if defined(_MSC_VER)
#define DS_CLANG_CL 1
#endif
#elif defined(__INTEL_LLVM_COMPILER) || defined(__INTEL_COMPILER)
#define DS_INTEL 1
#elif defined(__GNUC__)
#define DS_GCC 1
#elif defined(_MSC_VER)
#define DS_MSVC 1
#endif

#if defined(__MINGW32__) || defined(__MINGW64__)
#define DS_MINGW 1
#endif
#if defined(__EMSCRIPTEN__)
#define DS_EMSCRIPTEN 1
#endif

/**
 * @def DS_COMPILER_STR
 * @brief 当前编译器的字符串标识.
 *
 * 字符串宏基于上面的编译器布尔宏展开，便于日志和文档展示。
 */

#if defined(DOXYGEN)
#define DS_COMPILER_STR
#elif defined(DS_EMSCRIPTEN)
#define DS_COMPILER_STR "Emscripten"
#elif defined(DS_CLANG_CL)
#define DS_COMPILER_STR "Clang-CL"
#elif defined(DS_CLANG)
#define DS_COMPILER_STR "Clang"
#elif defined(DS_INTEL)
#define DS_COMPILER_STR "Intel"
#elif defined(DS_MINGW)
#define DS_COMPILER_STR "MinGW"
#elif defined(DS_GCC)
#define DS_COMPILER_STR "GCC"
#elif defined(DS_MSVC)
#define DS_COMPILER_STR "MSVC"
#else
#define DS_COMPILER_STR "Unknown"
#endif

/** @} */

/** @name 构建模式 */
/** @{ */

/**
 * 下列构建模式宏采用布尔风格：命中时定义为 1，未命中时不定义。
 */

/**
 * @def DS_BUILD_DEBUG
 * @brief 当前编译单元为 Debug 构建模式时定义为 1.
 */

/**
 * @def DS_BUILD_RELEASE
 * @brief 当前编译单元为 Release 构建模式时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_BUILD_DEBUG 1
#define DS_BUILD_RELEASE 1
#elif defined(NDEBUG) && !defined(_DEBUG)
#define DS_BUILD_RELEASE 1
#else
#define DS_BUILD_DEBUG 1
#endif

/**
 * @def DS_BUILD_MODE_STR
 * @brief 当前构建模式的字符串标识.
 *
 * 字符串宏基于上面的构建模式布尔宏展开，便于日志和文档展示。
 */

#if defined(DOXYGEN)
#define DS_BUILD_MODE_STR
#elif defined(DS_BUILD_DEBUG)
#define DS_BUILD_MODE_STR "Debug"
#else
#define DS_BUILD_MODE_STR "Release"
#endif

/** @} */

/** @name 符号导出 */
/** @{ */

/**
 * @def DS_Export
 * @brief 符号导出属性.
 *
 * MSVC / Clang-CL / MinGW 下使用 `__declspec(dllexport)`，其余支持可见性属性
 * 的编译器使用 `__attribute__((visibility("default")))`。
 */

/**
 * @def DS_Import
 * @brief 符号导入属性.
 *
 * MSVC / Clang-CL / MinGW 下使用 `__declspec(dllimport)`，其余支持可见性属性
 * 的编译器使用 `__attribute__((visibility("default")))`。
 */

#if defined(DOXYGEN)
#define DS_Export
#define DS_Import
#elif DS_MSVC || DS_CLANG_CL || DS_MINGW
#define DS_Export __declspec(dllexport)
#define DS_Import __declspec(dllimport)
#else
#define DS_Export __attribute__((visibility("default")))
#define DS_Import __attribute__((visibility("default")))
#endif

/**
 * @def DS_API
 * @brief 公共 API 可见性修饰符.
 *
 * - 构建 DLL 时（ @c DS_DLL_BUILD ）展开为 DS_Export
 * - 使用 DLL 时（ @c DS_DLL ）展开为 DS_Import
 * - 静态链接时展开为空
 */

#if defined(DOXYGEN)
#define DS_API
#elif DS_DLL_BUILD
#define DS_API DS_Export
#elif DS_DLL
#define DS_API DS_Import
#else
#define DS_API
#endif

/** @} */

/** @name 调用约定 */
/** @{ */

/**
 * @def DS_Call
 * @brief 函数调用约定.
 *
 * MSVC / Clang-CL 下为 `_fastcall`，Intel 编译器下为空间兼容保留，
 * 其余编译器为空。
 */

#if defined(DOXYGEN)
#define DS_Call
#elif DS_MSVC || DS_CLANG_CL
#define DS_Call _fastcall
#else
#define DS_Call
#endif

/** @} */

/** @name 内联属性 */
/** @{ */

/**
 * @def DS_INLINE
 * @brief 强制内联属性.
 *
 * 根据编译器分别展开为 `inline`、`[[msvc::forceinline]] inline`、`__forceinline`、
 * `inline [[gnu::always_inline]]` 或 `inline [[clang::always_inline]]`。
 */

#if defined(DOXYGEN)
#define DS_INLINE
#elif DS_MSVC || DS_CLANG_CL
#define DS_INLINE [[msvc::forceinline]] inline
#elif DS_INTEL
#define DS_INLINE __forceinline
#elif DS_GCC || DS_EMSCRIPTEN
#define DS_INLINE [[gnu::always_inline]] inline
#elif DS_CLANG
#define DS_INLINE [[clang::always_inline]] inline
#else
#define DS_INLINE inline
#endif

/** @} */

/** @name 平台判断 */
/** @{ */

/**
 * 下列平台宏采用布尔风格：命中时定义为 1，未命中时不定义。
 */

/**
 * @def DS_PLATFORM_WINDOWS
 * @brief 当前目标平台为 Windows 时定义为 1.
 */

/**
 * @def DS_PLATFORM_MINGW
 * @brief 当前目标平台为 MinGW 时定义为 1.
 */

/**
 * @def DS_PLATFORM_CYGWIN
 * @brief 当前目标平台为 Cygwin 时定义为 1.
 */

/**
 * @def DS_PLATFORM_APPLE
 * @brief 当前目标平台为 Apple 系列平台时定义为 1.
 */

/**
 * @def DS_PLATFORM_MACCATALYST
 * @brief 当前目标平台为 macOS Catalyst 时定义为 1.
 */

/**
 * @def DS_PLATFORM_TVOS
 * @brief 当前目标平台为 tvOS 时定义为 1.
 */

/**
 * @def DS_PLATFORM_WATCHOS
 * @brief 当前目标平台为 watchOS 时定义为 1.
 */

/**
 * @def DS_PLATFORM_IOS
 * @brief 当前目标平台为 iOS 时定义为 1.
 */

/**
 * @def DS_PLATFORM_MACOS
 * @brief 当前目标平台为 macOS 时定义为 1.
 */

/**
 * @def DS_PLATFORM_ANDROID
 * @brief 当前目标平台为 Android 时定义为 1.
 */

/**
 * @def DS_PLATFORM_EMSCRIPTEN
 * @brief 当前目标平台为 Emscripten 时定义为 1.
 */

/**
 * @def DS_PLATFORM_WASM
 * @brief 当前目标平台为 WebAssembly 运行环境时定义为 1.
 */

/**
 * @def DS_PLATFORM_LINUX
 * @brief 当前目标平台为 Linux 时定义为 1.
 */

/**
 * @def DS_PLATFORM_FREEBSD
 * @brief 当前目标平台为 FreeBSD 时定义为 1.
 */

/**
 * @def DS_PLATFORM_OPENBSD
 * @brief 当前目标平台为 OpenBSD 时定义为 1.
 */

/**
 * @def DS_PLATFORM_NETBSD
 * @brief 当前目标平台为 NetBSD 时定义为 1.
 */

/**
 * @def DS_PLATFORM_DRAGONFLY
 * @brief 当前目标平台为 DragonFly BSD 时定义为 1.
 */

/**
 * @def DS_PLATFORM_HAIKU
 * @brief 当前目标平台为 Haiku 时定义为 1.
 */

/**
 * @def DS_PLATFORM_SOLARIS
 * @brief 当前目标平台为 Solaris 时定义为 1.
 */

/**
 * @def DS_PLATFORM_AIX
 * @brief 当前目标平台为 AIX 时定义为 1.
 */

/**
 * @def DS_PLATFORM_QNX
 * @brief 当前目标平台为 QNX 时定义为 1.
 */

/**
 * @def DS_PLATFORM_UNKNOWN
 * @brief 当前目标平台未命中已知分支时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_PLATFORM_WINDOWS 1
#define DS_PLATFORM_MINGW 1
#define DS_PLATFORM_CYGWIN 1
#define DS_PLATFORM_APPLE 1
#define DS_PLATFORM_MACCATALYST 1
#define DS_PLATFORM_TVOS 1
#define DS_PLATFORM_WATCHOS 1
#define DS_PLATFORM_IOS 1
#define DS_PLATFORM_MACOS 1
#define DS_PLATFORM_ANDROID 1
#define DS_PLATFORM_EMSCRIPTEN 1
#define DS_PLATFORM_WASM 1
#define DS_PLATFORM_LINUX 1
#define DS_PLATFORM_FREEBSD 1
#define DS_PLATFORM_OPENBSD 1
#define DS_PLATFORM_NETBSD 1
#define DS_PLATFORM_DRAGONFLY 1
#define DS_PLATFORM_HAIKU 1
#define DS_PLATFORM_SOLARIS 1
#define DS_PLATFORM_AIX 1
#define DS_PLATFORM_QNX 1
#define DS_PLATFORM_UNKNOWN 1
#elif defined(_WIN32)
#define DS_PLATFORM_WINDOWS 1
#if defined(__MINGW32__) || defined(__MINGW64__)
#define DS_PLATFORM_MINGW 1
#endif
#if defined(__CYGWIN__)
#define DS_PLATFORM_CYGWIN 1
#endif
#elif defined(__APPLE__)
#define DS_PLATFORM_APPLE 1
#include <TargetConditionals.h>
#if TARGET_OS_MACCATALYST
#define DS_PLATFORM_MACCATALYST 1
#endif
#if TARGET_OS_TV
#define DS_PLATFORM_TVOS 1
#endif
#if TARGET_OS_WATCH
#define DS_PLATFORM_WATCHOS 1
#endif
#if TARGET_OS_IPHONE
#define DS_PLATFORM_IOS 1
#endif
#if TARGET_OS_MAC
#define DS_PLATFORM_MACOS 1
#endif
#elif defined(__ANDROID__)
#define DS_PLATFORM_ANDROID 1
#elif defined(__EMSCRIPTEN__)
#define DS_PLATFORM_EMSCRIPTEN 1
#define DS_PLATFORM_WASM 1
#elif defined(__linux__)
#define DS_PLATFORM_LINUX 1
#elif defined(__FreeBSD__)
#define DS_PLATFORM_FREEBSD 1
#elif defined(__OpenBSD__)
#define DS_PLATFORM_OPENBSD 1
#elif defined(__NetBSD__)
#define DS_PLATFORM_NETBSD 1
#elif defined(__DragonFly__)
#define DS_PLATFORM_DRAGONFLY 1
#elif defined(__HAIKU__)
#define DS_PLATFORM_HAIKU 1
#elif defined(__sun) || defined(sun)
#define DS_PLATFORM_SOLARIS 1
#elif defined(_AIX)
#define DS_PLATFORM_AIX 1
#elif defined(__QNXNTO__)
#define DS_PLATFORM_QNX 1
#else
#define DS_PLATFORM_UNKNOWN 1
#endif

/**
 * @def DS_PLATFORM_STR
 * @brief 当前目标操作系统的字符串标识.
 *
 * 字符串宏基于上面的布尔平台宏展开，便于日志和文档展示。
 */

#if defined(DOXYGEN)
#define DS_PLATFORM_STR
#elif defined(DS_PLATFORM_MINGW)
#define DS_PLATFORM_STR "MinGW"
#elif defined(DS_PLATFORM_CYGWIN)
#define DS_PLATFORM_STR "Cygwin"
#elif defined(DS_PLATFORM_WINDOWS)
#define DS_PLATFORM_STR "Windows"
#elif defined(DS_PLATFORM_MACCATALYST)
#define DS_PLATFORM_STR "macOS(Catalyst)"
#elif defined(DS_PLATFORM_TVOS)
#define DS_PLATFORM_STR "tvOS"
#elif defined(DS_PLATFORM_WATCHOS)
#define DS_PLATFORM_STR "watchOS"
#elif defined(DS_PLATFORM_IOS)
#define DS_PLATFORM_STR "iOS"
#elif defined(DS_PLATFORM_MACOS)
#define DS_PLATFORM_STR "macOS"
#elif defined(DS_PLATFORM_ANDROID)
#define DS_PLATFORM_STR "Android"
#elif defined(DS_PLATFORM_EMSCRIPTEN)
#define DS_PLATFORM_STR "Emscripten"
#elif defined(DS_PLATFORM_WASM)
#define DS_PLATFORM_STR "WebAssembly"
#elif defined(DS_PLATFORM_LINUX)
#define DS_PLATFORM_STR "Linux"
#elif defined(DS_PLATFORM_FREEBSD)
#define DS_PLATFORM_STR "FreeBSD"
#elif defined(DS_PLATFORM_OPENBSD)
#define DS_PLATFORM_STR "OpenBSD"
#elif defined(DS_PLATFORM_NETBSD)
#define DS_PLATFORM_STR "NetBSD"
#elif defined(DS_PLATFORM_DRAGONFLY)
#define DS_PLATFORM_STR "DragonFly BSD"
#elif defined(DS_PLATFORM_HAIKU)
#define DS_PLATFORM_STR "Haiku"
#elif defined(DS_PLATFORM_SOLARIS)
#define DS_PLATFORM_STR "Solaris"
#elif defined(DS_PLATFORM_AIX)
#define DS_PLATFORM_STR "AIX"
#elif defined(DS_PLATFORM_QNX)
#define DS_PLATFORM_STR "QNX"
#else
#define DS_PLATFORM_STR "Unknown"
#endif

/** @} */

/** @name 架构信息 */
/** @{ */

/**
 * 下列架构宏采用布尔风格：命中时定义为 1，未命中时不定义。
 */

/**
 * @def DS_ARCH_ARM64
 * @brief 当前目标架构为 ARM64/AArch64 时定义为 1.
 */

/**
 * @def DS_ARCH_ARM
 * @brief 当前目标架构为 ARM 32 位时定义为 1.
 */

/**
 * @def DS_ARCH_X86_64
 * @brief 当前目标架构为 x86_64/AMD64 时定义为 1.
 */

/**
 * @def DS_ARCH_X86
 * @brief 当前目标架构为 x86 32 位时定义为 1.
 */

/**
 * @def DS_ARCH_RISCV64
 * @brief 当前目标架构为 RISC-V 64 位时定义为 1.
 */

/**
 * @def DS_ARCH_RISCV32
 * @brief 当前目标架构为 RISC-V 32 位时定义为 1.
 */

/**
 * @def DS_ARCH_PPC64
 * @brief 当前目标架构为 PowerPC 64 位时定义为 1.
 */

/**
 * @def DS_ARCH_PPC32
 * @brief 当前目标架构为 PowerPC 32 位时定义为 1.
 */

/**
 * @def DS_ARCH_MIPS64
 * @brief 当前目标架构为 MIPS64 时定义为 1.
 */

/**
 * @def DS_ARCH_MIPS32
 * @brief 当前目标架构为 MIPS32 时定义为 1.
 */

/**
 * @def DS_ARCH_S390X
 * @brief 当前目标架构为 s390x 时定义为 1.
 */

/**
 * @def DS_ARCH_WASM32
 * @brief 当前目标架构为 WebAssembly 32 位时定义为 1.
 */

/**
 * @def DS_ARCH_UNKNOWN
 * @brief 当前目标架构未命中已知分支时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_ARCH_ARM64 1
#define DS_ARCH_ARM 1
#define DS_ARCH_X86_64 1
#define DS_ARCH_X86 1
#define DS_ARCH_RISCV64 1
#define DS_ARCH_RISCV32 1
#define DS_ARCH_PPC64 1
#define DS_ARCH_PPC32 1
#define DS_ARCH_MIPS64 1
#define DS_ARCH_MIPS32 1
#define DS_ARCH_S390X 1
#define DS_ARCH_WASM32 1
#define DS_ARCH_UNKNOWN 1
#elif defined(__aarch64__) || defined(_M_ARM64)
#define DS_ARCH_ARM64 1
#elif defined(__arm__) || defined(_M_ARM)
#define DS_ARCH_ARM 1
#elif defined(__x86_64__) || defined(_M_X64)
#define DS_ARCH_X86_64 1
#elif defined(__i386__) || defined(_M_IX86)
#define DS_ARCH_X86 1
#elif defined(__riscv) && __riscv_xlen == 64
#define DS_ARCH_RISCV64 1
#elif defined(__riscv) && __riscv_xlen == 32
#define DS_ARCH_RISCV32 1
#elif defined(__powerpc64__) || defined(_M_PPC64)
#define DS_ARCH_PPC64 1
#elif defined(__powerpc__) || defined(_M_PPC)
#define DS_ARCH_PPC32 1
#elif defined(__mips64)
#define DS_ARCH_MIPS64 1
#elif defined(__mips__)
#define DS_ARCH_MIPS32 1
#elif defined(__s390x__)
#define DS_ARCH_S390X 1
#elif defined(__wasm32__) || defined(__EMSCRIPTEN__)
#define DS_ARCH_WASM32 1
#else
#define DS_ARCH_UNKNOWN 1
#endif

/**
 * @def DS_ARCH_STR
 * @brief 当前目标 CPU 架构的字符串标识.
 *
 * 字符串宏基于上面的架构布尔宏展开，便于日志和文档展示。
 */

#if defined(DOXYGEN)
#define DS_ARCH_STR
#elif defined(DS_ARCH_ARM64)
#define DS_ARCH_STR "arm64"
#elif defined(DS_ARCH_ARM)
#define DS_ARCH_STR "arm"
#elif defined(DS_ARCH_X86_64)
#define DS_ARCH_STR "x86_64"
#elif defined(DS_ARCH_X86)
#define DS_ARCH_STR "x86"
#elif defined(DS_ARCH_RISCV64)
#define DS_ARCH_STR "riscv64"
#elif defined(DS_ARCH_RISCV32)
#define DS_ARCH_STR "riscv32"
#elif defined(DS_ARCH_PPC64)
#define DS_ARCH_STR "ppc64"
#elif defined(DS_ARCH_PPC32)
#define DS_ARCH_STR "ppc32"
#elif defined(DS_ARCH_MIPS64)
#define DS_ARCH_STR "mips64"
#elif defined(DS_ARCH_MIPS32)
#define DS_ARCH_STR "mips32"
#elif defined(DS_ARCH_S390X)
#define DS_ARCH_STR "s390x"
#elif defined(DS_ARCH_WASM32)
#define DS_ARCH_STR "wasm32"
#else
#define DS_ARCH_STR "unknown"
#endif

/** @} */

/** @name 指令集检测 */
/** @{ */

/**
 * 下列指令集宏采用布尔风格：命中时定义为 1，未命中时不定义。
 */

/**
 * @def DS_SIMD_SSE2
 * @brief 当前编译单元支持 SSE2 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_SSE2 1
#elif defined(__SSE2__) || defined(_M_X64)
#define DS_SIMD_SSE2 1
#endif

/**
 * @def DS_SIMD_SSE3
 * @brief 当前编译单元支持 SSE3 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_SSE3 1
#elif defined(__SSE3__) || defined(_M_X64)
#define DS_SIMD_SSE3 1
#endif

/**
 * @def DS_SIMD_SSSE3
 * @brief 当前编译单元支持 SSSE3 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_SSSE3 1
#elif defined(__SSSE3__) || defined(_M_X64)
#define DS_SIMD_SSSE3 1
#endif

/**
 * @def DS_SIMD_SSE4_1
 * @brief 当前编译单元支持 SSE4.1 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_SSE4_1 1
#elif defined(__SSE4_1__) || defined(_M_X64)
#define DS_SIMD_SSE4_1 1
#endif

/**
 * @def DS_SIMD_SSE4_2
 * @brief 当前编译单元支持 SSE4.2 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_SSE4_2 1
#elif defined(__SSE4_2__) || defined(_M_X64)
#define DS_SIMD_SSE4_2 1
#endif

/**
 * @def DS_SIMD_AVX
 * @brief 当前编译单元支持 AVX 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_AVX 1
#elif defined(__AVX__) || defined(_M_X64)
#define DS_SIMD_AVX 1
#endif

/**
 * @def DS_SIMD_AVX2
 * @brief 当前编译单元支持 AVX2 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_AVX2 1
#elif defined(__AVX2__) || defined(_M_X64)
#define DS_SIMD_AVX2 1
#endif

/**
 * @def DS_SIMD_AVX512F
 * @brief 当前编译单元支持 AVX-512F 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_AVX512F 1
#elif defined(__AVX512F__) || defined(_M_X64)
#define DS_SIMD_AVX512F 1
#endif

/**
 * @def DS_SIMD_FMA
 * @brief 当前编译单元支持 FMA 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_FMA 1
#elif defined(__FMA__) || defined(_M_X64)
#define DS_SIMD_FMA 1
#endif

/**
 * @def DS_SIMD_AES
 * @brief 当前编译单元支持 AES 指令集时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_AES 1
#elif defined(__AES__) || defined(_M_X64)
#define DS_SIMD_AES 1
#endif

/**
 * @def DS_SIMD_BMI
 * @brief 当前编译单元支持 BMI1 指令集时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_BMI 1
#elif defined(__BMI__)
#define DS_SIMD_BMI 1
#endif

/**
 * @def DS_SIMD_BMI2
 * @brief 当前编译单元支持 BMI2 指令集时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_BMI2 1
#elif defined(__BMI2__)
#define DS_SIMD_BMI2 1
#endif

/**
 * @def DS_SIMD_POPCNT
 * @brief 当前编译单元支持 POPCNT 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_POPCNT 1
#elif defined(__POPCNT__) || defined(_M_X64)
#define DS_SIMD_POPCNT 1
#endif

/**
 * @def DS_SIMD_ARM_NEON
 * @brief 当前编译单元支持 ARM NEON 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_ARM_NEON 1
#elif defined(__ARM_NEON) || defined(_M_ARM64)
#define DS_SIMD_ARM_NEON 1
#endif

/**
 * @def DS_SIMD_ARM_SVE
 * @brief 当前编译单元支持 ARM SVE 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_ARM_SVE 1
#elif defined(__ARM_FEATURE_SVE)
#define DS_SIMD_ARM_SVE 1
#endif

/**
 * @def DS_SIMD_ARM_SME
 * @brief 当前编译单元支持 ARM SME 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_ARM_SME 1
#elif defined(__ARM_FEATURE_SME)
#define DS_SIMD_ARM_SME 1
#endif

/**
 * @def DS_SIMD_ARM_CRYPTO
 * @brief 当前编译单元支持 ARM Crypto 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_ARM_CRYPTO 1
#elif defined(__ARM_FEATURE_CRYPTO)
#define DS_SIMD_ARM_CRYPTO 1
#endif

/**
 * @def DS_SIMD_ARM_FP16
 * @brief 当前编译单元支持 ARM FP16 向量运算时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_ARM_FP16 1
#elif defined(__ARM_FEATURE_FP16_VECTOR_ARITHMETIC) || defined(__ARM_FP16_FORMAT_IEEE)
#define DS_SIMD_ARM_FP16 1
#endif

/**
 * @def DS_SIMD_ARM_DOTPROD
 * @brief 当前编译单元支持 ARM dot product 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_ARM_DOTPROD 1
#elif defined(__ARM_FEATURE_DOTPROD)
#define DS_SIMD_ARM_DOTPROD 1
#endif

/**
 * @def DS_SIMD_ARM_BF16
 * @brief 当前编译单元支持 ARM BF16 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_ARM_BF16 1
#elif defined(__ARM_FEATURE_BF16)
#define DS_SIMD_ARM_BF16 1
#endif

/**
 * @def DS_SIMD_ARM_I8MM
 * @brief 当前编译单元支持 ARM I8MM 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_ARM_I8MM 1
#elif defined(__ARM_FEATURE_MATMUL_INT8)
#define DS_SIMD_ARM_I8MM 1
#endif

/**
 * @def DS_SIMD_ARM_SVE2
 * @brief 当前编译单元支持 ARM SVE2 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_ARM_SVE2 1
#elif defined(__ARM_FEATURE_SVE2)
#define DS_SIMD_ARM_SVE2 1
#endif

/**
 * @def DS_SIMD_RISCV_VECTOR
 * @brief 当前编译单元支持 RISC-V Vector 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_RISCV_VECTOR 1
#elif defined(__riscv_vector) && (defined(DS_ARCH_RISCV64) || defined(DS_ARCH_RISCV32))
#define DS_SIMD_RISCV_VECTOR 1
#endif

/**
 * @def DS_SIMD_PPC_ALTIVEC
 * @brief 当前编译单元支持 PowerPC AltiVec 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_PPC_ALTIVEC 1
#elif (defined(__ALTIVEC__) || defined(__VEC__)) && (defined(DS_ARCH_PPC64) || defined(DS_ARCH_PPC32))
#define DS_SIMD_PPC_ALTIVEC 1
#endif

/**
 * @def DS_SIMD_PPC_VSX
 * @brief 当前编译单元支持 PowerPC VSX 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_PPC_VSX 1
#elif defined(__VSX__) && (defined(DS_ARCH_PPC64) || defined(DS_ARCH_PPC32))
#define DS_SIMD_PPC_VSX 1
#endif

/**
 * @def DS_SIMD_MIPS_MSA
 * @brief 当前编译单元支持 MIPS MSA 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_MIPS_MSA 1
#elif defined(__mips_msa) && (defined(DS_ARCH_MIPS64) || defined(DS_ARCH_MIPS32))
#define DS_SIMD_MIPS_MSA 1
#endif

/**
 * @def DS_SIMD_S390X_VX
 * @brief 当前编译单元支持 s390x Vector Facility 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_S390X_VX 1
#elif (defined(__VEC__) || defined(__VX__)) && defined(DS_ARCH_S390X)
#define DS_SIMD_S390X_VX 1
#endif

/**
 * @def DS_SIMD_WASM_SIMD128
 * @brief 当前编译单元支持 WebAssembly SIMD128 时定义为 1.
 */

#if defined(DOXYGEN)
#define DS_SIMD_WASM_SIMD128 1
#elif defined(__wasm_simd128__) && defined(DS_ARCH_WASM32)
#define DS_SIMD_WASM_SIMD128 1
#endif

/** @} */
