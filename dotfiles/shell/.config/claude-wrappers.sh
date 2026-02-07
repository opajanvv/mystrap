# Claude Code "Switcher" Functions
# Source this file from ~/.bashrc or ~/.zshrc

# 1. The Builder (Z.ai / GLM-4.7)
# This explicitly sets the Base URL and Key just for this command.
claude-glm() {
    # Check for .env file
    if [[ ! -f ~/.env ]]; then
        echo "Error: ~/.env file not found"
        return 1
    fi

    # Read the key from your .env file
    local ZAI_KEY=$(grep 'ZAI_PROXY_KEY' ~/.env | cut -d '"' -f 2)

    # Validate key exists
    if [[ -z "$ZAI_KEY" ]]; then
        echo "Error: ZAI_PROXY_KEY not found in ~/.env"
        return 1
    fi

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
    # Check if litellm proxy is running
    if ! curl -s -o /dev/null -w "%{http_code}" http://localhost:11435/v1/models | grep -q "200\|401"; then
        echo "Error: litellm proxy not reachable at http://localhost:11435"
        echo "Start it with: litellm --model ollama/llama3 --port 11435"
        return 1
    fi

    echo "🏠 Starting Claude Code (Local Ollama via litellm)"

    env ANTHROPIC_BASE_URL="http://localhost:11435/v1" \
        ANTHROPIC_API_KEY="dummy" \
        claude
}

# 4. Home Ollama (remote, needs proxy setup)
claude-home() {
    # Check if home endpoint is reachable
    if ! curl -s -o /dev/null -w "%{http_code}" https://ollama.janvv.nl/v1/models | grep -q "200\|401"; then
        echo "Error: Home Ollama not reachable at https://ollama.janvv.nl"
        return 1
    fi

    echo "🏠 Starting Claude Code (Home Ollama)"

    env ANTHROPIC_BASE_URL="https://ollama.janvv.nl/v1" \
        ANTHROPIC_API_KEY="dummy" \
        claude
}
