import Python

main : IO ()
main = do
    pyNone <- Python.print ()
    Python.print pyNone
