# Skyrim Packages

- [Skyrim Packages](#skyrim-packages)
- [xmake](#xmake)
    - [Configure repository](#configure-repository)
  - [Available Skyrim Packages](#available-skyrim-packages)
  - [CommonLib](#commonlib)
    - [Basic Usage](#basic-usage)
      - [`skyrim-commonlib-ae` (_or any other package_)](#skyrim-commonlib-ae-or-any-other-package)
    - [SKSE Plugin metadata](#skse-plugin-metadata)
    - [Xbyak Support](#xbyak-support)
    - [Mod Folder Deployment](#mod-folder-deployment)
      - [`mods_folder`](#mods_folder)
      - [`mod_files`](#mod_files)


> Note: I plan to add vcpkg support in the future, but for now, only xmake is supported for most packages.

# xmake

### Configure repository

To use these xmake packages, add the following to your `xmake.lua` file:

```lua
add_repositories("SkyrimScripting https://github.com/SkyrimScripting/Packages.git")
```

## Available Skyrim Packages

- `skyrim-commonlib-ae`
- `skyrim-commonlib-se`
- `skyrim-commonlib-vr`
- `skyrim-commonlib-ng`

## CommonLib

`xmake` packages available:

- `skyrim-commonlib-ae` ( _Adds dependency on @powerof3's [CommonLibSSE](https://github.com/powerof3/CommonLibSSE)_ configured for Skyrim 1.6+ compatibility )
- `skyrim-commonlib-se` ( _Adds dependency on @powerof3's [CommonLibSSE](https://github.com/powerof3/CommonLibSSE)_ configured for Skyrim 1.5.97 compatibility )
- `skyrim-commonlib-vr` ( _Adds dependency on @alandtse's [CommonLibVR](https://github.com/alandtse/CommonLibVR)_ )
- `skyrim-commonlib-ng` ( _Adds dependency on @CharmedBaryon's [CommonLibSSE-NG](https://github.com/CharmedBaryon/CommonLibSSE-NG)_ )

### Basic Usage

#### `skyrim-commonlib-ae` (_or any other package_)

Or any of the other packages listed above:

```lua
-- For example, to use the VR version of CommonLib:
add_requires("skyrim-commonlib-ae")

target("My-SKSE-Plugin")
    add_files("plugin.cpp")
    -- This will add the CommonLibSSE dependency
    add_packages("skyrim-commonlib-ae")
    -- And don't forget to add the rules for the plugin
    add_rules("@skyrim-commonlib-ae/plugin")
```

### SKSE Plugin metadata

```lua
target("My-SKSE-Plugin")
    add_files("plugin.cpp")
    add_packages("skyrim-commonlib-ae")
    add_rules("@skyrim-commonlib-ae/plugin", {
        name = "My-SKSE-Plugin", -- This defaults to the target name
        version = "420.1.69", -- This defaults to the target version or "0.0.0"
        author = "Mrowr Purr",
        email = "mrowr.purr@gmail.com",
        mods_folder = os.getenv("MO2_or_VORTEX_mods_folder_path"),
        mod_files = {"Scripts", "", "AnythingToDeployToTheModFolder"}
    })
```

### Xbyak Support

To enable [xbyak](https://github.com/herumi/xbyak) support, enable the `xybak` option (available for any version):

```lua
add_requires("skyrim-commonlib-ae", { configs = { xbyak = true } })
```

This will provide the following function (_which is otherwise unavailable_):

```cpp
SKSE::Trampoline::allocate(Xbyak::CodeGenerator& codeGenerator)
```

### Mod Folder Deployment

#### `mods_folder`

Optionally, you can define one or more "mods" folders to deploy the plugin dll/pdb to:

```lua
add_requires("skyrim-commonlib-ae")

target("My-SKSE-Plugin")
    add_files("plugin.cpp")
    add_packages("skyrim-commonlib-ae")

    add_rules("@skyrim-commonlib-ae/plugin", {
        -- This will output to the following generated folder location:
        --  C:/Path/to/my/mods/My-SKSE-Plugin/SKSE/Plugins/My-SKSE-Plugin.dll
        mods_folder = "C:/Path/to/my/mods"
    })

    -- Note: use the rule with a name matching the package that you are using:
    -- add_rules("@skyrim-commonlib-vr/plugin", {...
    -- add_rules("@skyrim-commonlib-ae/plugin", {...
    -- add_rules("@skyrim-commonlib-se/plugin", {...
    -- add_rules("@skyrim-commonlib-vr/plugin", {...
```

If you have multiple mods folders, you can specify them as a list:

```lua
add_requires("skyrim-commonlib-ae")

target("My-SKSE-Plugin")
    add_files("plugin.cpp")
    add_packages("skyrim-commonlib-ae")
    add_rules("@skyrim-commonlib-ae/plugin", {
        mod_folders = { "C:/...", "C:/..." }
    })
```

Paths containing a `;` are split, allowing for use of an environment varialbe to specify multiple output paths:

```lua
add_requires("skyrim-commonlib-ae")

target("My-SKSE-Plugin")
    add_files("plugin.cpp")
    add_packages("skyrim-commonlib-ae")
    add_rules("@skyrim-commonlib-ae/plugin", {
        mod_folders = os.getenv("SKYRIM_MOD_FOLDERS")
    })
```

#### `mod_files`

You can also specify additional files to deploy to the mod folder:

```lua
add_requires("skyrim-commonlib-ae")

target("My-SKSE-Plugin")
    add_files("plugin.cpp")
    add_packages("skyrim-commonlib-ae")
    add_rules("@skyrim-commonlib-ae/plugin", {
        mod_files = { "Scripts", "", "AnythingToDeployToTheModFolder" }
    })
```

> _These xmake configurations were originally based on these CommonLibSSE-NG xmake package configuration:_
> _https://github.com/xmake-io/xmake-repo_
> _License: Apache 2.0_
>
> _That xmake configuration was authored by by Qudix (https://github.com/Qudix)_
>
> _Modifications were made to the original code_
