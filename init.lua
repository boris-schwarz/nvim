-- Disable netrw so it doesn't fill the window when opening a directory
-- (neo-tree handles directories as a sidebar instead). Must be set before plugins load.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<leader>s", ":w<CR>", { desc = "Save file" })
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
