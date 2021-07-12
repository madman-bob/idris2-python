module Python.PythonClass

import Python.PythonObject
import Python.PythonDict
import Python.PythonList
import Python.PythonString
import Python.PythonTuple

export
data PythonClass : Type where [external]

export
PrimPythonType PythonClass where

%foreign "python: type"
prim__py_subclass : StringUTF8 -> PythonTuple -> PythonDict -> PrimIO PythonClass

export
subclass : HasIO io
        => StringUTF8
        -> List PythonClass
        -> PythonDict
        -> io PythonClass
subclass name parents fields = primIO $ prim__py_subclass name !(pyToTuple !(toPyList parents)) fields
