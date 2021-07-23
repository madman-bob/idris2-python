# Idris2-Python

A Python backend for Idris 2.

## Prerequisites

- Idris 2 and the Idris 2 API, as per the [Idris installation instructions](https://github.com/idris-lang/Idris2/blob/master/INSTALL.md).
  
- A C compiler, and the `gmp` library.

  These can be installed by:

  ```bash
  sudo apt-get install gcc
  sudo apt-get install libgmp3-dev
  ```

- If using Python 3.6, you'll need to manually install `dataclasses`.

  ```bash
  pip3 install dataclasses
  ```

## Installation

To build the `Idris2-Python` backend, and install the `Python` Idris library, run:
```bash
make install
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

## Python FFIs

You can use both C and [Python](#python-ffis) FFIs in your Idris 2 code when compiling to Python.
For convenience, a bindings library is provided for some Python builtins.

Python FFIs may be declared with the `%foreign` directive, using the format `"python: func, module"` for a Python function `func` in module `module`.
For builtins, omit the module.

For example,
```idris2
%foreign "python: abs"
abs : Int -> Int
```
and
```idris2
%foreign "python: floor, math"
floor : Int -> Int
```

The Python builtins bindings may be accessed by importing the module `Python`.

For example,
```idris2
import Python

main : IO ()
main = do
    l <- PythonList.empty

    append l "Orange"
    append l "Apple"

    print l
```
