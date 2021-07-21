import Python

main : IO ()
main = do
    Python.print !(pyToTuple !(toPyList ["Hello", "world"]))
