import Python

main : IO ()
main = do
    d <- PythonDict.empty
    Python.print d

    setItem d "name" "Lancelot"
    setItem d "quest" "The Holy Grail"
    Python.print d

    Python.print !(getItem d "quest" "The Messiah")
    Python.print !(getItem d "favorite color" "Blue")

    Python.print !(toPyDict [
        ("name", "Brian"),
        ("quest", "A peaceful life")
    ])
