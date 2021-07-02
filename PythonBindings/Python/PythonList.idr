module Python.PythonList

import Python.PythonObject

export
data PythonList : Type where [external]

export
PrimPythonType PythonList where

%foreign "python: list"
prim__py_list : PrimIO PythonList

export
empty : HasIO io => io PythonList
empty = primIO prim__py_list

%foreign "python: list.append"
prim__py_list_append : PythonList -> PythonObject -> PrimIO ()

export
append : PythonType io a => PythonList -> a -> io ()
append l o = primIO $ prim__py_list_append l !(toPy o)

%foreign "python: list.reverse"
prim__py_list_reverse : PythonList -> PrimIO ()

export
reverse : HasIO io => PythonList -> io ()
reverse = primIO . prim__py_list_reverse

export
toPyList : PythonType io a => List a -> io PythonList
toPyList xs = do
    l <- toPyList' xs
    reverse l
    pure l
  where
    toPyList' : List a -> io PythonList
    toPyList' [] = empty
    toPyList' (x :: xs) = do
        l <- toPyList' xs
        append l x
        pure l

export
PythonType io a => PythonType io (List a) where
    toPy = toPyList >=> toPy
