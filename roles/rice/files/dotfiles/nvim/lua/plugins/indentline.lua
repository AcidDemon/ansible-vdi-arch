return {
  "lukas-reineke/indent-blankline.nvim",
  config = function()
          require("ibl").setup({
              exclude = {
                filetypes = {
                  "NvimTree",
                  "Trouble",
                  "dashboard",
                  "help",
                  "lazy",
                  "neogitstatus",
                  "packer",
                  "startify",
                  "text",
                },
                buftypes = {
                  "terminal", "nofile"
                },
              },
          })
  end
}
