-- ~/.config/nvim/init.lua - User neovim configuration
--
-- This file sources the dotfiles neovim configuration and allows for local customization.
-- The dotfiles are managed separately and can be updated without affecting your local changes.

-- ============================================================================
-- Source Dotfiles Configuration
-- ============================================================================

-- Determine dotfiles directory
local dotfiles_dir = os.getenv("DOTFILES_DIR")
if not dotfiles_dir or dotfiles_dir == "" then
    -- Try standard locations
    local candidates = {
        vim.fn.expand("~/.dotfiles"),
        vim.fn.expand("~/dotfiles"),
        vim.fn.expand("~/.config/dotfiles")
    }

    for _, candidate in ipairs(candidates) do
        local init_lua = candidate .. "/common/nvim/.config/nvim/init.lua"
        if vim.fn.filereadable(init_lua) == 1 then
            dotfiles_dir = candidate
            vim.env.DOTFILES_DIR = dotfiles_dir
            break
        end
    end

    -- If still not found, warn user
    if not dotfiles_dir then
        vim.api.nvim_echo({
            {"Warning: Dotfiles not found. Please set DOTFILES_DIR environment variable.\n", "WarningMsg"},
            {"Expected location: ~/.dotfiles/common/nvim/.config/nvim/init.lua\n", "Normal"}
        }, true, {})
        return
    end
end

-- Source the main dotfiles neovim configuration
local dotfiles_init = dotfiles_dir .. "/common/nvim/.config/nvim/init.lua"
if vim.fn.filereadable(dotfiles_init) == 1 then
    dofile(dotfiles_init)
else
    vim.api.nvim_echo({
        {"Warning: Dotfiles init.lua not found at " .. dotfiles_init .. "\n", "WarningMsg"}
    }, true, {})
end

-- ============================================================================
-- Local Customizations
-- ============================================================================

-- Add your local customizations below this line
-- This section will not be modified by dotfiles updates

-- Example: Local key mappings
-- vim.keymap.set('n', '<leader>p', ':echo "Hello from local init.lua"<CR>', { noremap = true })

-- Example: Local settings
-- vim.opt.number = true
-- vim.opt.relativenumber = true

-- Example: Local plugin configurations
-- require('my_custom_config')

-- Source additional local neovim config if it exists
local local_init = vim.fn.expand("~/.config/nvim/init.local.lua")
if vim.fn.filereadable(local_init) == 1 then
    dofile(local_init)
end

-- Source personal neovim profile if it exists
local personal_init = vim.fn.expand("~/.config/nvim/personal.lua")
if vim.fn.filereadable(personal_init) == 1 then
    dofile(personal_init)
end
