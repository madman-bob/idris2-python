module Python.PythonString

import Python.PythonObject

export
data StringUTF8 : Type where [external]

export
PrimPythonType StringUTF8 where

%foreign "python: bytes.decode"
prim__py_bytes_decode : String -> StringUTF8

%foreign "python: str.encode"
prim__py_str_encode : StringUTF8 -> String

export
toUTF8 : String -> StringUTF8
toUTF8 = prim__py_bytes_decode

export
fromUTF8 : StringUTF8 -> String
fromUTF8 = prim__py_str_encode

export
fromString : String -> StringUTF8
fromString = toUTF8

export
HasIO io => PythonType io String where
    toPy = toPy . toUTF8
