return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter", -- Carrega só quando começa a digitar
    config = true,         -- Usa a configuração padrão
    -- Opcional: Integração com o menu de autocomplete (CMP)
    -- Se você der Enter no menu de sugestão, ele ajusta os parênteses
    dependencies = { "hrsh7th/nvim-cmp" },
    init = function()
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )
    end,
  },
}
