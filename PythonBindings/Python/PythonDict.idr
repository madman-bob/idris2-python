module Python.PythonDict

import public Data.List.Quantifiers

import Python.PythonList
import Python.PythonObject
import Python.PythonString

export
data PythonDict : Type where [external]

export
PrimPythonType PythonDict where

%foreign "python: dict"
prim__py_dict : PythonList -> PrimIO PythonDict

export
pyToDict : HasIO io => PythonList -> io PythonDict
pyToDict = primIO . prim__py_dict

export
empty : HasIO io => io PythonDict
empty = pyToDict !empty

%foreign "python: dict.get"
prim__py_dict_get_item : PythonDict -> StringUTF8 -> PythonObject -> PrimIO PythonObject

export
getItem : PythonType io a => PythonDict -> StringUTF8 -> a -> io PythonObject
getItem d k fallback = primIO $ prim__py_dict_get_item d k !(toPy fallback)

%foreign "python: dict.__setitem__"
prim__py_dict_set_item : PythonDict -> StringUTF8 -> PythonObject -> PrimIO ()

export
setItem : PythonType io a => PythonDict -> StringUTF8 -> a -> io ()
setItem d k v = primIO $ prim__py_dict_set_item d k !(toPy v)

export
extend : HasIO io
      => All (PythonType io) types
      => PythonDict
      -> All (Pair StringUTF8) types
      -> io ()
extend d [] = pure ()
extend @{io} @{pt :: pts} d ((k, v) :: rest) = do
    setItem d k v
    extend d rest

export
toPyDict : HasIO io
        => All (PythonType io) types
        => All (Pair StringUTF8) types
        -> io PythonDict
toPyDict xs = do
    d <- empty
    extend d xs
    pure d
