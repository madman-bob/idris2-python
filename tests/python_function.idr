import Python

%foreign "python: lambda f: f(\"Called from within Python\")"
prim__py_call : (StringUTF8 -> PrimIO ()) -> PrimIO ()

python_call : (StringUTF8 -> IO ()) -> IO ()
python_call f = primIO $ prim__py_call $ toPrimIO . f

main : IO ()
main = do
    python_call Python.print

    Python.print (id {a = PythonObject})
