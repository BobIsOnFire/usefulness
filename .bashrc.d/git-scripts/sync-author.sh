if [ "$GIT_COMMITTER_NAME" != "$GIT_AUTHOR_NAME" ]
then
    export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
fi
if [ "$GIT_COMMITTER_EMAIL" != "$GIT_AUTHOR_EMAIL" ]
then
    export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
fi
if [ "$GIT_COMMITTER_DATE" != "$GIT_AUTHOR_DATE" ]
then
    export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"
fi