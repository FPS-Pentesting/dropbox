#!/bin/bash
# Sets up zsh history
# Commands are written immediately to disk, more commands are remember, and timestamps are added
# View full history with timestamps using this command: fc -li 0

# ==== Custom Zsh history config ====
mkdir -p /etc/zsh/zshrc.d/

cat <<'EOF' > /etc/zsh/zshrc.d/history-logging.zsh
HISTFILE=~/.zsh_history
# Store up to this number of commands in the memory buffer
HISTSIZE=100000

# Save up to 1 Billion commands on disk
SAVEHIST=1000000000

# don't log uninteresting commands
HISTORY_IGNORE="exit:clear:history"

# log timestamps
setopt EXTENDED_HISTORY

# write commands immediately to disk (in case NAB gets unplugged by client)
setopt INC_APPEND_HISTORY
EOF

# Ensure global zshrc sources this (only once)
if ! grep -q 'history-logging.zsh' /etc/zsh/zshrc; then
    echo 'source /etc/zsh/zshrc.d/history-logging.zsh' >> /etc/zsh/zshrc
fi
