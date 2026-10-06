return {
  "goolord/alpha-nvim",
  config = function()
          local alpha = require("alpha")
          local dashboard = require("alpha.themes.dashboard")
          dashboard.section.header.val = {
              [[                               __                ]],
              [[  ___      __    ___   __  __ /\_\    ___ ___    ]],
              [[/' _ `\  /'__`\ / __`\/\ \/\ \\/\ \ /' __` __`\  ]],
              [[/\ \/\ \/\  __//\ \L\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
              [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
              [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
          }
          dashboard.section.buttons.val = {
              dashboard.button("e", " " .. " New", "<cmd>ene <BAR> startinsert<CR>"),
              dashboard.button("f", " " .. " Files", "<cmd>Telescope find_files<CR>"),
              dashboard.button("/", "󰱽 " .. " Search", "<cmd>Telescope live_grep<CR>"),
              dashboard.button("r", "󱀩 " .. " Recent", "<cmd>Telescope oldfiles<CR>"),
              dashboard.button("o", " " .. " Projects", "<cmd>Telescope projects<CR>"),
              dashboard.button("q", " " .. " Quit", "<cmd>qa<CR>"),
          }
          local function footer()
              return "github.com/AcidDemon"
          end
          dashboard.section.footer.val = footer()
          dashboard.section.footer.opts.hl = "Function"
          dashboard.section.header.opts.hl = "Function"
          dashboard.section.buttons.opts.hl = "Function"
          dashboard.opts.opts.noautocmd = true
          alpha.setup(dashboard.opts)
  end
}
