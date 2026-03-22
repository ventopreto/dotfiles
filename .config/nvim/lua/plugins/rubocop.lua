return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      rubocop = {
        cmd = { "bundle", "exec", "rubocop", "--lsp" },
        root_dir = function(fname)
          local util = require("lspconfig.util")
          return util.root_pattern("Gemfile", ".rubocop.yml", ".rubocop.yaml")(fname)
        end,
        single_file_support = false,
      },
    },
  },
}
