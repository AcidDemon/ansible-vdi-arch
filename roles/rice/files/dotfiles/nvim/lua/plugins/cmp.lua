return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "L3MON4D3/LuaSnip",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "lukas-reineke/cmp-rg",
    "saadparwaiz1/cmp_luasnip",
    "petertriho/cmp-git",
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require('cmp')
    cmp.setup({
      formatting = {
        format = require('lspkind').cmp_format({
          before = function (entry, vim_item)
            return vim_item
          end,
        }),
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
        ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
        ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<C-e>"] = cmp.mapping {
          i = cmp.mapping.abort(),
          c = cmp.mapping.close(),
        },
        ["<Tab>"] = cmp.mapping.confirm { select = true },
      }),
      sources = {
        { name='copilot' },
        { name='otter' },
        { name='nvim_lsp' },
        { name='luasnip' },
        { name='buffer' },
        { name='path' },
        { name='calc' },
        { name='git' },
        { name='rg' },
      },
    })

    -- Better completion for markdown-oxide (wiki-links, daily notes, etc.)
    cmp.setup.filetype('markdown', {
      sources = {
        { name = 'nvim_lsp',
          option = {
            markdown_oxide = {
              keyword_pattern = [[\(\k| |\/|#\)\+]]
            }
          }
        },
        { name = 'copilot' },
        { name = 'otter' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
      }
    })

    require("cmp_git").setup({})
  end
}
