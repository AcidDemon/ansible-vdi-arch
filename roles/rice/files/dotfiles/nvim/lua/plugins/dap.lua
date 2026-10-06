return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio"
  },
  keys = {
    { "<leader>G", desc = "Debug" },
    { "<leader>Gb", desc = "Debug: Toggle breakpoint" },
    { "<leader>Gc", desc = "Debug: Continue" },
    { "<leader>Gi", desc = "Debug: Step into" },
    { "<leader>Go", desc = "Debug: Step over" },
    { "<leader>GO", desc = "Debug: Step out" },
    { "<leader>Gl", desc = "Debug: Run last" },
    { "<leader>Gt", desc = "Debug: Terminate" },
    { "<leader>Gr", desc = "Debug: Toggle REPL" },
    { "<leader>Gd", desc = "Debug: Toggle UI" },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    local DAP_PORT = "13000"
    dap.adapters.codelldb = {
      type = "server",
      port = DAP_PORT,
      executable = {
        command = "codelldb",
        args = { "--port", DAP_PORT },
      },
    }

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    dap.configurations.c = {
      {
        name = "Launch file (codeLLDB)",
        type = "codelldb",
        request = "launch",
        program = function()
          local path
          vim.ui.input({
            prompt = "Path to executable: ",
            default = (vim.uv or vim.loop).cwd() .. "/build/",
          }, function(input)
            path = input
          end)
          vim.cmd([[redraw]])
          return path
        end,
        stopOnEntry = false,
      },
    }

    dapui.setup({
      expand_lines = true,
      icons = { expanded = "", collapsed = "", circular = "" },
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.33 },
            { id = "breakpoints", size = 0.17 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 0.33,
          position = "right",
        },
        {
          elements = {
            { id = "repl", size = 0.45 },
            { id = "console", size = 0.55 },
          },
          size = 0.27,
          position = "bottom",
        },
      },
      floating = {
        max_height = 0.9,
        max_width = 0.5,
        border = vim.g.border_chars,
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
    })

    vim.fn.sign_define("DapBreakpoint", {
      text = "",
      texthl = "DiagnosticSignError",
      linehl = "",
      numhl = "",
    })

    local wk = require "which-key"
    wk.add({
      { "<leader>G", group = "Debug" },
      { "<leader>Gb", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle breakpoint" },
      { "<leader>Gc", function() require("dap").continue() end, desc = "Debug: Continue" },
      { "<leader>Gi", function() require("dap").step_into() end, desc = "Debug: Step into" },
      { "<leader>Go", function() require("dap").step_over() end, desc = "Debug: Step over" },
      { "<leader>GO", function() require("dap").step_out() end, desc = "Debug: Step out" },
      { "<leader>Gl", function() require("dap").run_last() end, desc = "Debug: Run last" },
      { "<leader>Gt", function() require("dap").terminate() end, desc = "Debug: Terminate" },
      { "<leader>Gr", function() require("dap").repl.toggle({ height = 14 }) end, desc = "Debug: Toggle REPL" },
      { "<leader>Gd", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
    }, { mode = "n" })
  end
}
