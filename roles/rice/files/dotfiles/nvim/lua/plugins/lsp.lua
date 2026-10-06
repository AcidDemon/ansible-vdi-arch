return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "onsails/lspkind.nvim", "jmbuhr/otter.nvim" },
    config = function()
      -- Otter lazy loading (LSP for embedded code in markdown/quarto)
      require("otter").setup({
        buffers = {
          set_filetype = false,
          write_to_disk = false,
        },
        handle_leading_whitespace = true,
      })

        vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "quarto", "norg" },
        callback = function()
          require("otter").activate()
        end,
      })

      local wk = require "which-key"
      wk.add {
        { "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Apply code action" },
        { "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Quickfix code action" },
        { "<leader>k", "<cmd>lua vim.lsp.buf.hover()<cr>", desc = "Show documentation for symbol under cursor" },
        { "<leader>r", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename symbol" },
        { "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action" },
        { "[d", "<cmd>lua vim.diagnostic.jump({ count = -1, float = true })<cr>", desc = "Go to prev diagnostic" },
        { "]d", "<cmd>lua vim.diagnostic.jump({ count = 1, float = true })<cr>", desc = "Go to next diagnostic" },
        { "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = "Go to declaration" },
      }

      local servers = {
        ansiblels = {},
        astro = {},
        bashls = {},
        clangd = {},
        clojure_lsp = {},
        cssls = {},
        cssmodules_ls = {},
        dagger = {},
        diagnosticls = {},
        dockerls = {},
        emmet_ls = {},
        eslint = {},
        gopls = {},
        graphql = {},
        html = {},
        jsonls = {},
        lua_ls = {},
        markdown_oxide = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true
              }
            }
          }
        },
        nixd = {},
        prismals = {},
        sqlls = {},
        tailwindcss = {},
        terraformls = {
          cmd = { "tofu-ls", "serve" },
          settings = {
            ["terraform-ls"] = {
              ignoreSingleFileWarning = true
            }
          }
        },
        texlab = {
          settings = {
            texlab = {
              build = {
                executable = "latexmk",
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                onSave = true,
              },
              diagnostics = {
                ignoredPatterns = {},
              },
            },
          },
        },
        tinymist = {
          settings = {
            formatterMode = "typstyle",
            exportPdf = "onSave",
          },
        },
        ts_ls = {},
        vimls = {},
        yamlls = {},
      }

      for server, settings in pairs(servers) do
        local options = vim.tbl_deep_extend("force", {
          on_attach = function(client, bufnr)
          end
        }, settings)
        vim.lsp.enable(server)
        vim.lsp.config(server, options)
      end
    end
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        server = {
          cmd = { "rust-analyzer" },
          default_settings = {
            ['rust-analyzer'] = {
              inlayHints = {
                enable = true,
              }
            }
          }
        }
      }
      vim.api.nvim_set_hl(0, '@lsp.type.comment.rust', {})
    end
  }
}
