module Idris2PythonTests

import Test.Golden

idris2PythonTests : TestPool
idris2PythonTests = MkTestPool "Idris2Python" [] Nothing [
    "HelloWorld",
    "PythonFFI"
    ]

pythonBindingsTests : TestPool
pythonBindingsTests = MkTestPool "PythonBindings" [] Nothing [
    "Boolean",
    "Integer",
    "PythonClass",
    "PythonDict",
    "PythonFunction",
    "PythonList",
    "PythonString",
    "PythonTuple",
    "Unit"
    ]

main : IO ()
main = runner [
    testPaths "Idris2Python" idris2PythonTests,
    testPaths "PythonBindings" pythonBindingsTests
    ]
    where
        testPaths : String -> TestPool -> TestPool
        testPaths dir = record { testCases $= map ((dir ++ "/") ++) }
