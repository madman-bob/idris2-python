module Python

import public Python.PythonBool
import public Python.PythonDict
import public Python.PythonList
import public Python.PythonObject
import public Python.PythonString
import public Python.PythonTuple

%foreign "python: print"
prim__py_print : PythonObject -> PrimIO ()

export
print : PythonType io a => a -> io ()
print x = primIO $ prim__py_print !(toPy x)
