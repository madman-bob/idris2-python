module Python.PythonInteger

import Python.PythonObject

export
data PythonInteger : Type where [external]

export
PrimPythonType PythonInteger where

%foreign "python: lambda i: i"
prim__cast_to_py_int : Int -> PythonInteger

export
HasIO io => PythonType io Int where
    toPy = toPy . prim__cast_to_py_int
