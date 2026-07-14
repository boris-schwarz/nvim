return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("bufferline").setup({
      options = {
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "thick",
        offsets = {
          { filetype = "neo-tree", text = "File Explorer", separator = true },
        },
      },
      highlights = {
        fill = { bg = "#11111b" },
        -- inactive tabs: dim text on a dark background
        background = { fg = "#6c7086", bg = "#181825" },
        buffer_visible = { fg = "#a6adc8", bg = "#181825" },
        -- active tab: bright text on a clearly lighter background
        buffer_selected = { fg = "#cdd6f4", bg = "#313244", bold = true, italic = false },
        close_button_selected = { fg = "#cdd6f4", bg = "#313244" },
        modified_selected = { fg = "#a6e3a1", bg = "#313244" },
        duplicate_selected = { fg = "#a6adc8", bg = "#313244" },
        numbers_selected = { fg = "#cdd6f4", bg = "#313244" },
        diagnostic_selected = { bg = "#313244" },
        info_selected = { bg = "#313244" },
        hint_selected = { bg = "#313244" },
        warning_selected = { bg = "#313244" },
        error_selected = { bg = "#313244" },
        indicator_selected = { fg = "#89b4fa", bg = "#313244" },
        separator = { fg = "#11111b", bg = "#181825" },
        separator_selected = { fg = "#11111b", bg = "#313244" },
      },
    })

    -- If focus is in a special panel (e.g. neo-tree), first jump to a normal
    -- file window, then cycle -- so the file never loads into the sidebar.
    local function cycle(cmd)
      return function()
        if vim.bo.buftype ~= "" then
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].buftype == "" then
              vim.api.nvim_set_current_win(win)
              break
            end
          end
          -- no normal file window open -- nothing to cycle
          if vim.bo.buftype ~= "" then
            return
          end
        end
        vim.cmd(cmd)
      end
    end

    vim.keymap.set("n", "<S-l>", cycle("BufferLineCycleNext"), { desc = "Next buffer" })
    vim.keymap.set("n", "<S-h>", cycle("BufferLineCyclePrev"), { desc = "Previous buffer" })
    -- Close the current buffer without closing its window: switch the window
    -- to another buffer first, so the layout (and neo-tree sidebar) survives.
    vim.keymap.set("n", "<leader>bd", function()
      if vim.bo.buftype ~= "" then
        return
      end
      local cur = vim.api.nvim_get_current_buf()
      if vim.bo[cur].modified then
        vim.notify("Buffer has unsaved changes (save with <leader>s first)", vim.log.levels.WARN)
        return
      end
      local listed = vim.tbl_filter(function(b)
        return vim.fn.buflisted(b) == 1
      end, vim.api.nvim_list_bufs())
      if #listed > 1 then
        vim.cmd("BufferLineCyclePrev")
      else
        vim.cmd("enew")
      end
      vim.api.nvim_buf_delete(cur, {})
    end, { desc = "Close buffer" })
  end,
}
