if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

BASHRC_DIR=$(dirname "${BASH_SOURCE[0]}")
for f in ${BASHRC_DIR}/.bashrc.d/*.sh; do
    [ -f $f ] && . $f
done
