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


# --- Claude Code "Switcher" Functions ---

# 1. The Builder (Z.ai / GLM-4.7)
# This explicitly sets the Base URL and Key just for this command.
claude-glm() {
    # Read the key from your .env file
    local ZAI_KEY=$(grep 'ZAI_PROXY_KEY' ~/.env | cut -d '"' -f 2)

    echo "🚀 Starting GLM-4.7 (Builder Mode via Z.ai)"

    # Run claude with temporary environment variables
    # We use 'env' to ensure they don't leak into your current shell
    env ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic" \
        ANTHROPIC_API_KEY="$ZAI_KEY" \
        claude --model glm-4.7
}

# 2. The Supervisor (Official Anthropic / Subscription)
# This ensures any stray API keys are hidden so it falls back to your login.
claude-opus() {

    echo "⚖️ Starting Opus 4.5 (Supervisor Mode / Subscription)"

    # We 'unset' the API key variables for this command execution
    # so Claude Code is forced to use your browser-based login.
    env -u ANTHROPIC_API_KEY -u ANTHROPIC_BASE_URL \
        claude --model opus
}

# 3. Local Ollama (via litellm proxy)
# Start litellm first: litellm --model ollama/llama3 --port 11435
claude-local() {

    echo "🏠 Starting Claude Code (Local Ollama via litellm)"

    env ANTHROPIC_BASE_URL="http://localhost:11435/v1" \
        ANTHROPIC_API_KEY="dummy" \
        claude
}

# 4. Home Ollama (remote, needs proxy setup)
claude-home() {

    echo "🏠 Starting Claude Code (Home Ollama)"

    env ANTHROPIC_BASE_URL="https://ollama.janvv.nl/v1" \
        ANTHROPIC_API_KEY="dummy" \
        claude
}
