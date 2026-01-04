return {
  {
    "hrsh7th/nvim-cmp",
    -- Carrega quando entra no modo de inserção (evita pesar o boot)
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",         -- Fonte: Inteligência do LSP
      "hrsh7th/cmp-buffer",           -- Fonte: Texto do arquivo atual
      "hrsh7th/cmp-path",             -- Fonte: Caminhos de arquivos
      "L3MON4D3/LuaSnip",             -- Engine de Snippets (Obrigatório)
      "saadparwaiz1/cmp_luasnip",     -- Conecta o LuaSnip no CMP
      "rafamadriz/friendly-snippets", -- Coleção de snippets prontos
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Carrega snippets estilo VSCode
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(), -- Força abrir o menu
          ["<C-e>"] = cmp.mapping.abort(),        -- Cancela
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter confirma

          -- Configuração do TAB para navegar no menu
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- Prioridade alta: Inteligência do código
          { name = "luasnip" },  -- Snippets
          { name = "buffer" },   -- Palavras que já estão no texto
          { name = "path" },     -- Caminhos de pastas/arquivos
        }),
      })
    end,
  },
}
