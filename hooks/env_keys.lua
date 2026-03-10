--- Configures environment variables for the NCS toolchain
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#envkeys-hook
--- @param ctx {path: string, runtimeVersion: string, sdkInfo: table} Context
--- @return table[] List of environment variable definitions
function PLUGIN:EnvKeys(ctx)
    local file = require("file")
    local mainPath = ctx.path

    local env_vars = {
        {
            key = "PATH",
            value = mainPath .. "/bin",
        },
    }

    -- Add arm-zephyr-eabi cross-compiler tools to PATH
    -- (symlink created by PostInstall pointing to the actual bin directory)
    local arm_bin_link = mainPath .. "/arm-zephyr-eabi-bin"
    if file.exists(arm_bin_link) then
        table.insert(env_vars, {
            key = "PATH",
            value = arm_bin_link,
        })
    end

    table.insert(env_vars, {
        key = "ZEPHYR_TOOLCHAIN_VARIANT",
        value = "zephyr",
    })

    table.insert(env_vars, {
        key = "ZEPHYR_SDK_INSTALL_DIR",
        value = mainPath .. "/opt/zephyr-sdk",
    })

    return env_vars
end
