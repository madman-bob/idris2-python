import Python

%foreign "python: abs"
abs : Int -> Int

%foreign "python: gcd, math"
gcd : Int -> Int -> Int

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
    python_call Python.print
