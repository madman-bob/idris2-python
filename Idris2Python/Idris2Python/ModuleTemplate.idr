module Idris2Python.ModuleTemplate

import Data.List
import Data.String

import Core.Core
import Core.Name

import System.File

import Libraries.Data.SortedSet
import Libraries.Utils.Path

import Idris2Python.PythonFFI

unique : Ord a => List a -> List a
unique = SortedSet.toList . fromList

export
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

export
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