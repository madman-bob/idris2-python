module Python.PythonBool

import Python.PythonObject

export
data PythonBool : Type where [external]

export
PrimPythonType PythonBool where

%foreign "python: lambda: False"
prim__py_false : PythonBool

%foreign "python: lambda: True"
prim__py_true : PythonBool

export
HasIO io => PythonType io Bool where
    toPy False = toPy prim__py_false
    toPy True = toPy prim__py_true

%foreign "python: lambda *args: args.__getitem__(1) if args.__getitem__(0) else args.__getitem__(2)"
prim__py_iif : PythonObject -> Int -> Int -> PrimIO Int

export
isTruthy : PythonType io a => a -> io Bool
isTruthy x = map (== 1) $ primIO $ prim__py_iif !(toPy x) 1 0
