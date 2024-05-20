# vscode internal shell breaks on Fedora when 'which' is a function
if [ "$(type -t which)" = "function" ]; then
       unset -f which
fi

if [ "$TERM_PROGRAM" = "vscode" ]; then
	export GIT_EDITOR="code --wait"
	alias vim=code
fi
