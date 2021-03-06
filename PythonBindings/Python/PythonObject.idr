module Python.PythonObject

public export
interface PrimPythonType a where

export
data PythonObject : Type where [external]

export
PrimPythonType PythonObject where

public export
interface HasIO io => PythonType io a where
    toPy : a -> io PythonObject

export
HasIO io => PrimPythonType a => PythonType io a where
    toPy = pure . believe_me

export
PythonType io a => PythonType io (PrimIO a) where
    toPy = (liftIO . primIO) >=> toPy
