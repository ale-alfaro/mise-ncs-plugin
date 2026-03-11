--- Returns a list of available NCS toolchain versions
--- Documentation: https://mise.jdx.dev/tool-plugin-development.html#available-hook
---
---

---@class NCSVersionCache[]
---@field versions NCSVersionData[]
---@field timestamp number
-- Cache versions for 12 hours
local cache = {}
local cache_ttl = 12 * 60 * 60 -- 12 hours in seconds
MIN_VERSION = "2.7.0"
local function get_supported_versions()
    local ncs = require("ncs")
    local now = os.time()

    -- Check cache first
    if cache.versions and cache.timestamp and (now - cache.timestamp) < cache_ttl then
        return cache.versions
    end

    -- Fetch fresh data
    local versions = ncs.fetch_index()

    -- Update cache
    cache.versions = versions
    cache.timestamp = now

    return versions
end

--- @param ctx {args: string[]} Context (args = user arguments)
--- @return table[] List of available versions
function PLUGIN:Available(ctx)
    local entries = get_supported_versions()
    local semver = require("semver")
    local strings = require("strings")
    local result = {}

    for _, entry in ipairs(entries) do
        if entry.json_api_version == 2 and entry.key and string.match(entry.key, "^v%d%.%d%.%d") then
            local version = strings.trim(entry.key, "v")
            if semver.compare(version, MIN_VERSION) >= 0 then
                local metadata = nil
                if strings.contains(version, "-rc") or strings.contains(version, "-preview") then
                    metadata = "pre-release"
                end

                table.insert(result, {
                    version = version,
                    note = metadata,
                })
            end
        end
    end

    return semver.sort_by(result, "version")
end
