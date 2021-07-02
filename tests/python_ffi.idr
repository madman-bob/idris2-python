%foreign "python: abs"
abs : Int -> Int

%foreign "python: gcd, math"
gcd : Int -> Int -> Int

data StringUTF8 : Type where [external]

%foreign "python: bytes.decode"
asUTF8 : String -> StringUTF8

%foreign "python: str.title"
title : StringUTF8 -> StringUTF8

%foreign "python: print"
prim__python_print : StringUTF8 -> PrimIO ()

python_print : HasIO io => StringUTF8 -> io ()
python_print = primIO . prim__python_print

data PythonUTF8Iterable : Type where [external]

%foreign "python: list"
prim__python_explode : StringUTF8 -> PrimIO PythonUTF8Iterable

python_explode : HasIO io => StringUTF8 -> io PythonUTF8Iterable
python_explode = primIO . prim__python_explode

%foreign "python: map"
prim__python_map : (StringUTF8 -> StringUTF8) -> PythonUTF8Iterable -> PrimIO PythonUTF8Iterable

python_map : HasIO io => (StringUTF8 -> StringUTF8) -> PythonUTF8Iterable -> io PythonUTF8Iterable
python_map f xs = primIO $ prim__python_map f xs

%foreign "python: \"\".join"
prim__python_concat : PythonUTF8Iterable -> PrimIO StringUTF8

python_concat : HasIO io => PythonUTF8Iterable -> io StringUTF8
python_concat = primIO . prim__python_concat

%foreign "python: lambda f: f(\"Called from within Python\")"
prim__python_call : (StringUTF8 -> PrimIO ()) -> PrimIO ()

toPrimIO : IO a -> PrimIO a
toPrimIO io world = toPrim io world

python_call : (StringUTF8 -> IO ()) -> IO ()
python_call f = primIO $ prim__python_call $ toPrimIO . f

main : IO ()
main = do
    putStrLn $ show $ abs $ -1
    putStrLn $ show $ gcd 4 6
    python_print $ title $ asUTF8 "hello, world"
    python_print !(python_concat !(python_map title !(python_explode $ asUTF8 "hello, world")))
    python_call python_print
