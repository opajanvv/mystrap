# Bash configuration
# TODO: Add your Bash configuration here

# Source aliases
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# Enable starship prompt if available
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

