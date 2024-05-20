FILES := .bashrc .gitconfig .vimrc
FILES += $(wildcard .bashrc.d/*.sh)
FILES += $(wildcard .bashrc.d/git-scripts/*.sh)

.PHONY: all
.SUFFIXES:

all: $(patsubst %,$(HOME)/%,$(FILES))

$(HOME)/%: % | $(dir $(HOME)/%)
	@if [ -f $@.old ]; then echo '$@.old still exists, remove it and run make again'; false; fi  
	cp $@ $@.old
	cp $< $@
	@if cmp -s $@ $@.old; then rm $@.old; fi

$(HOME) $(HOME)/.bashrc.d $(HOME)/.bashrc.d/git-scripts:
	mkdir -p $@

