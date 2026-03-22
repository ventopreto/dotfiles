return {
  "vim-test/vim-test",
  keys = {
    { "<leader>tT", "<CMD>TestSuite<CR>", desc = "Run test suite of the current file" },
    { "<leader>tg", "<CMD>TestVisit<CR>", desc = "Open the last run test in the current buffer" },
    { "<leader>tl", "<CMD>TestLast<CR>", desc = "Run the last test" },
    { "<leader>tr", "<CMD>TestNearest<CR>", desc = "Run a test nearest to the cursor" },
    { "<leader>tt", "<CMD>TestFile<CR>", desc = "Run tests for the current file" },
    {
      "<leader>tq",
      function()
        if vim.env.ZELLIJ and vim.fn.executable("zellij") == 1 then
          vim.fn.jobstart({ "zellij", "action", "toggle-floating-panes" }, { detach = true })
          return
        end

        vim.cmd("ToggleTermToggleAll")
      end,
      desc = "Toggle test terminals",
    },
  },
  config = function()
    local function toggleterm_strategy(cmd)
      vim.cmd(("TermExec cmd='%s'"):format(cmd:gsub("'", '"')))
    end

    local function zellij_strategy(direction)
      return function(cmd)
        if not vim.env.ZELLIJ or vim.fn.executable("zellij") ~= 1 then
          toggleterm_strategy(cmd)
          return
        end

        local args = { "zellij", "run", "--name", "vim-test", "--cwd", vim.fn.getcwd() }

        if direction == "float" then
          vim.list_extend(args, { "--floating", "--pinned", "true" })
        else
          vim.list_extend(args, { "--direction", direction })
        end

        vim.list_extend(args, { "--", "bash", "-lc", cmd })
        vim.fn.jobstart(args, { detach = true })
      end
    end

    _G.vim_test_zellij_float = zellij_strategy("float")
    _G.vim_test_zellij_right = zellij_strategy("right")

    vim.cmd([[
      function! VimTestZellijFloat(cmd) abort
        call v:lua.vim_test_zellij_float(a:cmd)
      endfunction

      function! VimTestZellijRight(cmd) abort
        call v:lua.vim_test_zellij_right(a:cmd)
      endfunction

      let g:test#custom_strategies = extend(get(g:, 'test#custom_strategies', {}), {
            \ 'zellij_float': function('VimTestZellijFloat'),
            \ 'zellij_right': function('VimTestZellijRight'),
            \ })
      let test#strategy = 'zellij_float'
    ]])
  end,
}
