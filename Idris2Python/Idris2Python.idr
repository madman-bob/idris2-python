module Idris2Python

import Compiler.ANF
import Compiler.Common
import Compiler.RefC.CC
import Compiler.RefC.RefC

import Core.Context
import Core.Core
import Core.Directory
import Core.Options

import System
import System.File

import Idris.Driver
import Idris.Version
import Libraries.Utils.Path

generatePyInitFile : (filePath : String)
                  -> (cdllName : String)
                  -> Core (Maybe String)
generatePyInitFile filePath cdllName = do
    coreLift_ $ writeFile filePath $ "import ctypes\nimport pathlib\n\ncdll = ctypes.CDLL(pathlib.Path(__file__).parent / \"" ++ cdllName ++ "\")\n"
    pure $ Just filePath

generatePyMainFile : (filePath : String)
                  -> Core (Maybe String)
generatePyMainFile filePath = do
    coreLift_ $ writeFile filePath $ "from . import cdll\n\ncdll.main()\n"
    pure $ Just filePath

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

    _ <- generateCSourceFile defs cSourceFile
    _ <- compileCObjectFile {asLibrary = True} cSourceFile cObjectFile
    _ <- compileCFile {asShared = True} cObjectFile cSharedObjectFile

    let pyInitFilePath = outputModulePath </> "__init__.py"
    let pyMainFilePath = outputModulePath </> "__main__.py"

    _ <- generatePyInitFile pyInitFilePath "main.so"
    _ <- generatePyMainFile pyMainFilePath

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
