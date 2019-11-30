# bonfire-core ![](https://img.shields.io/github/license/solarrabbit/bonfire) ![](https://img.shields.io/github/issues/solarrabbit/bonfire)

A simple but flexible framework to create 2D top-down adventure games, JRPG games, and more.

> ⚠️ **DISCLAIMER** : bonfire is currently in its earliest stages of development. Please note that anything in this README may or may not have been actually implemented. For now, this README should be viewed more as a roadmap for what's to come.

### Why bonfire?
1. ***Write once, deploy everywhere***
    bonfire is powered by [Kha](https://github.com/Kode/Kha), an "[u]ltra-portable, high performance, open source multimedia framework", as well as written in the [Haxe programming language](https://haxe.org/), allowing access to countless backends as well as native performance in each one. bonfire builds natively to Windows (Direct3D, Vulkan, OpenGL), macOS (Metal, OpenGL), Linux (Vulkan, OpenGL), Android (C++, Java), iOS (Metal, OpenGL), HTML5 (WebGL with canvas fallback), and more. For a comprehensive list of the build targets available, see [Kha's list of supported platforms](https://github.com/Kode/Kha/wiki/Features#supported-platforms).
2. ***Simple but flexible scripting system***
    bonfire implements a simple scripting language of its own, *FlameScript*, to write scripted sequences and implement new, project-specific features. bonfire exposes many lower-level features such as drawing and asset loading as well as higher-level functions like displaying text in a message box to *FlameScript*; this results in a tightly-integrated, user-friendly experience.
3. ***Hackable***
    bonfire is open source and is easy to build/test out of the box. This makes it trivial for you to make changes to the core codebase or push changes to it.

### Contribution
If you find a bug or have a feature request, please feel free to open an issue/PR!