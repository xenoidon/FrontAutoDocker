SHELL := /bin/bash

all: update.o build.o clear.o
update.o:
	$(SHELL) update
build.o:
	$(SHELL) up
clear.o:
	$(SHELL) clear
