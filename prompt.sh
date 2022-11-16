##### Custom shell prompt.

# Color scheme. Current scheme matches the ones in vivid 'molokai' theme.

color_ok="0 255 135"
color_fail="255 74 68"
color_faded="122 112 112"

color_diff_noaction="0 255 135"
color_diff_detached="182 182 182"
color_diff_behind="226 209 57"
color_diff_ahead="253 151 31"
color_diff_diverged="249 38 114"

color_repo="102 217 239"
color_path="102 217 239"

# Escape sequence generators.

function bold {	echo -n "\e[1m"; }
function nobold {	echo -n "\e[22m"; }
function reset { echo -n "\e[m"; }
function fgcolor { echo -n "\e[38;2;${1};${2};${3}m"; }
function bgcolor { echo -n "\e[48;2;${1};${2};${3}m"; }
# $1 - decorators (e.g. "$(bold && fgcolor $color_ok)"), $2 - text
function decorate { echo "${1}${2}$(reset)"; }

# Process timer.

function process_timer_start {
	exec_start=${exec_start:-$(date +%s.%N)}
}

function process_timer_stop {
	exec_end=$(date +%s.%N)
	exec_time=$(format_duration $(echo "${exec_end} - ${exec_start}" | bc))
	unset exec_start
	unset exec_end
}

function format_duration {
	# Trim fractions of seconds
	secs=$(echo "$1 / 1" | bc)

	# Round fractions to three digits
	fracs=$(echo "scale=3;($1 - $secs)/1" | bc)
	test "${fracs}" = "0" && unset fracs

	days=$(( secs/60/60/24 ))
	hrs=$(( secs/60/60%24 ))
	mins=$(( secs/60%60 ))
	secs=$(( secs%60 ))

	test $days -gt 0 && echo -n "${days}d"
	test $hrs  -gt 0 && echo -n "${hrs}h"
	test $mins -gt 0 && echo -n "${mins}m"
	echo "${secs}${fracs}s"
}

# Git repository information extractors.

function git_repo {
	remote=$(git remote -v)
	if [ -z "$remote" ]; then
		echo "(no remote)"
	else
		echo $remote | awk 'NR==1{print $2}' |
			sed -r -e 's^(ftp|ssh|https?)://^^' -e 's^git@^^' -e 's^\.git$^^' |
			sed -r -e 's^github\.com^github^' |
			sed -r -e 's^\.?orcsoftware\.com^^' |
			sed -r -e 's^\.?itiviti\.com^^'
	fi
}

function git_reference {
	ref=$(git branch --show-current)
	if [ -z "$ref" ]; then
		ref="$(git rev-parse --short @)"
	fi

	echo "$ref"
}

function git_remote_diff {
	local=$(git rev-parse @ 2>/dev/null)
	if [ "$local" = "@" ]; then
		echo $(decorate "$(fgcolor ${color_diff_noaction})" "[no commits yet]")
		return
	fi

	remote=$(git rev-parse @{u} 2>/dev/null)
	base=$(git merge-base @ @{u} 2>/dev/null)

	if [ "$(git rev-parse --abbrev-ref @)" == "HEAD" ]; then
		color=$(fgcolor ${color_diff_detached})
		msg="detached"
	elif [ -z "$remote" ] || [ "$remote" = "@{u}" ]; then
		color=$(fgcolor ${color_diff_noaction})
		msg="no upstream"
	elif [ "$local" = "$remote" ]; then
		color=$(fgcolor ${color_diff_noaction})
		msg="up-to-date"
	elif [ "$local" = "$base" ]; then
		color=$(bold && fgcolor ${color_diff_behind})
		msg="behind"
	elif [ "$remote" = "$base" ]; then
		color=$(bold && fgcolor ${color_diff_ahead})
		msg="ahead"
	else
		color=$(bold && fgcolor ${color_diff_diverged})
		msg="diverged"
	fi

	echo "$(decorate "${color}" "[${msg}]")"
}

# Actual prompt generator.

function ps1_is_on_fire {
	# Collect info about previous process before doing anything.
	rc=$?
	process_timer_stop

	# Someone just modified PS1: fine, but do not put anything before the '┗━ ' prompt
	if [ "$PS1" != "┗━ " ]; then
		PS1=$(echo "$PS1" | sed -r 's|^(.*)(┗━ )(.*)$|\2\1\3|' )
	fi

	### A dashboard of different information about the system.

	# 1. Info about previous process 
	if test $rc -eq 0 ; then exec_color="$color_ok"; else exec_color="$color_fail"; fi
	exec_status=$(decorate "$(fgcolor ${exec_color})" "rc:$(bold)${rc}$(nobold) time:$(bold)${exec_time}$(nobold)")

	# 2. Abbreviated hostname (or a custom value - use PROMPT_HOSTNAME)
	system_host=${PROMPT_HOSTNAME:-$(hostname | sed -r 's|\..*||')}

	# 3. Time
	system_time=$(date +%T)

	# 4. Git status
	unset git_status
	if git rev-parse --git-dir &>/dev/null; then
		repo=$(decorate "$(fgcolor ${color_repo})" "$(git_repo)@$(git_reference)")
		rdiff=$(git_remote_diff)
		git_status="${repo} ${rdiff}"
	fi

	# Construct dashboard.

	ps1_dashboard="${exec_status} • ${system_host} • ${system_time}"
	test ! -z "${git_status}" && ps1_dashboard+=" • ${git_status}"

	### CWD

	cwd=$(decorate "$(fgcolor ${color_path})" "${PWD/#${HOME}/\~}/")

	### Construct PS1, finally.

	echo
	echo -e "┏━ ${ps1_dashboard}"
	echo -e "┃  ${cwd}"
}

trap 'process_timer_start' DEBUG

export PS1="┗━ "
export PS2="\[\e[A\]┃  \n┗━ "

export PROMPT_COMMAND=ps1_is_on_fire
