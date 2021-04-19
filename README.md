# Idris2-Python

A Python backend for Idris 2.

## Installation

Install Idris 2 and the Idris 2 API, as per the [Idris intallation instructions](https://github.com/idris-lang/Idris2/blob/master/INSTALL.md).

Then build the `Idris2-Python` backend:
```bash
idris2 --build idris2-python.ipkg
```
This builds an executable `build/exec/idris2-python` that can be used to compile Idris 2 code into a Python module.

## Compile code

To compile Idris 2 code to a Python module, use `idris2-python` as you would `idris2` when [compiling with the standard backend](https://idris2.readthedocs.io/en/latest/backends/index.html).

eg.
```bash
./build/exec/idris2-python tests/hello_world.idr -o hello_world
```

This produces a Python module in `build/exec`.

## Run code

A Python module is a folder containing an `__init__.py` file.
Python modules are not referred to by path, instead by name.
Python searches for modules in the current directory (non-recursively), then in `$PYTHONPATH`, then installed modules.

The module created in the previous section can be run by temporarily adding your build directory to `$PYTHONPATH`.
```bash session
$ PYTHONPATH=build/exec python -m hello_world
Hello, world
```
