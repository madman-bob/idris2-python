import Python

%foreign "python: str.title"
title : StringUTF8 -> StringUTF8

data PythonUTF8Iterable : Type where [external]

PrimPythonType PythonUTF8Iterable where

%foreign "python: (list)"
prim__py_explode : StringUTF8 -> PrimIO PythonUTF8Iterable

explode : HasIO io => StringUTF8 -> io PythonUTF8Iterable
explode = primIO . prim__py_explode

%foreign "python: map"
prim__py_map : (StringUTF8 -> StringUTF8) -> PythonUTF8Iterable -> PrimIO PythonUTF8Iterable

map : HasIO io => (StringUTF8 -> StringUTF8) -> PythonUTF8Iterable -> io PythonUTF8Iterable
map f xs = primIO $ prim__py_map f xs

%foreign "python: \"\".join"
prim__py_concat : PythonUTF8Iterable -> PrimIO StringUTF8

concat : HasIO io => PythonUTF8Iterable -> io StringUTF8
concat = primIO . prim__py_concat

main : IO ()
main = do
    l <- PythonList.empty
    Python.print l

    append l "Orange"
    append l "Apple"
    Python.print l

    reverse l
    Python.print l

    Python.print !(toPyList ["Pear", "Banana"])
    Python.print $ the (List String) ["Kiwi", "Apple"]

    Python.print !(concat !(map title !(explode "hello, world")))
