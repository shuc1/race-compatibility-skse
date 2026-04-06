# Race Compatibility SKSE
[![Build](https://img.shields.io/github/actions/workflow/status/shuc1/race-compatibility-skse/main.yml)](https://github.com/shuc1/race-compatibility-skse/actions/workflows/main.yml)
[![Release](https://img.shields.io/github/v/release/shuc1/race-compatibility-skse)](https://github.com/shuc1/race-compatibility-skse/releases/latest)


Plugin for race compatibility in dialogue, vampirism, armor and more.

## Requirements
* [XMake](https://xmake.io) [3.0.6+]
* [Visual Studio Community 2026](https://visualstudio.microsoft.com/) [Desktop development with C++]

## Getting Started
Clone the repository and its submodules:
```bash
git clone --recurse-submodules https://github.com/shuc1/race-compatibility-skse.git
cd race-compatibility-skse
```

To compile Papyrus scripts, set the `SKYRIM_HOME` environment variable to your Skyrim game folder and ensure the folder structure matches the following (SKSE must be installed):
```text
└─SKYRIM_HOME
    ├─Papyrus Compiler
    │   ├─PapyrusCompiler.exe
    │   └─...
    └─Data
        └─Scripts
            └─Source
                ├─TESV_Papyrus_Flags.flg
                ├─abForswornBriarheartScript.psc
                └─...
```

### Build
For the project `release` build, run the following command:
```bash
xmake f -m release
xmake # build .dll plugins(default targets)
```

For `releasedebug` build, run:
```bash
xmake f -m releasedbg
xmake
```

To compile Papyrus scripts, run:
```bash
xmake -b papyrus
```

> ***Note:*** *This will generate a `build/` directory in the **project's root directory** with the build output.*
### Build Fomod (Optional)
To build the Fomod files, run:
```bash
xmake pack
```

> ***Note:*** *Zip files for the main fomod will be generated in the `build/xpack` directory.*
### Project Generation (Optional)
To generate a Visual Studio project, run:
```bash
xmake project -k vsxmake
```

> ***Note:*** *This will generate a `vsxmakeXXXX/` directory in the **project's root directory** using the latest version of Visual Studio installed on the system.*
### Upgrading Packages (Optional)
To upgrade the project's dependencies, run:
```bash
xmake require --upgrade
```

## Documentation
Please refer to the [Wiki](../../wiki/Home) for more details.

## Credits
- [Ryan McKenzie](https://github.com/Ryan-rsm-McKenzie) and [powerof3](https://github.com/powerof3) for their work on `CommonLibSSE`.
- [alandtse](https://github.com/alandtse) for `CommonLibVR`.
- [qudix](https://github.com/qudix) for [commonlibsse-template](https://github.com/qudix/commonlibsse-template)
- [fenix31415](https://github.com/fenix31415) for `SKSE` modding [tutorial](https://www.youtube.com/watch?v=PunbccQr9xk)
- [meh321](https://github.com/meh321) and the entire community on `xSE RE` server