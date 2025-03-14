return {
  {
    'olimorris/codecompanion.nvim',
    config = true,
    opts = {
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
      },
      strategies = {
        chat = {
          adapter = 'llama3custom',
        },
        inline = {
          adapter = 'llama3custom',
        },
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
}
