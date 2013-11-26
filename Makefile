all:
	@echo $(shell pwd)
	@./build.sh

clean:
	@rm -f *.tar.gz *.changes *.dsc *.deb
