# Race Compatibility SKSE

Plugin for race compatibility in dialogue, vampirism, armor and more.

## Requirements
* [XMake](https://xmake.io) [2.9.9+]
* [Visual Studio Community 2022](https://visualstudio.microsoft.com/) [Desktop development with C++]

## Getting Started
Clone the repository and its submodules:
```bat
git clone --recurse-submodules https://github.com/shuc1/race-compatibility-skse.git
cd race-compatibility-skse
```

Set the `SKYRIM_HOME` environment variable to your Skyrim game folder and ensure the folder structure matches the following (SKSE must be installed):
```
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
To build the project, run the following command:
```bat
xmake f -m release
xmake
```

> ***Note:*** *This will generate a `build/` directory in the **project's root directory** with the build output.*
### Build Fomod (Optional)
To build the Fomod files, run:
```bat
xmake pack
```

> ***Note:*** *Two zip files for the main fomod will be generated in the `build/xpack` directory.*
### Project Generation (Optional)
To generate a Visual Studio project, run:
```bat
xmake project -k vsxmake
```

> ***Note:*** *This will generate a `vsxmakeXXXX/` directory in the **project's root directory** using the latest version of Visual Studio installed on the system.*
### Upgrading Packages (Optional)
To upgrade the project's dependencies, run:
```bat
xmake repo --update
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