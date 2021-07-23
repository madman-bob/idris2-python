.PHONY: idris2-python python-bindings install test retest clean

idris2-python: build/exec/idris2-python

build/exec/idris2-python: idris2-python.ipkg Idris2Python/* Idris2Python/*/* Idris2Python/*/*/*
	idris2 --build idris2-python.ipkg

python-bindings: build/ttc/Python.ttc

build/ttc/Python.ttc: python-bindings.ipkg PythonBindings/* PythonBindings/*/*
	idris2 --install python-bindings.ipkg

install: idris2-python python-bindings

test:
	make -C tests test

retest:
	make -C tests retest

clean:
	rm -rf build
