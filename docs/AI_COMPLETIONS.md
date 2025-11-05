# AI Code Completions Setup

This dotfiles repository is configured with AI-powered code completions for enhanced productivity.

## Overview

**Recommended Provider: Codeium (Free)**
- Free alternative to GitHub Copilot
- Excellent code completion quality
- Supports all major languages
- Works in Neovim and Zed

## Neovim Setup

### Already Configured
Your Neovim config already includes Codeium! Just follow these steps:

1. **Open Neovim** for the first time after installation
2. The plugin manager will automatically install Codeium
3. On first use, Codeium will prompt you to authenticate:
   - It will open a browser window
   - Sign up/login (free account)
   - Copy the auth token
   - Paste it back in Neovim
4. Done! You now have AI completions

### Usage
- **Tab**: Accept AI suggestion
- **Alt-]**: Next suggestion
- **Alt-[**: Previous suggestion
- **Ctrl-]**: Dismiss suggestion

### Codeium Chat (Bonus)
Codeium also provides a ChatGPT-like interface in Neovim:
- `:Codeium Chat` - Open chat interface
- Ask questions about your code
- Generate code snippets
- Debug issues

## Zed Setup

### Steps to Enable

1. **Install Codeium Extension**:
   - Open Zed
   - Press `Cmd+Shift+X` (or `Ctrl+Shift+X` on Linux)
   - Search for "Codeium"
   - Click Install

2. **Authenticate**:
   - After installation, Codeium will prompt for authentication
   - Sign in with the same account you used for Neovim

3. **Done!**
   - Inline completions are already enabled in your settings
   - You'll see AI suggestions as you type

### Usage
- **Tab**: Accept suggestion
- **Esc**: Dismiss suggestion
- Suggestions appear automatically as you type

## Alternative Providers

### GitHub Copilot (Paid - $10/month)
If you prefer GitHub Copilot:

**Neovim:**
Replace the Codeium plugin in `~/.config/nvim/init.lua`:
```lua
-- Replace Codeium with Copilot
{
  "github/copilot.vim",
}
```

**Zed:**
- Install the "GitHub Copilot" extension instead
- Authenticate with your GitHub account

### Supermaven (Free tier available)
Another excellent option:

**Neovim:**
```lua
{
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({})
  end,
}
```

**Zed:**
- Install "Supermaven" extension from Zed extensions

## Comparison

| Provider | Cost | Quality | Speed | Privacy |
|----------|------|---------|-------|---------|
| **Codeium** | Free | ⭐⭐⭐⭐ | Fast | Good |
| **GitHub Copilot** | $10/mo | ⭐⭐⭐⭐⭐ | Fast | Good |
| **Supermaven** | Free tier | ⭐⭐⭐⭐ | Very Fast | Good |
| **Tabnine** | Free tier | ⭐⭐⭐ | Medium | Best (local) |

## Troubleshooting

### Neovim: Completions not showing
1. Check if Codeium is installed: `:Lazy`
2. Check Codeium status: `:Codeium Auth`
3. Restart Neovim

### Zed: Completions not showing
1. Check if extension is installed: Extensions panel
2. Check settings: `show_inline_completions: true`
3. Restart Zed

### Privacy Concerns
All providers send code snippets to their servers for completions. If you have strict privacy requirements:
- Use Tabnine with local mode
- Or disable AI completions in sensitive projects
- Add paths to `disabled_globs` in Zed settings

## Disabling AI Completions

### Neovim
Comment out the Codeium plugin in `~/.config/nvim/init.lua`

### Zed
Set in `~/.config/zed/settings.json`:
```json
"show_inline_completions": false
```

Or disable per-project in `.zed/settings.json`
