return {
  -- Gitsigns: Mostra barras coloridas na esquerda (Add/Change/Delete)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        -- Configuração visual dos sinais
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
        },
        -- Atalhos úteis para Git (opcional, mas recomendado)
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navegar entre mudanças (hunk)
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          -- Ações
          map('n', '<leader>gb', gs.toggle_current_line_blame, { desc = "Git Blame (Linha)" })
          map('n', '<leader>gd', gs.diffthis, { desc = "Git Diff" })
          map('n', '<leader>gp', gs.preview_hunk, { desc = "Preview da Mudança" })
        end
      })
    end,
  }
}
