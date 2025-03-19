-- add 2 commands:
--    CodeCompanionSave [space delimited args]
--    CodeCompanionLoad
-- Save will save current chat in a md file named 'space-delimited-args.md'
-- Load will use a telescope filepicker to open a previously saved chat

-- create a folder to store our chats
local function save_path()
  local Path = require 'plenary.path'
  local p = Path:new(vim.fn.stdpath 'data' .. '/codecompanion_chats')
  p:mkdir { parents = true }
  return p
end

-- telescope picker for our saved chats
vim.api.nvim_create_user_command('CodeCompanionLoad', function()
  local t_builtin = require 'telescope.builtin'
  local t_actions = require 'telescope.actions'
  local t_action_state = require 'telescope.actions.state'

  local function start_picker()
    t_builtin.find_files {
      prompt_title = 'Saved CodeCompanion Chats | <c-d>: delete',
      cwd = save_path():absolute(),
      -- hidden = true, -- Show hidden files
      no_ignore = true, -- Don't respect .gitignore files
      attach_mappings = function(_, map)
        map('i', '<c-d>', function(prompt_bufnr)
          local selection = t_action_state.get_selected_entry()
          local filepath = selection.path or selection.filename
          os.remove(filepath)
          t_actions.close(prompt_bufnr)
          start_picker()
        end)
        return true
      end,
    }
  end
  start_picker()
end, {})

-- save current chat, `CodeCompanionSave foo bar baz` will save as 'foo-bar-baz.md'
vim.api.nvim_create_user_command('CodeCompanionSave', function(opts)
  local codecompanion = require 'codecompanion'
  local success, chat = pcall(function()
    return codecompanion.buf_get_chat(0)
  end)
  if not success or chat == nil then
    vim.notify('CodeCompanionSave should only be called from CodeCompanion chat buffers', vim.log.levels.ERROR)
    return
  end
  if #opts.fargs == 0 then
    vim.notify('CodeCompanionSave requires at least 1 arg to make a file name', vim.log.levels.ERROR)
  end
  local save_name = table.concat(opts.fargs, '-') .. '.md'
  local save_path = save_path():joinpath(save_name)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  save_path:write(table.concat(lines, '\n'), 'w')
  vim.notify('CodeCompanionSave saved the file', vim.log.levels.INFO)
end, { nargs = '*' })

return {
  {
    'olimorris/codecompanion.nvim',
    config = true,
    opts = {
      opts = {
        -- Set debug logging
        log_level = 'DEBUG',
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
          adapter = 'openai',
        },
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
}
