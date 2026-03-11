--- Returns download information for a specific NCS toolchain version
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#preinstall-hook
--- @param ctx {version: string, runtimeVersion: string} Context
---@return NCSVersion
function PLUGIN:PreInstall(ctx)
    local ncs = require("ncs")
    return ncs.find_version(ctx.version)
end
