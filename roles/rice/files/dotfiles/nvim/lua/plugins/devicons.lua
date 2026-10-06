return {
  "nvim-tree/nvim-web-devicons",
  config = function()
          local devicons = require("nvim-web-devicons")

          devicons.set_icon({
              astro = {
                  --  󱓟 
                  icon = "󱓞",
                  color = "#FF7E33",
                  name = "astro",
              },
          })
  end
}
