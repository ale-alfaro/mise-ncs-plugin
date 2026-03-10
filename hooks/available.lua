--- Returns a list of available NCS toolchain versions
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#available-hook
--- @param ctx {args: string[]} Context (args = user arguments)
--- @return table[] List of available versions
function PLUGIN:Available(ctx)
    local ncs = require("ncs")
    local entries = ncs.fetch_index()
    local result = {}

    for _, entry in ipairs(entries) do
        local version
        if entry.json_api_version == 2 then
            version = entry.key
        else
            version = entry.version
        end

        local note = nil
        if version:find("-rc") or version:find("-preview") then
            note = "pre-release"
        end

        table.insert(result, {
            version = version,
            note = note,
        })
    end

    return result
end
