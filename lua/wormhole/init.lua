local home_dir = require("plenary").path.path.home

local M = {}

M.options = {
  ssh = {
    config_path = home_dir .. "/.ssh/config",
  },
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

return M
