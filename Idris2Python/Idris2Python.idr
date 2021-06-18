module Idris2Python

import Data.List
import Data.String

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
import Libraries.Data.SortedSet
import Libraries.Utils.Path

import Idris2Python.PythonFFI

unique : Ord a => List a -> List a
unique = SortedSet.toList . fromList

copyFile : HasIO io
        => (sourcePath : String)
        -> (targetDirectory : String)
        -> io (Either FileError String)
copyFile sourcePath targetDirectory = do
    let Just targetName = fileName sourcePath
        | Nothing => pure $ Left FileNotFound
    let targetPath = targetDirectory </> targetName
    Right fileContents <- readFile sourcePath
        | Left err => pure $ Left err
    Right () <- writeFile targetPath fileContents
        | Left err => pure $ Left err
    pure $ Right targetPath

appendFile : HasIO io
          => (filePath : String)
          -> (additionalContents : String)
          -> io (Either FileError ())
appendFile filePath additionalContents =
    withFile filePath Append pure (flip fPutStrLn additionalContents)

generatePyInitFile : (outputModulePath : String)
                  -> (templatePyInitFilePath : String)
                  -> (pyFFIs : List PythonFFI)
                  -> Core ()
generatePyInitFile outputModulePath templatePyInitFilePath pyFFIs = do
    let pyFFIImports = map ("import " ++) $ unique $ map show $ catMaybes $ map pyModule pyFFIs
    let pyFFIStubInits = map initFFIStub pyFFIs

    Right pyInitFilePath <- coreLift $ copyFile templatePyInitFilePath outputModulePath
        | Left err => throw $ FileErr "Cannot create module __init__.py file" err
    Right () <- coreLift $ appendFile pyInitFilePath $ unlines $
            [""] ++ pyFFIImports ++ [""] ++ pyFFIStubInits
        | Left err => throw $ FileErr "Cannot reify __init__.py template file" err

    pure ()

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
