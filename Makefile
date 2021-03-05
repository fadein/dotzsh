DUMPS = $(addsuffix .zwc, $(filter-out %.zwc,$(wildcard fn_*)))
SHELL = zsh

all: $(DUMPS)

%.zwc: %
	zcompile -U $^ $^/*

clean:
	rm -f $(DUMPS)

.PHONY: all clean
