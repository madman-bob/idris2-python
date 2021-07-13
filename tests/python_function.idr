import Python

%foreign "python: lambda f: f(\"Called from within Python\")"
prim__py_call : (StringUTF8 -> PrimIO ()) -> PrimIO ()

python_call : (StringUTF8 -> IO ()) -> IO ()
python_call f = primIO $ prim__py_call $ toPrimIO . f

%foreign "python: lambda f: f(*\"Multiple arg support\".split())"
prim__py_call_curried : (StringUTF8 -> StringUTF8 -> StringUTF8 -> PrimIO ()) -> PrimIO ()

python_call_curried : (StringUTF8 -> StringUTF8 -> StringUTF8 -> IO ()) -> IO ()
python_call_curried f = primIO $ prim__py_call_curried $ \x, y, z => toPrimIO (f x y z)

print_three : StringUTF8 -> StringUTF8 -> StringUTF8 -> IO ()
print_three x y z = do
    Python.print x
    Python.print y
    Python.print z

main : IO ()
main = do
    python_call Python.print
    python_call_curried print_three

    Python.print (id {a = PythonObject})
