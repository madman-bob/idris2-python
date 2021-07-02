module Python.PythonTuple

import Python.PythonList
import Python.PythonObject

export
data PythonTuple : Type where [external]

export
PrimPythonType PythonTuple where

%foreign "python: tuple"
prim__py_tuple : PythonList -> PrimIO PythonTuple

export
pyToTuple : HasIO io => PythonList -> io PythonTuple
pyToTuple = primIO . prim__py_tuple
