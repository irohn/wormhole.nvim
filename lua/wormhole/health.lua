local health = vim.health
local start = health.start
local ok = health.ok
local warn = health.warn
local error = health.error
local info = health.info

local is_win = vim.fn.has("win32") == 1
local is_mac = vim.fn.has("mac") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_mac


local function check_binary_installed(binary)
  -- Check if the binary exists in PATH
  local exists = vim.fn.executable(binary.binaries[1]) == 1

  if not exists then
    return false, nil
  end

  -- Get the version of the binary
  local version_cmd = binary.binaries[1] .. " " .. binary.version_flag
  local handle = io.popen(version_cmd .. " 2>&1")
  if not handle then
    return true, nil
  end

  local result = handle:read("*l")
  handle:close()

  -- Clean up the version string
  local version = result:gsub("^%s*(.-)%s*$", "%1")

  return true, version
end

local function lualib_installed(lib_name)
  local res, _ = pcall(require, lib_name)
  return res
end

local required_executables = {
  {
    name = "ssh",
    url = "https://www.openssh.com/",
    binaries = { "ssh" },
    optional = false,
    version_flag = "-V",
  },
  {
    name = "rsync",
    url = "https://rsync.samba.org/",
    binaries = { "rsync" },
    optional = true,
    info = "(Required for syncing files with remote.)",
    version_flag = "--version",
  },
  {
    name = "fswatch",
    url = "https://github.com/emcrisostomo/fswatch",
    binaries = { "fswatch" },
    optional = true,
    info = "(Required for continous sync with remote.)",
    version_flag = "--version",
  },
}

local required_plugins = {
  {
    name = "plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim",
    lib = "plenary",
    optional = false,
    info = "(Required for core functionality.)",
  },
  {
    name = "oil.nvim",
    url = "https://github.com/stevearc/oil.nvim",
    lib = "oil",
    optional = true,
    info = "(Required for oil-ssh.)",
  },
  {
    name = "snacks.nvim",
    url = "https://github.com/folke/snacks.nvim",
    lib = "snacks",
    optional = true,
    info = "(Optional for 'vim.ui.select'.)",
  },
}

local M = {}

M.check = function()
  start("Checking operating system.")
  if is_win then
    error("Windows is not currently supported.")
    info("Use WSL on Windows machines: https://learn.microsoft.com/en-us/windows/wsl/install")
  elseif is_mac then
    ok("MacOS detected.")
  elseif is_linux then
    ok("Linux detected.")
  else
    warn("Unknown operating system. Some features might not be supported.")
  end

  start("Checking for executables")
  for _, executable in ipairs(required_executables) do
    local installed, version = check_binary_installed(executable)
    if installed then
      ok(executable.name .. " is installed. Version: " .. (version or "Unknown"))
    else
      if executable.optional then
        warn(executable.name .. " is not installed. " .. (executable.info or "Some features might not work properly."))
      else
        error(executable.name .. " is not installed.")
      end
    end
  end

  start("Checking for plugins")
  for _, plugin in ipairs(required_plugins) do
    if lualib_installed(plugin.lib) then
      ok(plugin.name .. " installed.")
    else
      local lib_not_installed = plugin.name .. " not found."
      if plugin.optional then
        warn(("%s %s"):format(lib_not_installed, plugin.info))
      else
        error(lib_not_installed)
      end
    end
  end

end

return M
