import Python

main : IO ()
main = do
    Python.print False
    Python.print True

    Prelude.printLn !(isTruthy "")
    Prelude.printLn !(isTruthy "Hello, world")
