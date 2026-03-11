--- Performs setup after NCS toolchain installation
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#postinstall-hook
--- @param ctx {rootPath: string, runtimeVersion: string, sdkInfo: table} Context
function PLUGIN:PostInstall(ctx)
    local file = require("file")
    local log = require("log")
    local cmd = require("cmd")
    local ncs = require("ncs")
    local sdkInfo = ctx.sdkInfo[PLUGIN.name]
    local path = sdkInfo.path
    local zephyr_sdk_install = file.join_path(path, "opt", "zephyr-sdk")
    local usr_bin_dir = file.join_path(path, "usr", "local", "bin")
    -- The tar.gz is auto-extracted by mise into the install path.
    -- Discover arm-zephyr-eabi/bin and create a symlink at a well-known
    -- location so EnvKeys can add it to PATH without running find on every shell start.
    if
        not file.exists(file.join_path(zephyr_sdk_install, "sdk_version"))
        or not file.exists(file.join_path(zephyr_sdk_install, "sdk_toolchains"))
    then
        error("Couldnt find the arm-zephyr-eabi toolchain bin path")
    end
    log.info("ZEPHYR_SDK VERSION:", file.read(file.join_path(zephyr_sdk_install, "sdk_version")))
    log.info("ZEPHYR_SDK TOOLCHAINS:", file.read(file.join_path(zephyr_sdk_install, "sdk_toolchains")))
    ncs.remove_from_bin_path(usr_bin_dir, { "git*", "west", "ninja" })
end
