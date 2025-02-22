-- This configuration is based on code from https://github.com/xmake-io/xmake-repo
-- License: Apache 2.0
-- Original xmake configuration for CommonLibSSE-NG project by Qudix (https://github.com/Qudix)
-- Modifications were made to the original code

rule("plugin")

add_deps("win.sdk.resource")

before_build(function(target)
    target:add("packages", "skyrim-commonlib-vr")
end)

on_config(function(target)
    import("core.base.semver")
    import("core.project.depend")
    import("core.project.project")

    target:add("defines",
        "SKYRIMVR",
        "BOOST_STL_INTERFACES_DISABLE_CONCEPTS",
        "UNICODE", "_UNICODE"
    )

    target:set("kind", "shared")
    target:set("arch", "x64")

    target:add("cxxflags", "/permissive-", "/Zc:alignedNew", "/Zc:__cplusplus", "/Zc:forScope", "/Zc:ternary")
    target:add("cxxflags", "cl::/Zc:externConstexpr", "cl::/Zc:hiddenFriend", "cl::/Zc:preprocessor",
        "cl::/Zc:referenceBinding")

    local config = target:extraconf("rules", "@skyrim-commonlib-vr/plugin")

    local plugin_name = config.name or target:name()
    local author_name = config.author or ""
    local author_email = config.email or ""

    local version = semver.new(config.version or target:version() or "0.0.0")
    local version_string = string.format("%s.%s.%s", version:major(), version:minor(), version:patch())

    local product_version = semver.new(config.product_version or project.version() or config.version or target:version() or
    "0.0.0")
    local product_version_string = string.format("%s.%s.%s", product_version:major(), product_version:minor(),
        product_version:patch())

    local output_files_folder = path.join(target:autogendir(), "rules", "skyrim-commonlib-vr", "plugin")

    local version_file = path.join(output_files_folder, "version.rc")
    depend.on_changed(function()
        local file = io.open(version_file, "w")
        if file then
            file:print("#include <winres.h>\n")
            file:print("1 VERSIONINFO")
            file:print("FILEVERSION %s, %s, %s, 0", version:major(), version:minor(), version:patch())
            file:print("PRODUCTVERSION %s, %s, %s, 0", product_version:major(), product_version:minor(),
                product_version:patch())
            file:print("FILEFLAGSMASK 0x17L")
            file:print("#ifdef _DEBUG")
            file:print("    FILEFLAGS 0x1L")
            file:print("#else")
            file:print("    FILEFLAGS 0x0L")
            file:print("#endif")
            file:print("FILEOS 0x4L")
            file:print("FILETYPE 0x1L")
            file:print("FILESUBTYPE 0x0L")
            file:print("BEGIN")
            file:print("    BLOCK \"StringFileInfo\"")
            file:print("    BEGIN")
            file:print("        BLOCK \"040904b0\"")
            file:print("        BEGIN")
            file:print("            VALUE \"FileDescription\", \"%s\"", config.description or "")
            file:print("            VALUE \"FileVersion\", \"%s.0\"", version_string)
            file:print("            VALUE \"InternalName\", \"%s\"", config.name or target:name())
            file:print("            VALUE \"LegalCopyright\", \"%s, %s\"", config.author or "",
                config.license or target:license() or "Unknown License")
            file:print("            VALUE \"ProductName\", \"%s\"",
                config.product_name or project.name() or config.name or target:name())
            file:print("            VALUE \"ProductVersion\", \"%s.0\"", product_version_string)
            file:print("        END")
            file:print("    END")
            file:print("    BLOCK \"VarFileInfo\"")
            file:print("    BEGIN")
            file:print("        VALUE \"Translation\", 0x409, 1200")
            file:print("    END")
            file:print("END")
            file:close()
        end
    end, { dependfile = target:dependfile(version_file), files = project.allfiles() })

    local plugin_file = path.join(output_files_folder, "plugin.cpp")
    depend.on_changed(function()
        local file = io.open(plugin_file, "w")
        if file then
            file:print("#include <SKSEPluginInfo.h>")
            file:print("")
            file:print("// For standard access from your SKSE plugin")
            file:print("// These are functions for flexibility")
            file:print("namespace SKSEPluginInfo {")
            file:print("    const char* GetPluginName() { return \"" .. plugin_name .. "\"; }")
            file:print("    const char* GetAuthorName() { return \"" .. author_name .. "\"; }")
            file:print("    const char* GetAuthorEmail() { return \"" .. author_email .. "\"; }")
            file:print("    const REL::Version GetPluginVersion() { return REL::Version{" ..
            version:major() .. ", " .. version:minor() .. ", " .. version:patch() .. "}; }")
            file:print("}")
            file:print("")
            file:print("// These need to be constant to support AE's SKSEPlugin_Version structure")
            file:print("// These aren't visible to the code")
            file:print("namespace SKSEPluginInfoConstants {")
            file:print("    using namespace std::literals;")
            file:print("    inline constexpr std::string_view PluginName = \"" .. plugin_name .. "\"sv;")
            file:print("    inline constexpr std::string_view AuthorName = \"" .. author_name .. "\"sv;")
            file:print("    inline constexpr std::string_view AuthorEmail = \"" .. author_email .. "\"sv;")
            file:print("    inline constexpr REL::Version PluginVersion = { " ..
            version:major() .. ", " .. version:minor() .. ", " .. version:patch() .. " };")
            file:print("}")
            file:print("")
            file:print("#include <SKSEPluginInfo/Extern/SKSEPlugin_Query.h>")
            file:close()
        end
    end, { dependfile = target:dependfile(plugin_file), files = project.allfiles() })

    target:add("files", version_file)
    target:add("files", plugin_file)
end)

after_build(function(target)
    local config = target:extraconf("rules", "@skyrim-commonlib-vr/plugin")

    local output_folders = config.output_folders or {}

    if config.output_folder then
        table.insert(output_folders, config.output_folder)
    end

    local dll = target:targetfile()
    local pdb = dll:gsub("%.dll$", ".pdb")

    for _, output_folder in ipairs(output_folders) do
        local dll_target = path.join(output_folder, path.filename(dll))
        local pdb_target = path.join(output_folder, path.filename(pdb))

        -- Clean up previous files in the output folder
        if os.isfile(dll_target) then
            os.rm(dll_target)
        end
        if os.isfile(pdb_target) then
            os.rm(pdb_target)
        end

        if not os.isdir(output_folder) then
            os.mkdir(output_folder)
        end

        -- Copy new files to output fulder
        os.cp(dll, output_folder)
        if os.isfile(pdb) then
            os.cp(pdb, output_folder)
        end
    end

    -- Split string into a table by a delimiter
    function split(str, delim)
        local result = {}
        for match in (str .. delim):gmatch("(.-)" .. delim) do
            table.insert(result, match)
        end
        return result
    end

    -- add unique items to a "set"
    function addToSet(set, value)
        set[value] = true
    end

    local all_folders_set = {}     -- "set" to store unique folder paths
    local mod_names = { "mod_folder", "mods_folder", "mods_folders", "mod_folders" }

    for _, mod_name in ipairs(mod_names) do
        local mod_value = config[mod_name]     -- This could be a table or a string
        if mod_value then
            if type(mod_value) == "table" then
                for _, entry in ipairs(mod_value) do
                    -- split by semicolons
                    for _, item in ipairs(split(entry, ";")) do
                        if item ~= "" then     -- No empty strings
                            addToSet(all_folders_set, item)
                        end
                    end
                end
            elseif type(mod_value) == "string" then
                -- split by semicolons
                for _, item in ipairs(split(mod_value, ";")) do
                    if item ~= "" then
                        addToSet(all_folders_set, item)
                    end
                end
            end
        end
    end

    -- Convert set to table
    local mod_folders = {}
    for k in pairs(all_folders_set) do
        table.insert(mod_folders, k)
    end

    local mod_name = config.mod_name or config.name or target:name()
    local mod_files = config.mod_files or {}

    table.insert(mod_files, dll)
    if os.isfile(pdb) then
        table.insert(mod_files, pdb)
    end

    for _, mods_folder in ipairs(mod_folders) do
        local mod_folder = path.join(mods_folder, mod_name)
        for _, mod_file in ipairs(mod_files) do
            if os.isfile(mod_file) then
                local mod_file_target = path.join(mod_folder, path.filename(mod_file))

                if mod_file == dll then
                    mod_file_target = path.join(mod_folder, "SKSE", "Plugins", path.filename(mod_file))
                elseif mod_file == pdb then
                    mod_file_target = path.join(mod_folder, "SKSE", "Plugins", path.filename(mod_file))
                end

                local mod_file_target_dir = path.directory(mod_file_target)
                if not os.isdir(mod_file_target_dir) then
                    os.mkdir(mod_file_target_dir)
                end

                -- Clean up previous files in the output folder
                if os.isfile(mod_file_target) then
                    os.rm(mod_file_target)
                end

                -- Copy new files to output fulder
                os.cp(mod_file, mod_file_target_dir)
            elseif os.isdir(mod_file) then
                local mod_folder_target = path.join(mod_folder, path.filename(mod_file))
                print("Copying " .. mod_file .. " to " .. mod_folder_target)

                if not os.isdir(mod_folder_target) then
                    os.mkdir(mod_folder_target)
                end

                for _, file in ipairs(os.files(path.join(mod_file, "*"))) do
                    local source_file = file
                    local target_file = path.join(mod_folder_target, path.filename(file))

                    -- Does it exist already? If so, delete it first:
                    if os.isfile(target_file) then
                        print("Deleting file: " .. target_file)
                        os.rm(target_file)
                    end

                    print("Copying file: " .. source_file .. " to " .. mod_folder_target)
                    os.cp(source_file, mod_folder_target)
                end

                for _, dir in ipairs(os.dirs(path.join(mod_file, "*"))) do
                    local source_dir = dir
                    local target_dir = path.join(mod_folder_target, path.filename(dir))

                    -- Does it exist already? If so, delete it first:
                    if os.isdir(target_dir) then
                        print("Deleting directory: " .. target_dir)
                        os.rmdir(target_dir)
                    end

                    print("Copying directory: " .. source_dir .. " to " .. target_dir)
                    os.cp(source_dir, target_dir)
                end
            else
                print("File not found: " .. mod_file)
            end
        end
    end
end)
