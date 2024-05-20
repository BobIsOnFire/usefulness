# Rusty tools!

test -f "$HOME/.cargo/env" && source "$HOME/.cargo/env"

export LS_COLORS=$($HOME/.cargo/bin/vivid generate molokai)
export BAT_THEME="Visual Studio Dark+"
alias ls="$HOME/.cargo/bin/exa"
alias du="$HOME/.cargo/bin/dust -rb"
alias cat="$HOME/.cargo/bin/bat -pp"
alias rg="$HOME/.cargo/bin/rg -uuu"

# Go

export GOPATH=$HOME/.local
