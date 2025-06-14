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

  -- Create a new buffer
  vim.cmd("new")

  -- Get the current buffer
  local buf = vim.api.nvim_get_current_buf()

  -- Set buffer name
  vim.api.nvim_buf_set_name(buf, "ssh://" .. host)

  -- Run the terminal command in the buffer
  ---@diagnostic disable-next-line: param-type-mismatch
  local ok, err = pcall(vim.cmd, string.format("terminal %s", term_cmd))
  if not ok then
    vim.notify("Failed to spawn terminal: " .. err, vim.log.levels.ERROR)
    vim.cmd("bdelete!")
    return
  end

  vim.cmd("startinsert")
end

M.explore_files = function(host, path)
  if not host then
    vim.notify("No host provided", vim.log.levels.ERROR)
    return
  end

  if not path then
    vim.ui.input({
      prompt = "Enter path to explore: ",
    }, function(input)
      if input then
        path = input
        -- check if oil.nvim is installed and use oil-ssh, if not fall back to scp (netrw)
        local oil_installed = pcall(require, "oil")
        if oil_installed then
          local adapter = "oil-ssh"
          local oil = require("oil")
          oil.open(string.format("%s://%s//%s", adapter, host, path))
        else
          local adapter = "scp"
          vim.cmd(string.format("edit %s://%s/%s", adapter, host, path))
        end
      end
    end)
    return
  end

  -- check if oil.nvim is installed and use oil-ssh, if not fall back to scp (netrw)
  local oil_installed = pcall(require, "oil")
  if oil_installed then
    local adapter = "oil-ssh"
    local oil = require("oil")
    oil.open(string.format("%s://%s//%s", adapter, host, path))
  else
    local adapter = "scp"
    vim.cmd(string.format("%s://%s//%s", adapter, host, path))
  end
end

return M
