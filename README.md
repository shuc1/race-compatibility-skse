# Race Compatibility SKSE

Plugin for race compatibility in dialogue, vampirism and so on.
### Requirements
* [XMake](https://xmake.io) [2.8.6+]
* C++23 Compiler (MSVC)
* Papyrus Compiler

## Getting Started
```bat
git clone --recurse-submodules https://github.com/shuc1/race-compatibility-skse.git
cd race-compatibility-skse
```

Ensure that you set path `SKYRIM_HOME=YOUR_SKYRIM_GAME_FOLDER` and arrange the `%SKYRIM_HOME%` folder as follows (SKSE must has been installed):
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
xmake
```

> ***Note:*** *This will generate a `build/` directory in the **project's root directory** with the build output.*
### Build Fomod (Optional)
To build core fomod and patch fomod, run the following command after build:
```bat
xmake pack
```

> ***Note:*** *Two zip files for the main fomod and patch hub fomod will be generated in the `build/xpack` directory.*
### Project Generation (Optional)
If you want to generate a Visual Studio project, run the following command:
```bat
xmake project -k vsxmake
```

> ***Note:*** *This will generate a `vsxmakeXXXX/` directory in the **project's root directory** using the latest version of Visual Studio installed on the system.*
### Upgrading Packages (Optional)
If you want to upgrade the project's dependencies, run the following commands:
```bat
xmake repo --update
xmake require --upgrade
```

## Documentation
Please refer to the [Wiki](../../wiki/Home) for more advanced topics.

## Credits
- [Ryan McKenzie](https://github.com/Ryan-rsm-McKenzie) and [powerof3](https://github.com/powerof3) for their work on `commonlibsse`.
- [qudix](https://github.com/qudix) for [commonlibsse-template](https://github.com/qudix/commonlibsse-template)
- [fenix31415](https://github.com/fenix31415) for `SKSE` modding [tutorial](https://www.youtube.com/watch?v=PunbccQr9xk)
- [meh321](https://github.com/meh321) and the entire community on `xSE RE` server