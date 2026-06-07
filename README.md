[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux.yml)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux_arm64.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux_arm64.yml)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_win64.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_win64.yml)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_macos14.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_macos14.yml)

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=UJMHRRKYCPXYW)

usdviewer
=========

usdviewer is an open source review tool for OpenUSD scenes that does not depend on Hydra or OpenGL.  It currently works with Vulkan and does not yet support raytracing as macOS' MoltenVK does not support the extension (next year will port to KosmicKrisp which does support it).

![Screenshot](https://github.com/ggarra13/usdviewer/blob/main/assets/images/hummingbird.gif)
![Screenshot](https://github.com/ggarra13/usdviewer/blob/main/assets/images/ALab_lowres.png)

Contents:

- [Pre-built Binaries](#pre-built-binaries)
- [Information](#information)
- [Currently Supported](#currently-supported)
	- [Features](#features)
	- [Primitives](#primitives)
- [Not yet supported](#not-yet-supported)
- [Running usdviewer](#running-usdviewer)
    - [macOS and Linux](#macos-and-linux)
    - [Windows](#windows)

# Pre-built Binaries

Not yet available.

# Information

The source code is written in C++20 and uses CMake for the build system, with some bash scripts for auxiliary tasks.  

# Currently supported:

## Features: 
  
  * HDR support
  * Animation
  * Skeleton and Shape deformations
  * Pixar's USDPreview shader
  * All texture types (roughness, diffuse, opacity, ambient occlusion, etc)
  * Normal mapping
  * Textures with one single Primvar (like 'st')
  * Saving of OpenEXRs
  * Linux, Windows and macOS.
  
## Primitives:
  * Sphere
  * Subdivisions' unsubdivided mesh
  * Variant meshes
  * Meshes
  
# Not yet supported:

- Raytracing or OIT transparency
- Displacement mapping with a geometry shader.
- Skeletons with a compute shader. 
- Improved performance (mrv2's OpenUSD is still faster and more rich in features).
- Saving of images.
- Changing cameras or orbiting around the scene.
- No MaterialX support.

# Running usdviewer:

## macOS and Linux:

```
BUILD-<Platform>-<ARCH>/Release/install/bin/usdviewer.sh <asset.usd>
```

## Windows

``` 
BUILD-Windows-<ARCH>/Release/install/bin/usdviewer <asset.usd>
```
