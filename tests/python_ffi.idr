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

main : IO ()
main = do
    putStrLn $ show $ abs $ -1
    putStrLn $ show $ gcd 4 6
    python_print $ title $ asUTF8 "hello, world"
