#!/bin/bash

### git-log wrapper that adds hyperlinks to Jira issues, commits and PRs in its output.
### Usage: same arguments as 'git log' command.
### Create alias via `git config --global alias.ulog '!/path/to/gitlog-with-urls.sh'`
###
### Config options:
### * ulog.jiraUrl -- generate links to Jira cases based on this URL.
###   Can also be overriden via GIT_ULOG_JIRA_URL env variable.

# fd is the descriptor where output should be written (e.g. 1 for stdout)
# TERM heuristic is not good, but it is still enough to remove some really unsupported variants like PuTTY.
# Inspired by: https://github.com/gcc-mirror/gcc/commit/458c8d6459c4005fc9886b6e25d168a6535ac415
supports_ansi_links() {
    local fd=$1
    test -t "${fd}" && test "${TERM}" == "xterm-256color"
}

# https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
# Returns search-and-replace pattern ready to be supplied into GNU sed -E
make_ansi_link_regex() {
    local match=$1
    local link=$2

    local osc=$'\e]8' # Control sequence for the URL command
    local nul=$'\e\\\\' # String terminator in the command ('\' is escaped for sed)

    local link_escaped=${link//\//\\/} # escape all forward slashes in the link (looks like random slashes though lmao)
    local ansi_link="${osc};;${link_escaped}${nul}&${osc};;${nul}"

    # TODO: do not create link if /${match}/ is already a part of URL (requires lookahead, so has to be in Perl/Python i guess...)
    echo "s/${match}/${ansi_link}/g"
}

# Include some useful shell commands: https://git-scm.com/docs/git-sh-setup
NONGIT_OK=1 # otherwise next line fails if we're not in top-level git dir (why)
. "$(git --exec-path)/git-sh-setup"

# If we don't write to terminal that supports URLs, drop the wrapper and pass
# execution to git-log proper
if ! supports_ansi_links 1; then
    exec git log "$@"
fi

# From git-sh-setup -- fail if we're not in git tree
require_work_tree

# If pager is 'less', add '-r' so that it doesn't post-process escape sequences
# A little scary if someone puts other escape sequences in commit message, but that's so unlikely
GIT_PAGER=$(git var GIT_PAGER)
if [[ "${GIT_PAGER}" =~ less ]]; then
    GIT_PAGER="${GIT_PAGER} -r"
fi
export GIT_PAGER

if [ ${GIT_ULOG_JIRA_URL} ]; then
    jira_url=${GIT_ULOG_JIRA_URL}
elif git config --get ulog.jiraUrl; then
    jira_url=$(git config --get ulog.jiraUrl)
fi
test ${jira_url} && jira_case_link_regex=$(make_ansi_link_regex "([A-Z]+-[0-9]+)" "${jira_url}/browse/\\1")

git_commit_link_regex=
git_pr_link_regex=

# Remote called 'origin' should take priority over everything else
all_remotes=$( (git remote -v | grep -w origin; git remote -v) | awk '{print $2}')
# Browse through remotes, try to figure out what web link we can generate for commits/PRs
for remote in ${all_remotes}; do
    # The script supports two forms of remotes:
    # 1. <protocol>://[<creds>@]<server>/<path-to-repo>/<repo>[/]
    remote_old_regex='^[^:]+://([^/]*@)?([^/]+)/(.+)/([^/]+)/?$'
    # 2. [<creds>@]<server>:<path-to-repo>/<repo>[/]
    remote_new_regex='^([^:]*@)?([^:]+):(.+)/([^/]+)/?$'

    # Transform to lowercase before matching
    remote=${remote,,}
    if [[ "${remote}" =~ ${remote_old_regex} || "${remote}" =~ ${remote_new_regex} ]]; then
        server=${BASH_REMATCH[2]}
        path=${BASH_REMATCH[3]}
        repo=${BASH_REMATCH[4]}

        # Some heuristics to figure out what kind of git server host this is
        case ${server} in
            # Atlassian BitBucket
            *stash*|*bitbucket*)
                path=${path#scm/}
                repo=${repo%.git}
                commit_url="https://${server}/projects/${path}/repos/${repo}/commits/\\1"
                git_pr_link_regex=$(make_ansi_link_regex "#([0-9]+)" "https://${server}/projects/${path}/repos/${repo}/pull-requests/\\1")
                ;;
            # GitHub
            *github*)
                repo=${repo%.git}
                commit_url="https://${server}/${path}/${repo}/commit/\\1"
                git_pr_link_regex=$(make_ansi_link_regex "#([0-9]+)" "https://${server}/${path}/${repo}/pull/\\1")
                ;;
            # GitLab
            *gitlab*)
                repo=${repo%.git}
                commit_url="https://${server}/${path}/${repo}/-/commit/\\1"
                git_pr_link_regex=$(make_ansi_link_regex "!([0-9]+)" "https://${server}/${path}/${repo}/-/merge_requests/\\1")
                ;;
            # Assume it's just a GitWeb host (https://git-scm.com/book/en/v2/Git-on-the-Server-GitWeb)
            *)
                commit_url="https://${server}/${path}/${repo}/commit/?id=\\1"
        esac

        git_commit_link_regex=$(make_ansi_link_regex "([0-9a-f]{7,40})" "${commit_url}")

        break
    fi
done

sed_args=('-E')
test "${jira_case_link_regex}" && sed_args+=('-e' "${jira_case_link_regex}")
test "${git_commit_link_regex}" && sed_args+=('-e' "${git_commit_link_regex}")
test "${git_pr_link_regex}" && sed_args+=('-e' "${git_pr_link_regex}")

# git_pager command is from git-sh-setup, it expands to logical GIT_PAGER or 'cat' if pager is not needed or explicitly ignored
git log --color=always --decorate "$@" | sed "${sed_args[@]}" | git_pager
