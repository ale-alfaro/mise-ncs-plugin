--- Configures environment variables for the NCS toolchain
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#envkeys-hook
--- @param ctx {path: string, runtimeVersion: string, sdkInfo: table} Context
--- @return table[] List of environment variable definitions
function PLUGIN:EnvKeys(ctx)
    local cmd = require("cmd")
    local file = require("file")
    local strings = require("strings")
    local semver = require("semver")
    local log = require("log")
    local mainPath = ctx.path

    local usr_bin_dir = file.join_path(mainPath, "usr", "local", "bin")
    local ld_lib_path = file.join_path(mainPath, "usr", "local", "lib")
    local sdk_install_dir = file.join_path(mainPath, "opt", "zephyr-sdk")
    local sdk_bin_dir = file.join_path(mainPath, "opt", "zephyr-sdk", "arm-zephyr-eabi", "bin")
    local env_vars = {
        {
            key = "PATH",
            value = usr_bin_dir,
        },
        {
            key = "PATH",
            value = sdk_bin_dir,
        },
        {
            key = "LD_LIBRARY_PATH",
            value = ld_lib_path,
        },
        {
            key = "ZEPHYR_TOOLCHAIN_VARIANT",
            value = "zephyr",
        },
        {
            key = "ZEPHYR_SDK_INSTALL_DIR",
            value = sdk_install_dir,
        },
    }

    local python_bin = file.join_path(usr_bin_dir, "python3")
    local ok, raw_output = pcall(function()
        return cmd.exec(python_bin .. " --version", { env = { LD_LIBRARY_PATH = ld_lib_path } })
    end)
    if not ok or not raw_output then
        error("Failed to get the python version of the toolchain")
    end
    -- "Python 3.12.2" → "3.12.2"
    local python_version = strings.trim_space(raw_output):match("%S+$")
    local parts = semver.parse(python_version)
    if parts[1] ~= 3 then
        error("Python version is invalid " .. python_version)
    end
    log.info("PYTHON VERSION:", python_version)
    table.insert(env_vars, {
        key = "NCS_PYTHON_VERSION",
        value = python_version,
    })

    return env_vars
end
