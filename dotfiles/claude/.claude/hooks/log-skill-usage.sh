#!/bin/bash
# Log Claude skill invocations to ~/.local/share/claude/skill-usage.log

input=$(cat)
tool_name=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)

if [ "$tool_name" = "Skill" ]; then
    skill=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('skill',''))" 2>/dev/null)
    if [ -n "$skill" ]; then
        mkdir -p ~/.local/share/claude
        echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),$skill" >> ~/.local/share/claude/skill-usage.log
    fi
fi
