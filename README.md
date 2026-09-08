# libDiffSing

[![Build Artifacts](https://github.com/Harmonic-Loom/libDiffSing/actions/workflows/build.yml/badge.svg?branch=main&event=push)](https://github.com/Harmonic-Loom/libDiffSing/actions/workflows/build.yml?query=branch%3Amain+event%3Apush)
[![Docs](https://img.shields.io/website?url=https%3A%2F%2Fharmonic-loom.github.io%2FlibDiffSing%2F&label=docs)](https://harmonic-loom.github.io/libDiffSing/)
[![GitHub Release](https://img.shields.io/github/v/release/Harmonic-Loom/libDiffSing)](https://github.com/Harmonic-Loom/libDiffSing/releases)
[![License](https://img.shields.io/github/license/Harmonic-Loom/libDiffSing)](./LICENSE)
[![CMake >= 3.25](https://img.shields.io/badge/CMake-%3E%3D3.25-blue)](https://cmake.org/)
[![C++20](https://img.shields.io/badge/C%2B%2B-20-blue.svg)](https://isocpp.org/)

DiffSinger C Runtime（C/C++20，CMake + Ninja，多平台预设构建）。

上游项目（DiffSinger）：<https://github.com/openvpi/DiffSinger>

English version: [README.en.md](README.en.md)

## 1. 克隆与下载

本仓库使用 `vcpkg` 作为子模块，请使用带子模块参数的克隆方式：

```bash
git clone --recursive https://github.com/Harmonic-Loom/libDiffSing.git
cd libDiffSing
```

如果已经克隆过但未拉取子模块：

```bash
git submodule update --init --recursive
```

## 1.1 发行版与版本

- 发布页：<https://github.com/Harmonic-Loom/libDiffSing/releases>
- 最新发行版：<https://github.com/Harmonic-Loom/libDiffSing/releases/latest>
- 文档页面：<https://harmonic-loom.github.io/libDiffSing/>

---

## 2. 各平台构建环境依赖

通用要求：

- [Git](https://git-scm.com/downloads)
- [CMake](https://cmake.org/download/) >= 3.25（项目当前使用 CMake Presets）
- [Ninja](https://ninja-build.org/)
- C/C++ 编译器

| 目标平台 | 构建主机 | 主要依赖 |
| --- | --- | --- |
| Android（arm64-v8a / x86_64） | Windows / Linux / macOS | [Android SDK](https://developer.android.com/studio)、[Android NDK](https://developer.android.com/ndk/downloads)、`ANDROID_SDK_ROOT`、`ANDROID_NDK_HOME` |
| iOS（arm64） | macOS | [Xcode（含 Command Line Tools）](https://developer.apple.com/xcode/)、iOS SDK |
| iOS Simulator（arm64） | macOS | [Xcode（含 Command Line Tools）](https://developer.apple.com/xcode/)、iOS Simulator SDK |
| Windows（x64 / arm64） | Windows | [Visual Studio（MSVC，含 C++ 工具集）](https://visualstudio.microsoft.com/downloads/)、Ninja |
| Linux（x64 / arm64） | Linux | [LLVM/Clang](https://releases.llvm.org/download.html)（clang / clang++）、ninja-build |
| macOS（arm64 / x86_64） | macOS | [Xcode（含 Command Line Tools）](https://developer.apple.com/xcode/)、Ninja（或 Xcode Generator） |
| WebAssembly（wasm32） | Windows / Linux / macOS | [Emscripten](https://emscripten.org/docs/getting_started/downloads.html) 工具链（`emcc` / `em++`） |

---

## 3. 目标平台（按指令集）/ Preset / 输出目录对照

项目在 `CMakePresets.json` 中维护了多平台预设。`buildPreset` 与 `configurePreset` 同名，可直接对应使用。

| 目标平台 | 指令集 | Preset | 输出目录 |
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

## 4. 构建项目命令

以任意 `<preset>` 为例（例如 `windows-x64-debug`）：

### 4.1 配置

```bash
cmake --preset <preset>
```

### 4.2 编译

```bash
cmake --build --preset <preset>
```

### 4.3 运行测试（非 iOS）

使用 preset 对应的测试目标执行：

```bash
cmake --build --preset <preset> --target test
```

> iOS 平台不构建命令行测试程序。

---

## 5. 项目文档生成

项目通过 `docs` 目标生成两套 Doxygen 文档：

- API 文档
- Internal 文档

### 5.1 先完成配置

```bash
cmake --preset <preset>
```

### 5.2 构建文档目标

```bash
cmake --build --preset <preset> --target docs
```

### 5.3 文档输出目录

文档输出位于当前 `<preset>` 对应的构建目录下：

- `docs/`（API）
- `docs/internal/`（Internal）

### 5.4 文档构建平台支持（Doxygen / Graphviz / doxygen-awesome-css）

| 文档构建执行平台 | Doxygen | Graphviz（dot） | doxygen-awesome-css |
| --- | --- | --- | --- |
| Windows | 优先使用系统安装；未安装时自动下载 | 优先使用系统安装；未安装时自动下载 | 通过 FetchContent 自动拉取（需 Git + 网络访问） |
| Linux | 优先使用系统安装；未安装时自动下载 | 优先使用系统安装；未安装时自动下载 | 通过 FetchContent 自动拉取（需 Git + 网络访问） |
| macOS | 需手动安装（不支持自动下载） | 需手动安装（不支持自动下载） | 通过 FetchContent 自动拉取（需 Git + 网络访问） |

macOS 手动安装命令（Homebrew）：

```bash
brew install doxygen graphviz
```

### 5.5 文档构建依赖拆分

| 依赖项 | 必需性 | 用途 |
| --- | --- | --- |
| [Doxygen](https://www.doxygen.nl/download.html) | 必需 | 生成 API 与 Internal 文档 |
| [Graphviz（dot）](https://graphviz.org/download/) | 可选（推荐） | 生成类图、包含关系图等图表 |
| [Git](https://git-scm.com/downloads) + 网络访问 | 必需 | 通过 FetchContent 获取 [`doxygen-awesome-css`](https://github.com/jothepro/doxygen-awesome-css) 主题资源 |

---

## 6. 相关链接

- 项目仓库：<https://github.com/Harmonic-Loom/libDiffSing>
- 最新发行版：<https://github.com/Harmonic-Loom/libDiffSing/releases/latest>
- DiffSinger（上游项目）：<https://github.com/openvpi/DiffSinger>
- CMake 下载：<https://cmake.org/download/>
- Ninja：<https://ninja-build.org/>
- Visual Studio（MSVC）：<https://visualstudio.microsoft.com/downloads/>
- Android SDK：<https://developer.android.com/studio>
- Android NDK：<https://developer.android.com/ndk/downloads>
- Xcode：<https://developer.apple.com/xcode/>
- Emscripten：<https://emscripten.org/docs/getting_started/downloads.html>
- ONNX Runtime：<https://onnxruntime.ai/>
- Doxygen：<https://www.doxygen.nl/download.html>
- Graphviz：<https://graphviz.org/download/>
- doxygen-awesome-css：<https://github.com/jothepro/doxygen-awesome-css>
