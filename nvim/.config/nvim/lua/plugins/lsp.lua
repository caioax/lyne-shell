return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- 1. Setup do Mason (Interface Gráfica)
      require("mason").setup()

      -- 2. Setup do Mason-LSPConfig com HANDLERS (O jeito novo da v2.0)
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "ts_ls", "html", "cssls", "bashls", "pyright", "tailwindcss"
        },
        automatic_installation = true,

        -- Aqui está a mágica: Handlers definem como ligar cada servidor
        handlers = {
          function(server_name)
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- Opções comuns (atalhos de teclado)
            local opts = {
              capabilities = capabilities,
              on_attach = function(_, bufnr)
                local map = vim.keymap.set
                local k_opts = { buffer = bufnr, noremap = true, silent = true }
                map("n", "gd", vim.lsp.buf.definition, k_opts)
                map("n", "K", vim.lsp.buf.hover, k_opts)
                map("n", "<leader>rn", vim.lsp.buf.rename, k_opts)
                map("n", "<leader>ca", vim.lsp.buf.code_action, k_opts)
              end,
            }

            -- LÓGICA HÍBRIDA: Tenta o jeito novo (vim.lsp.config), senão usa o velho
            if vim.lsp.config and vim.lsp.config[server_name] then
               -- Jeito Moderno (Nvim 0.11+ ou polyfill)
               vim.lsp.config[server_name].setup(opts)
            else
               -- Fallback: Se o vim.lsp.config não existir, usamos o antigo
               -- (Isso pode gerar aviso, mas é necessário se seu Nvim for < 0.11)
               require("lspconfig")[server_name].setup(opts)
            end
          end,
        },
      })
    end,
  },
}
