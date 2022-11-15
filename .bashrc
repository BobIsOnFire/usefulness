# .bashrc

# Source global definitions

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Tbricks binaries

export CUSTOM_BIN_PATH=$HOME/.local/bin:$HOME/.local/go/bin:$HOME/.cargo/bin
export PATH=$CUSTOM_BIN_PATH:$PATH

# vscode internal shell breaks on Fedora when 'which' is a function

if [ "$(type -t which)" = "function" ]; then
	unset -f which
fi

# vscode convenience

if [ "$TERM_PROGRAM" = "vscode" ]; then
	GIT_EDITOR="code --wait"
	alias vim=code
fi

# Phat phingers

alias gti="git"
alias hotp="htop"
alias ll="ls -alF"
alias where="which"
alias utop="htop -u $USER"

# Checking timestamps of files and directories

alias mtime="stat --printf '%Y %n\n'"
alias ctime="stat --printf '%Z %n\n'"
alias atime="stat --printf '%X %n\n'"
alias crtime="stat --printf '%W %n\n'"

# Additional environment from vcpkg and cargo

test -f "$HOME/vcpkg/scripts/vcpkg_completion.bash" && source "$HOME/vcpkg/scripts/vcpkg_completion.bash"
test -f "$HOME/.cargo/env" && source "$HOME/.cargo/env"

# Rusty tools!

export LS_COLORS=$($HOME/.cargo/bin/vivid generate molokai)
export BAT_THEME="Visual Studio Dark+"
alias ls="$HOME/.cargo/bin/exa"
alias du="$HOME/.cargo/bin/dust -rb"
alias cat="$HOME/.cargo/bin/bat -pp"
alias rg="$HOME/.cargo/bin/rg -uuu"

# Go

export GOPATH=$HOME/.local

# Cows and cats! And jumoreski!

print_jumoreski
function cowread {
	cat $@ | cowsay -f small-frogs | lolcat
}

# Custom shell prompt

source $HOME/prompt.sh
