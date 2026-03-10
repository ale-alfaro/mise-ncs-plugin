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

function M.get_download_info(version)
    local entries = M.fetch_index()

    for _, entry in ipairs(entries) do
        local entry_version, filename, sha512

        if entry.json_api_version == 2 then
            entry_version = entry.key
            filename = entry.metadata.filename
            sha512 = entry.metadata.sha512
        else
            entry_version = entry.version
            if entry.toolchains and #entry.toolchains > 0 then
                filename = entry.toolchains[1].name
                sha512 = entry.toolchains[1].sha512
            end
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

return M
