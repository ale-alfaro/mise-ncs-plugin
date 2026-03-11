local http = require("http")
local json = require("json")

local M = {}

local BASE_URL = "https://files.nordicsemi.com/artifactory/NCS/external/bundles/v3/"

function M.get_platform()
    local os_type = RUNTIME.osType
    local arch_type = RUNTIME.archType
    local os_map = { linux = "linux", darwin = "macos" }
    local arch_map = { amd64 = "x86_64", arm64 = "aarch64", x86_64 = "x86_64", aarch64 = "aarch64" }
    return os_map[os_type] or os_type, arch_map[arch_type] or arch_type
end

---@return NCSVersionData[]
function M.fetch_index()
    local os_name, arch = M.get_platform()
    local index_url = BASE_URL .. "index-" .. os_name .. "-" .. arch .. ".json"

    local resp, err = http.get({ url = index_url })
    if err ~= nil then
        error("Failed to fetch NCS toolchain index: " .. err)
    end
    if resp.status_code ~= 200 then
        error("NCS index returned status " .. resp.status_code .. ": " .. resp.body)
    end

    return json.decode(resp.body)
end
---@param version string
---@return NCSVersion
function M.find_version(version)
    local entries = M.fetch_index()

    for _, entry in ipairs(entries) do
        local entry_version, filename, sha512

        if entry.json_api_version == 2 then
            entry_version = entry.key
            filename = entry.metadata.filename
            sha512 = entry.metadata.sha512
        end

        if entry_version == version and filename then
            return {
                version = version,
                url = BASE_URL .. filename,
                sha512 = sha512,
            }
        end
    end

    local os_name, arch = M.get_platform()
    error("NCS toolchain version " .. version .. " not found for " .. os_name .. "-" .. arch)
end

---@param bin_path string
---@param bins string[]
function M.remove_from_bin_path(bin_path, bins)
    local cmd = require("cmd")
    for _, bin in ipairs(bins) do
        local ok, ret = pcall(function()
            return cmd.exec("rm -f " .. bin, { cwd = bin_path })
        end)

        if not ok then
            error("Failed to remove " .. bin .. "binaries from the bin path " .. bin_path .. "ret=" .. ret)
        end
    end
end
return M
