return {
  {
    'olimorris/codecompanion.nvim',
    config = true,
    opts = {
      opts = {
        -- Set debug logging
        log_level = 'ERROR',
      },
      adapters = {
        llama3custom = function()
          return require('codecompanion.adapters').extend('ollama', {
            name = 'llama3custom', -- Give this adapter a different name to differentiate it from the default ollama adapter
            schema = {
              model = {
                default = 'llama3.2',
              },
              num_ctx = {
                default = 16384,
              },
              num_predict = {
                default = -1,
              },
            },
          })
        end,
        --opts = {
        --  allow_insecure = true,
        --  proxy = 'http://127.0.0.1:8080',
        --},
      },
      strategies = {
        chat = {
          adapter = 'anthropic',
          keymaps = {
            close = {
              modes = { n = '<C-x>', i = '<C-x>' },
            },
            -- Add further custom keymaps here
          },
        },
        inline = {
          adapter = 'anthropic',
        },
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
}
