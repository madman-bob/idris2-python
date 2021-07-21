INTERACTIVE ?= --interactive
threads ?= $(shell (nproc || sysctl -n hw.ncpu) 2>/dev/null || echo 1)

.PHONY: test retest clean

test: build/exec/idris2-python-tests
	./build/exec/idris2-python-tests $(INTERACTIVE) --timing --failure-file failures --threads $(threads) --only $(only)

retest: build/exec/idris2-python-tests
	./build/exec/idris2-python-tests $(INTERACTIVE) --timing --failure-file failures --threads $(threads) --only-file failures --only $(only)

build/exec/idris2-python-tests: idris2-python-tests.ipkg Idris2PythonTests.idr
	idris2 --build idris2-python-tests.ipkg

clean:
	$(RM) failures
	$(RM) -r build
	$(RM) -r **/**/build
	@find . -type f -name 'output' -exec rm -rf {} \;
	@find . -type f -name '*.ttc' -exec rm -f {} \;
	@find . -type f -name '*.ttm' -exec rm -f {} \;
	@find . -type f -name '*.ibc' -exec rm -f {} \;
