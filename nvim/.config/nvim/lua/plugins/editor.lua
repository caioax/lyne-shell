return {
  -- File Explorer (Árvore de arquivos)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- Ícones
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Abrir/Fechar Explorer" },
    },
    config = function()
      require("neo-tree").setup({
        window = {
          width = 30, -- Largura da janela lateral
        },
        filesystem = {
          filtered_items = {
            visible = true, -- Mostra arquivos ocultos (.config, etc)
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = { enabled = true }, -- Segue o arquivo que você abriu
        },
      })
    end,
  },

  -- Telescope (Buscador Fuzzy - Essencial)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Buscar Arquivos" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Buscar Texto" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Arquivos Abertos" },
    },
  },

  -- Treesitter (Highlighting Inteligente)
  {
    "nvim-treesitter/nvim-treesitter",
    -- A ESTRATÉGIA DELE: Travamos na versão estável para não quebrar nunca mais
    tag = "v0.9.2", 
    build = ":TSUpdate",
    
    -- A OTIMIZAÇÃO DELE: Só carrega quando ler um arquivo (Deixa o boot rápido)
    event = { "BufReadPost", "BufNewFile" },
    
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Instale apenas o essencial para não pesar
        ensure_installed = { "bash", "c", "html", "javascript", "lua", "markdown", "vim", "vimdoc" },
        
        -- Instala automaticamente se faltar algum parser
        auto_install = true,
        
        -- Ativa o highlight (Cores)
        highlight = { enable = true },
        
        -- Ativa a indentação inteligente (baseada na estrutura do código)
        indent = { enable = true },
      })
    end,
  },
}
