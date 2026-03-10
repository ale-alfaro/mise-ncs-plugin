--- Performs setup after NCS toolchain installation
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#postinstall-hook
--- @param ctx {rootPath: string, runtimeVersion: string, sdkInfo: table} Context
function PLUGIN:PostInstall(ctx)
    local cmd = require("cmd")
    local file = require("file")
    local sdkInfo = ctx.sdkInfo[PLUGIN.name]
    local path = sdkInfo.path

    -- The tar.gz is auto-extracted by mise into the install path.
    -- Discover arm-zephyr-eabi/bin and create a symlink at a well-known
    -- location so EnvKeys can add it to PATH without running find on every shell start.
    local ok, arm_bin = pcall(function()
        return cmd.exec("find " .. path .. " -type d -name bin -path '*/arm-zephyr-eabi/bin' 2>/dev/null | head -1")
    end)

    if ok and arm_bin then
        arm_bin = arm_bin:gsub("%s+$", "")
        if arm_bin ~= "" then
            file.symlink(arm_bin, path .. "/arm-zephyr-eabi-bin")
        end
    end
end
