# AI Code Completions Setup

This dotfiles repository is configured with AI-powered code completions for enhanced productivity.

## Overview

**Default Provider: Tabnine (Privacy-First, Free)**
- 🔒 **Runs locally on your machine** - your code never leaves your computer
- 🆓 **Completely free** forever
- 🔐 **Maximum security** - perfect for proprietary/sensitive code
- ⚡ Works offline - no internet required
- 🌍 Supports all major languages
- ✅ Works in Neovim and Zed

**Why Tabnine?** Unlike cloud-based alternatives (Copilot, Codeium, Supermaven), Tabnine runs entirely on your local machine. Your code stays private and secure.

## Neovim Setup

### Already Configured
Your Neovim config already includes Tabnine! Just follow these steps:

1. **Open Neovim** for the first time after installation
2. The plugin manager (lazy.nvim) will automatically install Tabnine
3. Tabnine will download its local AI model (may take a minute on first run)
4. **No authentication required!** It just works
5. Done! You now have private, local AI completions

### Usage
- **Tab**: Accept AI suggestion (or cycle through completion menu)
- **Ctrl-]**: Dismiss suggestion
- Suggestions appear automatically as you type

### Local Mode (Default)
By default, Tabnine runs in **local mode**:
- All AI processing happens on your machine
- No internet connection needed
- Your code never leaves your computer
- Perfect for NDAs, enterprise code, and sensitive projects

### Optional: Enable Cloud Mode
If you want higher quality suggestions (at the cost of privacy):
1. Run `:TabnineHub` in Neovim
2. This opens Tabnine settings in your browser
3. Sign up for a free account
4. Enable "Cloud" mode in settings

**Note:** We keep local mode as default for maximum privacy.

## Zed Setup

### Steps to Enable

1. **Install Tabnine Extension**:
   - Open Zed
   - Press `Cmd+Shift+X` (or `Ctrl+Shift+X` on Linux)
   - Search for "Tabnine"
   - Click Install

2. **That's it!**
   - No authentication required for local mode
   - Inline completions are already enabled in your settings
   - Tabnine downloads its local model automatically
   - You'll see AI suggestions as you type

3. **Optional: Sign in for Cloud Mode**
   - If prompted, you can sign in for better suggestions
   - But local mode works great without any account

### Usage
- **Tab**: Accept suggestion
- **Esc**: Dismiss suggestion
- Suggestions appear automatically as you type
- Works 100% offline in local mode

## Alternative Providers (Cloud-Based)

**⚠️ Warning:** The following alternatives send your code to cloud servers. Only use these if you're comfortable with that tradeoff.

### Codeium (Free, Cloud)
Best free cloud alternative to Copilot:

**Neovim:** Replace Tabnine in `~/.config/nvim/init.lua`:
```lua
-- Replace Tabnine with Codeium
{
  "Exafunction/codeium.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
  config = function()
    require("codeium").setup({ enable_chat = true })
  end,
}

-- Update cmp sources:
sources = {
  { name = "codeium", priority = 1000 },
  -- ... rest of sources
}
```

**Zed:** Install "Codeium" extension, authenticate

### GitHub Copilot (Paid - $10/month, Cloud)
Industry standard, best quality:

**Neovim:** Replace Tabnine with:
```lua
{
  "github/copilot.vim",
}
```

**Zed:** Install "GitHub Copilot" extension, authenticate with GitHub

### Supermaven (Free tier, Cloud)
Fastest cloud option:

**Neovim:** Replace Tabnine with:
```lua
{
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({})
  end,
}
```

**Zed:** Install "Supermaven" extension

## Comparison

| Provider | Cost | Quality | Speed | Privacy | Location |
|----------|------|---------|-------|---------|----------|
| **Tabnine** (Default) | Free | ⭐⭐⭐ | Medium | ⭐⭐⭐⭐⭐ | 🔒 Local |
| **GitHub Copilot** | $10/mo | ⭐⭐⭐⭐⭐ | Fast | ⭐⭐⭐ | ☁️ Cloud |
| **Codeium** | Free | ⭐⭐⭐⭐ | Fast | ⭐⭐⭐ | ☁️ Cloud |
| **Supermaven** | Free tier | ⭐⭐⭐⭐ | Very Fast | ⭐⭐⭐ | ☁️ Cloud |

**The Tradeoff:**
- **Tabnine (local)**: Lower quality suggestions, but your code NEVER leaves your machine
- **Cloud options**: Better quality suggestions, but your code is sent to remote servers

**Our choice:** Privacy and security > slightly better suggestions

## Troubleshooting

### Neovim: Completions not showing
1. Check if Tabnine is installed: `:Lazy` (should show tabnine-nvim and cmp-tabnine)
2. Check Tabnine status: `:TabnineStatus`
3. Open Tabnine Hub to verify settings: `:TabnineHub`
4. Restart Neovim
5. Give it time on first launch - downloading the local model can take 1-2 minutes

### Zed: Completions not showing
1. Check if Tabnine extension is installed: Extensions panel (Cmd+Shift+X)
2. Check settings: `show_inline_completions: true` (already configured)
3. Restart Zed
4. Wait for model download on first launch

### Slow/Low Quality Suggestions
This is expected with local mode! Tabnine's local model trades quality for privacy.

**Options:**
1. **Accept the tradeoff** - lower quality for 100% privacy (recommended)
2. **Enable cloud mode** - Run `:TabnineHub` and sign in (defeats privacy benefit)
3. **Switch to cloud provider** - See "Alternative Providers" section above

### Privacy Verification
Want to verify Tabnine is running locally?

1. Open Tabnine Hub: `:TabnineHub` in Neovim
2. Check that "Local" mode is enabled (not "Cloud")
3. Disconnect from internet and verify completions still work!

## Disabling AI Completions

### Neovim
Comment out the Tabnine plugins in `~/.config/nvim/init.lua`:
```lua
-- Disable Tabnine by commenting these out:
-- {
--   "codota/tabnine-nvim",
--   ...
-- },

-- Also remove from cmp dependencies:
dependencies = {
  -- "tzachar/cmp-tabnine",  -- Comment this out
  ...
}

-- And remove from cmp sources:
sources = {
  -- { name = "cmp_tabnine", priority = 1000 },  -- Comment this out
  ...
}
```

### Zed
Set in `~/.config/zed/settings.json`:
```json
"show_inline_completions": false
```

Or disable per-project in `.zed/settings.json`

### Per-Project Disable (Neovim)
For sensitive projects, you can disable Tabnine for specific file paths by adding to your Tabnine config:
```lua
exclude_filetypes = { "TelescopePrompt", "NvimTree" },
-- Add file patterns to exclude:
-- Can also be configured via :TabnineHub
```
