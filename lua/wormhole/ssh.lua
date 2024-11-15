local plenary = require("plenary")
local context_manager = plenary.context_manager

local with = context_manager.with
local open = context_manager.open

local M = {}

M.parse_config = function(config_path)
  local hosts = {}
  local current_hosts = nil

  with(open(config_path), function(reader)
    for line in reader:lines() do
      line = line:match("^%s*(.-)%s*$")
      if line ~= "" and not line:match("^#") then

        local host_line = line:match("^[Hh][Oo][Ss][Tt]%s+(.+)$")
        if host_line then
          -- Split multiple hosts
          current_hosts = {}
          for host in host_line:gmatch("%S+") do
            current_hosts[#current_hosts + 1] = host
            hosts[host] = hosts[host] or {}
          end
        elseif current_hosts then
          local key, value = line:match("^%s*(%S+)%s+(.+)$")
          if key then
            key = key:lower()
            value = value:gsub('^"(.-)"$', '%1')
            value = value:gsub("^'(.-)'$", '%1')

            -- Apply the config to all current hosts
            for _, host in ipairs(current_hosts) do
              hosts[host][key] = value
            end
          end
        end
      end
    end
  end)

  return hosts
end

return M

