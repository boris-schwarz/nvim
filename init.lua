-- Disable netrw so it doesn't fill the window when opening a directory
-- (neo-tree handles directories as a sidebar instead). Must be set before plugins load.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- line numbers: absolute for the current line, relative for the rest (hybrid).
-- makes vertical motions like 5j / 12k easy to count.
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", space = "·", trail = "~" }
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.fixeol = true   -- always ensure a final newline on save
vim.opt.eol = true
vim.g.mapleader = " "

-- Show the project folder (cwd tail) as the terminal window title
-- (alacritty's dynamic_title picks this up; re-evaluated on cwd changes).
vim.opt.title = true
vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')} — nvim"

-- Use PowerShell 7 for :terminal, :! and system() on Windows. The extra shell
-- options come from :h shell-powershell — without them :! passes cmd.exe-style
-- flags to pwsh. Linux keeps the default $SHELL.
if vim.fn.has("win32") == 1 then
  vim.o.shell = "pwsh"
  vim.o.shellcmdflag = "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';$PSStyle.OutputRendering='plaintext';Remove-Alias -Force -ErrorAction SilentlyContinue tee;"
  vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  vim.o.shellpipe = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
end

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<leader>s", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>bt", function()
  -- If focus is in a special panel (e.g. neo-tree), open the terminal in a
  -- normal file window so it doesn't take over the sidebar.
  if vim.bo.buftype ~= "" then
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
  end
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "New terminal buffer" })
vim.keymap.set("n", "<leader>cr", function()
  local root = vim.fs.root(0, "Cargo.toml")
  if not root then
    vim.notify("Not in a Cargo project (no Cargo.toml found)", vim.log.levels.WARN)
    return
  end
  vim.cmd("botright 15split | terminal cargo run --manifest-path " .. vim.fn.fnameescape(root) .. "/Cargo.toml")
  vim.cmd("startinsert")
end, { desc = "cargo run" })
vim.keymap.set("n", "<leader>cb", function()
  local root = vim.fs.root(0, "Cargo.toml")
  if not root then
    vim.notify("Not in a Cargo project (no Cargo.toml found)", vim.log.levels.WARN)
    return
  end
  vim.cmd("botright 15split | terminal cargo build --manifest-path " .. vim.fn.fnameescape(root) .. "/Cargo.toml")
  vim.cmd("startinsert")
end, { desc = "cargo build" })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- When launched on a directory (e.g. `nvim c:\home\project`), make it the
-- cwd so the window title, telescope, and live_grep are scoped to it.
if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
  vim.cmd.cd(vim.fn.argv(0))
end

-- When launched on a directory (e.g. `nvim .`) with no file given, open
-- src/main.rs in the main window if it exists, instead of an empty buffer.
-- Registered before lazy.setup() because neo-tree (lazy = false) can trigger
-- VimEnter during setup, before an autocmd defined afterwards would attach.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Bail if an actual file was passed on the command line.
    if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 0 then
      return
    end
    if vim.fn.argc() > 1 then
      return
    end
    local dir = vim.fn.argc() == 1 and vim.fn.argv(0) or vim.fn.getcwd()
    local main = vim.fn.fnamemodify(dir, ":p") .. "src/main.rs"
    if vim.fn.filereadable(main) == 0 then
      return
    end
    -- Open it in a normal window, not the neo-tree sidebar. Deferred so it
    -- runs after neo-tree has finished building the sidebar.
    vim.schedule(function()
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(w)].filetype ~= "neo-tree" then
          vim.api.nvim_set_current_win(w)
          break
        end
      end
      vim.cmd("edit " .. vim.fn.fnameescape(main))
    end)
  end,
})

require("lazy").setup("plugins")

-- Non-plugin config: built-in LSP completion and language servers.
require("config.completion")
require("config.cflsp")
