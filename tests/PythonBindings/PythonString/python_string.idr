import Python

%foreign "python: str.title"
title : StringUTF8 -> StringUTF8

testNoMemoryLeak : IO ()
testNoMemoryLeak = Prelude.putStrLn $ pendulumCast 100000000 "Memory leak test"
  where
    pendulumCast : Nat -> String -> String
    pendulumCast 0 s = s
    pendulumCast (S n) s = pendulumCast n $ fromUTF8 $ toUTF8 s

main : IO ()
main = do
    Python.print $ title "hello, world"
    Prelude.putStrLn $ fromUTF8 $ title "lorem, ipsum"

    testNoMemoryLeak
