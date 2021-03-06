module Python

import public Python.PythonBool
import public Python.PythonClass
import public Python.PythonDict
import public Python.PythonFunction
import public Python.PythonInteger
import public Python.PythonList
import public Python.PythonObject
import public Python.PythonString
import public Python.PythonTuple
import public Python.PythonUnit

%foreign "python: print"
prim__py_print : PythonObject -> PrimIO ()

export
print : PythonType io a => a -> io ()
print x = primIO $ prim__py_print !(toPy x)
