import Python

%foreign "python: lambda f: f(\"Called from within Python\")"
prim__py_call : (StringUTF8 -> PrimIO ()) -> PrimIO ()

python_call : (StringUTF8 -> IO ()) -> IO ()
python_call f = primIO $ prim__py_call $ toPrimIO . f

%foreign "python: lambda f: f(*\"Multiple arg support\".split())"
prim__py_call_curried : (StringUTF8 -> StringUTF8 -> StringUTF8 -> PrimIO ()) -> PrimIO ()

python_call_curried : (StringUTF8 -> StringUTF8 -> StringUTF8 -> IO ()) -> IO ()
python_call_curried f = primIO $ prim__py_call_curried $ \x, y, z => toPrimIO (f x y z)

%foreign "python: lambda f: f(\"Called as Python function\")"
call_py_func : PythonFunction StringUTF8 StringUTF8 -> StringUTF8

%foreign "python: lambda: str.upper"
py_func : PythonFunction StringUTF8 StringUTF8

call_as_py_func : (StringUTF8 -> StringUTF8) -> IO StringUTF8
call_as_py_func = toPyFunc >=> (pure . call_py_func)

%foreign "python: lambda f: f(\"Called as Python object\")"
call_py_obj : PythonObject -> StringUTF8

%foreign "python: lambda: str.lower"
py_obj : PythonObject

call_as_py_obj : (StringUTF8 -> StringUTF8) -> IO StringUTF8
call_as_py_obj = toPy >=> (pure . call_py_obj)

%foreign "python: lambda f: f(*\"Some more args\".split())"
prim__py_call_py_obj_curried : PythonObject -> PrimIO ()

call_as_py_obj_curried : (StringUTF8 -> StringUTF8 -> StringUTF8 -> IO ()) -> IO ()
call_as_py_obj_curried f = primIO $ prim__py_call_py_obj_curried $ !(toPy $ \x, y, z => toPrimIO (f x y z))

print_three : StringUTF8 -> StringUTF8 -> StringUTF8 -> IO ()
print_three x y z = do
    Python.print x
    Python.print y
    Python.print z

main : IO ()
main = do
    python_call Python.print
    python_call_curried print_three

    Python.print $ call_py_func py_func
    Python.print !(call_as_py_func id)

    Python.print $ call_py_obj py_obj
    Python.print !(call_as_py_obj id)
    call_as_py_obj_curried print_three

    Python.print (id {a = PythonObject})
