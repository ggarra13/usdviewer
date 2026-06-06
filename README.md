[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux.yml)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux_arm64.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux_arm64.yml)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_win64.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_win64.yml)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_macos14.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_macos14.yml)

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=UJMHRRKYCPXYW)

usdviewer
=========

usdviewer is an open source review tool for OpenUSD scenes that does not depend on Hydra or OpenGL.  It currently works with Vulkan and does not yet support raytracing as macOS' Vulkan does not support the extension (next year will port to KosmicKrisp which does support it).

Contents:

- [Pre-built Binaries](#pre-built-binaries)
    - [Compatibility](#compatibility) 
    - [Notes on Installation](#notes-on-installation)
- [Features](#features)
- [Running usdviewer](#running-usdviewer)
    - [macOS and Linux](#macos-and-linux)
    - [Windows](#windows)

![banner](https://github.com/ggarra13/usdviewer/blob/main/assets/images/hummingbird.gif)
![banner](https://github.com/ggarra13/usdviewer/blob/main/assets/images/ALab.png)

# Features

The source code is written in C++20 and uses CMake for the build system, with some bash scripts for auxiliary tasks.  

Currently supported:

- Primitives:
  * HDR support
  * Sphere
  * Subdivisions' unsubdivided mesh
  * Variant meshes
  * Meshes
  * Animation
  * Skeleton and Shape deformations
  * Pixar's USDPreview shader
  * Textures with one single Primvar (like 'st')
- Linux, Windows and macOS Silicon.

Not yet supported:

- Raytracing or OIT transparency
- Skeletons with a compute shader. 
- Improved performance (mrv2 is still faster and more rich in features).
- Saving of images.
- No MaterialX support.
