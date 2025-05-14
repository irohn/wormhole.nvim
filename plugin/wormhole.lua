local wh = require("wormhole")
local ssh = require("wormhole.ssh")

local cmd_function = function(opts)
  if not opts.args or opts.args == "" then
    -- Show help or default behavior when no arguments are provided
    print("Usage: Wormhole [ssh|explore]")
    return
  elseif opts.args == "explore" then
    ssh.select_host(wh.options.ssh.config_path, function(choice)
      ssh.explore_files(choice)
    end)
  elseif opts.args == "ssh" then
    ssh.select_host(wh.options.ssh.config_path, function(choice)
      ssh.spawn_terminal(choice)
    end)
  else
    -- Handle unknown arguments
    print("Unknown command: " .. opts.args)
    print("Available commands: ssh, explore")
  end
end

vim.api.nvim_create_user_command("Wormhole", cmd_function, {
  nargs = "?",
  desc = "Wormhole command interface"
})
vim.api.nvim_create_user_command("Wh", cmd_function, {
  nargs = "?",
  desc = "Wormhole command interface"
})
