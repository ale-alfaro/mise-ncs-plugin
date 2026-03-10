--- Returns download information for a specific NCS toolchain version
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#preinstall-hook
--- @param ctx {version: string, runtimeVersion: string} Context
--- @return table Version and download information
function PLUGIN:PreInstall(ctx)
    local ncs = require("ncs")
    return ncs.get_download_info(ctx.version)
end
