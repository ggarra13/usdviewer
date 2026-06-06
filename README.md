[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux.yml)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux_arm64.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_linux_arm64.yml)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_win64.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_win64.yml)
[![Build Status](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_macos14.yml/badge.svg)](https://github.com/ggarra13/usdviewer/actions/workflows/vulkan_macos14.yml)

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=UJMHRRKYCPXYW)

usdviewer
=========

usdviewer is an open source review tool for OpenUSD scenes that does not depend on Hydra or OpenGL.  It currently works with Vulkan and does not yet support raytracing.

Contents:

- [Pre-built Binaries](#pre-built-binaries)
    - [Compatibility](#compatibility) 
    - [Notes on Installation](#notes-on-installation)
- [Features](#features)
- [Running usdviewer](#running-usdviewer)
    - [macOS and Linux](#macos-and-linux)
    - [Windows](#windows)
- [Tutorials](#tutorials)
- [Documenting](#documenting)

![banner](https://github.com/ggarra13/usdviewer/blob/main/assets/images/hummingbird.gif)

# Pre-built binaries

If you are looking for pre-built binaries for Windows, Linux or macOS, they can be found in:

[GitHub](https://github.com/ggarra13/usdviewer/releases)

The Linux releases are built on Rocky Linux 8.10 using SCL.
The Linux beta builds are built on Ubuntu 24.04.

## Compatibility

usdviewer **OFFICIAL RELEASE** binaries run on Windows 10+, RedHat 8+ or Ubuntu 24.04+, and macOS 11.0+ Silicon.

## Notes on installation

- On macOS you install it by opening the .dmg file, and dragging the usdviewer
  icon to the Applications directory.  If there's already an usdviewer version,
  we recommend you overwrite it.
  The macOS application is currently not notarized, so when you launch it you
  will not be able to run it as macOS will warn you that the file is not secure
  as it was downloaded from internet.
  To avoid that, you need to open the Apple Logo->Settings->Privacy and Security
  and go to Security and allow "Opening Anyway".
  Alternatively, you can do it from the Terminal, by:
  
```
  sudo xattr -rd com.apple.quarantine /Applications/usdviewer.app/
```

- Windows and Chrome, like macOS, also protect you from installing files from the Internet.  When you first download it with Chrome it may warn you that it is not an usual archive to be downloaded.  Make sure to click on the right up arrow menu to Save it anyway.
  You cannot open the .exe from Chrome directly.  You will need to open Windows Explorer and go to the Downloads directory.  You should then run it from there.
  Then Windows will popup a Blue box telling you Windows SmartScreen prevented the start of an unknown application and that you can place your PC at risk.
  Click on the More Information text and a Button that says Run anyway or similar should appear.  Click on it and follow the standard instructions to any Windows installer.
  One note about the Windows install.  When asked if you want to add usdviewer to your PATH, it is recommended to answer No to it, as it avoids DLLs conflicts with other applications that use common libraries like FFmpeg or OpenUSD.


- On Linux, in order to install the .rpm or .deb packages requires your user to
  have sudo permissions.

  On Debian (Ubuntu, etc) systems, you would install with:

```
  sudo dpkg -i usdviewer-v1.0.0-Linux-amd64.deb
```

  On Red Hat (Rocky Linux, etc), you would install it with:
  
```
  sudo rpm -i usdviewer-v1.0.0-Linux-amd64.rpm
```

  Once you install it, you can run usdviewer by just typing usdviewer or vusdviewer in the  shell, as a symlink to the executable is placed in /usr/bin.  The installers will also associate file extensions and install an icon for easy starting  up in the Desktop icon of the user that installed it.  For running usdviewer  with the icon, you need to select it and use the right mouse button to open the menu and choose Allow Launch.
  
  If you lack sudo permissions in your organization, you should download the .tar.gz file and you can uncompress it with:
  
```
  tar -xf usdviewer-v1.0.0-Linux-amd64.tar.gz
```

  That will create a folder in the directory you uncompress it from.  You can then run usdviewer by using the usdviewer.sh shell script in the bin/ subdirectory.

# Features

The source code is written in C++20 and uses CMake for the build system, with some bash scripts for auxiliary tasks.  

Currently supported:

- Primitives:
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
- Improved performance.
- Saving of images.
