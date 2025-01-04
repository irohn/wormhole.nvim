local wh = require("wormhole")
local ssh = require("wormhole.ssh")

local cmd_function = function(opts)
  if opts.args == "ssh" then
    ssh.select_host(wh.options.ssh.config_path, function(choice)
      ssh.spawn_terminal(choice)
    end)
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
