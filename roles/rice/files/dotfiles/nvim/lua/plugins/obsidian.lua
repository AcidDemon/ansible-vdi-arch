return {
  "epwalsh/obsidian.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  ft = "markdown",
  config = function()
    require("obsidian").setup({
      workspaces = {
        {
          name = "personal",
          path = vim.fn.expand("~/Documents/Obsidian"),
        },
      },

      notes_subdir = "notes",
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        template = nil,
      },

      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },

      note_id_func = function(title)
        local suffix = ""
        if title ~= nil then
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. "-" .. suffix
      end,

      frontmatter = {
        func = function(note)
          local out = { id = note.id, aliases = note.aliases, tags = note.tags }
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,
      },

      templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      ui = {
        enable = true,
      },

      checkbox = {
        order = {" ", "x", ">", "~"},
        chars = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        },
      },

      attachments = {
        folder = "attachments",
      },

      follow_url_func = false,
      legacy_commands = false,
    })

    -- Set up buffer-local keymaps
    vim.keymap.set("n", "gf", function()
      if require("obsidian").util.cursor_on_markdown_link() then
        return "<cmd>ObsidianFollowLink<cr>"
      else
        return "gf"
      end
    end, { noremap = false, expr = true, buffer = true })

    vim.keymap.set("n", "<leader>ch", function()
      return require("obsidian").util.toggle_checkbox()
    end, { buffer = true })

    local wk = require "which-key"
    wk.add {
      { "<leader>o", group = "Obsidian" },
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New note" },
      { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian app" },
      { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch notes" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },
      { "<leader>ot", "<cmd>ObsidianTags<cr>", desc = "Search tags" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show backlinks" },
      { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Today's daily note" },
      { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday's daily note" },
      { "<leader>of", "<cmd>ObsidianFollowLink<cr>", desc = "Follow link" },
      { "<leader>oc", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Toggle checkbox" },
    }
  end
}
