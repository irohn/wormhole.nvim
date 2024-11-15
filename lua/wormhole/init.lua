local home_dir = require("plenary").path.path.home
local ssh = require("wormhole.ssh")

local defaults = {
  ssh = {
    explorer_provider = "netrw",
    port = 22,
    config_path = home_dir .. "/.ssh/config",
  },
  sync = {
    program = "rsync",
  },
}

local M = {}

function M.setup(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  local hosts = ssh.parse_config(opts.ssh.config_path)
end

M.setup()

return M
