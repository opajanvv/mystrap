# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add .local/bin to PATH for user scripts
export PATH="$HOME/.local/bin:$PATH"

# Default editor
export EDITOR=nvim

# Claude Code: trigger auto-compact at 80% context usage
export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=80

# SSH agent
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
fi
ssh-add -q ~/.ssh/"$(hostname)" 2>/dev/null
ssh-add -q ~/.ssh/github 2>/dev/null
ssh-add -q ~/.ssh/gitlab 2>/dev/null

. "$HOME/.local/share/../bin/env"
export PATH=$PATH:/home/jan/.npm-global/bin


# Claude Code wrapper functions
[[ -f ~/.config/claude-wrappers.sh ]] && source ~/.config/claude-wrappers.sh
