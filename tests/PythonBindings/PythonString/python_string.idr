import Python

%foreign "python: str.title"
title : StringUTF8 -> StringUTF8

main : IO ()
main = do
    Python.print $ title "hello, world"
    Prelude.putStrLn $ fromUTF8 $ title "lorem, ipsum"
