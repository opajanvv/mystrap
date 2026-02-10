# Claude Code wrapper functions
# Source this file from ~/.bashrc or ~/.zshrc

# GLM-4.7 via Z.ai proxy
claude-glm() {
    if [[ ! -f ~/.env ]]; then
        echo "Error: ~/.env file not found"
        return 1
    fi
    local ZAI_KEY
    ZAI_KEY=$(grep 'ZAI_PROXY_KEY' ~/.env | cut -d '"' -f 2)
    if [[ -z "$ZAI_KEY" ]]; then
        echo "Error: ZAI_PROXY_KEY not found in ~/.env"
        return 1
    fi

    env ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic" \
        ANTHROPIC_API_KEY="$ZAI_KEY" \
        claude --model glm-4.7 "$@"
}

# Ollama on laptop (local)
claude-local() {
    if ! curl -sf http://localhost:11434/v1/messages -o /dev/null 2>/dev/null; then
        echo "Error: Ollama not reachable at localhost:11434"
        echo "Start it with: ollama serve"
        return 1
    fi

    env ANTHROPIC_BASE_URL="http://localhost:11434" \
        ANTHROPIC_AUTH_TOKEN="ollama" \
        claude --model "${1:-qwen3-coder}" "${@:2}"
}

# Ollama on homelab server
claude-ollama() {
    if [[ ! -f ~/.config/ollama-api-key ]]; then
        echo "Error: ~/.config/ollama-api-key not found"
        echo "Create it with: echo 'your-key' > ~/.config/ollama-api-key && chmod 600 ~/.config/ollama-api-key"
        return 1
    fi
    local api_key
    api_key=$(<~/.config/ollama-api-key)

    env ANTHROPIC_BASE_URL="https://ollama.janvv.nl" \
        ANTHROPIC_AUTH_TOKEN="$api_key" \
        claude --model "${1:-qwen3-coder}" "${@:2}"
}
