# Fish-specific settings.

set -g fish_greeting

if not set -q ALIAS_SYMLINK_DIR
    set -gx ALIAS_SYMLINK_DIR $HOME/.dotfiles_aliases
    mkdir -p $ALIAS_SYMLINK_DIR
end

# Fish stores universal variables itself; these helpers keep shared snippets
# harmless when they are sourced from Fish.
function read_dotfile_vars
end

function store_dotfile_var
end
