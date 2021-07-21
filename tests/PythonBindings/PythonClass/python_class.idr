import Python

%foreign "python: lambda: str"
py_str_class : PythonClass

main : IO ()
main = do
    Python.print !(subclass "MyString" [py_str_class] !PythonDict.empty)
