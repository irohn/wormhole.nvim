local plenary = require("plenary")
local home_dir = plenary.path.path.home
local context_manager = plenary.context_manager

local with = context_manager.with
local open = context_manager.open

local M = {}

M.parse_config = function(config_path)
  local hosts = {}

  with(open(config_path), function(reader)
    local lines = reader:lines()
    local includes = {}
    for line in lines do
      line = line:lower()
      if line:match("^include") then
        local include_path = line:match("^include%s+(.*)")
        if include_path then
          include_path = include_path:gsub("^~", home_dir)
          table.insert(includes, include_path)
        end
      elseif line:match("^host%s+") then
        local host = line:match("^host%s+(.*)")
        table.insert(hosts, host)
      else
      end
    end
    if #includes > 0 then
      for _, include_path in ipairs(includes) do
        local include_hosts = M.parse_config(include_path)
        for _, host in ipairs(include_hosts) do
          table.insert(hosts, host)
        end
      end
    end
  end)

  return hosts
end

M.select_host = function(config_path, on_choice)
  local hosts = M.parse_config(config_path)

  vim.ui.select(hosts, {
    prompt = "Select SSH host:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice then
      on_choice(choice)
    end
  end)
end

M.spawn_terminal = function(host)
  if not host then
    vim.notify("No host provided", vim.log.levels.ERROR)
    return
  end

  local term_cmd = string.format("ssh %s", host)

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local buf = vim.api.nvim_create_buf(false, true)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded"
  }

  local win = vim.api.nvim_open_win(buf, true, opts)

  ---@diagnostic disable-next-line: param-type-mismatch
  local ok, err = pcall(vim.cmd, string.format("terminal %s", term_cmd))
  if not ok then
    vim.notify("Failed to spawn terminal: " .. err, vim.log.levels.ERROR)
    vim.api.nvim_win_close(win, true)
  end

  vim.cmd("startinsert")
end

return M
