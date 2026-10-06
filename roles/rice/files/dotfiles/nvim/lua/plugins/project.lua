return {
  "ahmedkhalf/project.nvim",
  config = function()
          vim.api.nvim_create_autocmd("VimEnter", {
            once = true,
            callback = function()
              local ok, project = pcall(require, "project_nvim")
              if not ok then
                vim.notify("[project.nvim] require failed — not on runtimepath", vim.log.levels.ERROR)
                return
              end

              project.setup({
                active = true,
                manual_mode = false,
                ignore_lsp = {},
                exclude_dirs = {},
                show_hidden = false,
                silent_chdir = true,
                scope_chdir = "global",
                detection_methods = { "pattern" },
                patterns = {
                  ".git","_darcs",".hg",".bzr",".svn",
                  "Makefile","package.json","pom.xml",
                },
              })

              pcall(function() require("telescope").load_extension("projects") end)
              vim.g.__project_nvim_setup_ran = 1
            end,
          })
  end
}
