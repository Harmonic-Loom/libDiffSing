# libDiffSing

[![Build Artifacts](https://github.com/Harmonic-Loom/libDiffSing/actions/workflows/build.yml/badge.svg?branch=main&event=push)](https://github.com/Harmonic-Loom/libDiffSing/actions/workflows/build.yml?query=branch%3Amain+event%3Apush)
[![Docs](https://img.shields.io/website?url=https%3A%2F%2Fharmonic-loom.github.io%2FlibDiffSing%2F&label=docs)](https://harmonic-loom.github.io/libDiffSing/)
[![GitHub Release](https://img.shields.io/github/v/release/Harmonic-Loom/libDiffSing)](https://github.com/Harmonic-Loom/libDiffSing/releases)
[![License](https://img.shields.io/github/license/Harmonic-Loom/libDiffSing)](./LICENSE)
[![CMake >= 3.25](https://img.shields.io/badge/CMake-%3E%3D3.25-blue)](https://cmake.org/)
[![C++20](https://img.shields.io/badge/C%2B%2B-20-blue.svg)](https://isocpp.org/)

DiffSinger C Runtime (C/C++20, CMake + Ninja, multi-platform preset builds).

Upstream project (DiffSinger): <https://github.com/openvpi/DiffSinger>

## 1. Clone and Download

This repository uses `vcpkg` as a submodule. Please clone with submodules:

```bash
git clone --recursive https://github.com/Harmonic-Loom/libDiffSing.git
cd libDiffSing
```

If you already cloned the repository without submodules:

```bash
git submodule update --init --recursive
```

## 1.1 Releases and Versions

- Releases: <https://github.com/Harmonic-Loom/libDiffSing/releases>
- Latest release: <https://github.com/Harmonic-Loom/libDiffSing/releases/latest>
- Documentation site: <https://harmonic-loom.github.io/libDiffSing/>

---

## 2. Build Environment Dependencies by Platform

General requirements:

- [Git](https://git-scm.com/downloads)
- [CMake](https://cmake.org/download/) >= 3.25 (this project uses CMake Presets)
- [Ninja](https://ninja-build.org/)
- C/C++ compiler

| Target Platform | Build Host | Main Dependencies |
| --- | --- | --- |
| Android (arm64-v8a / x86_64) | Windows / Linux / macOS | [Android SDK](https://developer.android.com/studio), [Android NDK](https://developer.android.com/ndk/downloads), `ANDROID_SDK_ROOT`, `ANDROID_NDK_HOME` |
| iOS (arm64) | macOS | [Xcode (with Command Line Tools)](https://developer.apple.com/xcode/), iOS SDK |
| iOS Simulator (arm64) | macOS | [Xcode (with Command Line Tools)](https://developer.apple.com/xcode/), iOS Simulator SDK |
| Windows (x64 / arm64) | Windows | [Visual Studio (MSVC with C++ workload)](https://visualstudio.microsoft.com/downloads/), Ninja |
| Linux (x64 / arm64) | Linux | [LLVM/Clang](https://releases.llvm.org/download.html) (clang / clang++), ninja-build |
| macOS (arm64 / x86_64) | macOS | [Xcode (with Command Line Tools)](https://developer.apple.com/xcode/), Ninja (or Xcode Generator) |
| WebAssembly (wasm32) | Windows / Linux / macOS | [Emscripten](https://emscripten.org/docs/getting_started/downloads.html) toolchain (`emcc` / `em++`) |

---

## 3. Target Platform (by ISA) / Preset / Output Directory

`CMakePresets.json` defines the full multi-platform presets. `buildPreset` and `configurePreset` share the same names and can be used directly.

| Target Platform | ISA | Preset | Output Directory |
| --- | --- | --- | --- |
| Android | arm64-v8a | `android-arm64-debug`<br>`android-arm64-release` | `build/android-arm64-debug/bin`<br>`build/android-arm64-release/bin` |
| Android | x86_64 | `android-x64-debug`<br>`android-x64-release` | `build/android-x64-debug/bin`<br>`build/android-x64-release/bin` |
| iOS | arm64 | `ios-arm64-debug`<br>`ios-arm64-release` | `build/ios-arm64-debug/bin`<br>`build/ios-arm64-release/bin` |
| iOS Simulator | arm64 | `iossimu-arm64-debug`<br>`iossimu-arm64-release` | `build/iossimu-arm64-debug/bin`<br>`build/iossimu-arm64-release/bin` |
| Windows | x64 | `windows-x64-debug`<br>`windows-x64-release` | `build/windows-x64-debug/bin`<br>`build/windows-x64-release/bin` |
| Windows | arm64 | `windows-arm64-debug`<br>`windows-arm64-release` | `build/windows-arm64-debug/bin`<br>`build/windows-arm64-release/bin` |
| Linux | x64 | `linux-x64-debug`<br>`linux-x64-release` | `build/linux-x64-debug/bin`<br>`build/linux-x64-release/bin` |
| Linux | arm64 | `linux-arm64-debug`<br>`linux-arm64-release` | `build/linux-arm64-debug/bin`<br>`build/linux-arm64-release/bin` |
| macOS | arm64 | `osx-arm64-debug`<br>`osx-arm64-release`<br>`osx-arm64-xcode-debug`<br>`osx-arm64-xcode-release` | `build/osx-arm64-debug/bin`<br>`build/osx-arm64-release/bin`<br>`build/osx-arm64-xcode-debug/bin`<br>`build/osx-arm64-xcode-release/bin` |
| macOS | x86_64 | `osx-x64-debug`<br>`osx-x64-release` | `build/osx-x64-debug/bin`<br>`build/osx-x64-release/bin` |
| WebAssembly | wasm32 | `emscripten-debug`<br>`emscripten-release` | `build/emscripten-debug/bin`<br>`build/emscripten-release/bin` |

---

## 4. Build Commands

Use any `<preset>` (for example `windows-x64-debug`):

### 4.1 Configure

```bash
cmake --preset <preset>
```

### 4.2 Build

```bash
cmake --build --preset <preset>
```

### 4.3 Run Tests (non-iOS)

Run tests via the preset test target:

```bash
cmake --build --preset <preset> --target test
```

> iOS does not build command-line test executables.

---

## 5. Documentation Generation

The `docs` target generates two Doxygen outputs:

- API docs
- Internal docs

### 5.1 Configure first

```bash
cmake --preset <preset>
```

### 5.2 Build docs target

```bash
cmake --build --preset <preset> --target docs
```

### 5.3 Docs output

Docs are generated under the current `<preset>` build directory:

- `docs/` (API)
- `docs/internal/` (Internal)

### 5.4 Documentation Build Platform Support (Doxygen / Graphviz / doxygen-awesome-css)

| Docs Build Host | Doxygen | Graphviz (dot) | doxygen-awesome-css |
| --- | --- | --- | --- |
| Windows | Prefer system install; auto-download if missing | Prefer system install; auto-download if missing | Auto-fetched via FetchContent (requires Git + network) |
| Linux | Prefer system install; auto-download if missing | Prefer system install; auto-download if missing | Auto-fetched via FetchContent (requires Git + network) |
| macOS | Manual install required (no auto-download) | Manual install required (no auto-download) | Auto-fetched via FetchContent (requires Git + network) |

Manual install on macOS (Homebrew):

```bash
brew install doxygen graphviz
```

### 5.5 Documentation Dependency Breakdown

| Dependency | Required | Purpose |
| --- | --- | --- |
| [Doxygen](https://www.doxygen.nl/download.html) | Required | Generate API and Internal docs |
| [Graphviz (dot)](https://graphviz.org/download/) | Optional (recommended) | Generate class/include relationship graphs |
| [Git](https://git-scm.com/downloads) + network access | Required | Fetch [`doxygen-awesome-css`](https://github.com/jothepro/doxygen-awesome-css) via FetchContent |

---

## 6. Related Links

- Repository: <https://github.com/Harmonic-Loom/libDiffSing>
- Latest release: <https://github.com/Harmonic-Loom/libDiffSing/releases/latest>
- DiffSinger (upstream): <https://github.com/openvpi/DiffSinger>
- CMake: <https://cmake.org/download/>
- Ninja: <https://ninja-build.org/>
- Visual Studio (MSVC): <https://visualstudio.microsoft.com/downloads/>
- Android SDK: <https://developer.android.com/studio>
- Android NDK: <https://developer.android.com/ndk/downloads>
- Xcode: <https://developer.apple.com/xcode/>
- Emscripten: <https://emscripten.org/docs/getting_started/downloads.html>
- ONNX Runtime: <https://onnxruntime.ai/>
- Doxygen: <https://www.doxygen.nl/download.html>
- Graphviz: <https://graphviz.org/download/>
- doxygen-awesome-css: <https://github.com/jothepro/doxygen-awesome-css>
