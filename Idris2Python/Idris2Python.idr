module Idris2Python

import Compiler.ANF
import Compiler.Common
import Compiler.RefC.CC
import Compiler.RefC.RefC

import Core.Context
import Core.Core
import Core.Directory

import System
import System.File

import Idris.Driver
import Libraries.Utils.Path

import Idris2Python.ModuleTemplate
import Idris2Python.PythonFFI

compile : Ref Ctxt Defs
       -> (tmpDir : String)
       -> (outputDir : String)
       -> ClosedTerm
       -> (outputModule : String)
       -> Core (Maybe String)
compile defs tmpDir outputDir term outputModule = do
    let outputModulePath = outputDir </> outputModule

    coreLift_ $ mkdirAll outputModulePath
    cdata <- getCompileData False ANF term
    let defs = anf cdata

    let cSourceFile = outputModulePath </> "main.c"
    let cObjectFile = outputModulePath </> "main.o"
    let cSharedObjectFile = outputModulePath </> "main.so"

    _ <- generateCSourceFile {additionalFFILangs = ["python"]} defs cSourceFile
    _ <- compileCObjectFile {asLibrary = True} cSourceFile cObjectFile
    _ <- compileCFile {asShared = True} cObjectFile cSharedObjectFile

    templatePyInitFilePath <- findLibraryFile "Idris2Python/module_template/__init__.py"
    templatePyMainFilePath <- findLibraryFile "Idris2Python/module_template/__main__.py"

    generatePyInitFile outputModulePath templatePyInitFilePath (pythonFFIs defs)
    Right _ <- coreLift $ copyFile templatePyMainFilePath outputModulePath
        | Left err => throw $ FileErr "Cannot create module __main__.py file" err

    pure $ Just outputModulePath

executePython : Ref Ctxt Defs -> String -> ClosedTerm -> Core ()
executePython defs tmpDir term = coreLift_ $ do
    putStrLn "Execute expression not yet implemented for the Python backend"
    system "false"

pythonCodegen : Codegen
pythonCodegen = MkCG compile executePython

export
main : IO ()
main = mainWithCodegens [("python", pythonCodegen)]
