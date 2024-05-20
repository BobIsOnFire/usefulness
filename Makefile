FILES := .bashrc .gitconfig .vimrc
FILES += $(wildcard .bashrc.d/*.sh)
FILES += $(wildcard .bashrc.d/git-scripts/*.sh)

.PHONY: all
.SUFFIXES:

all: $(patsubst %,$(HOME)/%,$(FILES))

$(HOME)/%: %
	@if [ -f $@.old ]; then echo '$@.old still exists, remove it and run make again'; false; fi  
	mkdir -p $(@D)
	if [ -f $@ ]; then cp $@ $@.old; fi
	cp $< $@
	@if cmp -s $@ $@.old; then rm $@.old; fi
