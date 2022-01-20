module Python.PythonFunction

import Python.PythonObject

export
data PythonFunction : Type -> Type -> Type where [external]

export
PrimPythonType a => PythonType io b => PythonType io (PythonFunction a b) where
  toPy = pure . believe_me

%foreign "python: lambda f: lambda *args: f(args[0]) if len(args) == 1 else f(args[0])(*args[1:])"
prim__py_func_cast : (PythonObject -> PrimIO PythonObject) -> PrimIO (PythonFunction PythonObject PythonObject)

-- The Prelude function toPrim is linear, while we want unrestricted
-- This can be removed when linear subtyping reintroduced, or unrestricted version introduced into Prelude
export
toPrimIO : IO a -> PrimIO a
toPrimIO io world = toPrim io world

export
toPyFunc : PrimPythonType a => PythonType IO b => (a -> b) -> IO (PythonFunction a b)
toPyFunc f =
    map believe_me {a = PythonFunction PythonObject PythonObject} {b = PythonFunction a b} $
    primIO $
    prim__py_func_cast $
    toPrimIO . toPy . f . believe_me {a = PythonObject} {b = a}

export
PrimPythonType a => PythonType IO b => PythonType IO (a -> b) where
  toPy f = (toPyFunc $ toPrimIO . toPy . f) >>= toPy
