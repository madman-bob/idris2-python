module Idris2Python.PythonFFI

import Data.List

import Compiler.ANF
import Compiler.Common
import Compiler.CompileExpr

import Core.Name

import Compiler.RefC.RefC

public export
record PythonFFI where
    constructor MkPythonFFI
    pyModule : Maybe Namespace
    name : String
    argTypes : List CFType
    retType : CFType

export
pyFullName : PythonFFI -> String
pyFullName (MkPythonFFI pyModule name _ _) = show $ mkModuleIdent pyModule name

export
pythonFFIs : List (Name, ANFDef) -> List PythonFFI
pythonFFIs defs = do
    (_, MkAForeign ccs argTypes retType) <- defs
        | _ => []
    let Just (_, name :: opts) = parseCC ["python"] ccs
        | _ => []
    let pyModule = case opts of
            [] => Nothing
            (m :: _) => Just $ mkNamespace m
    pure $ MkPythonFFI pyModule name argTypes retType

ctypesTypeOfCFType : CFType -> String
ctypesTypeOfCFType CFUnit          = "ctypes.c_void_p"
ctypesTypeOfCFType CFInt           = "ctypes.c_int64"
ctypesTypeOfCFType CFInt8          = "ctypes.c_int8"
ctypesTypeOfCFType CFInt16         = "ctypes.c_int16"
ctypesTypeOfCFType CFInt32         = "ctypes.c_int32"
ctypesTypeOfCFType CFInt64         = "ctypes.c_int64"
ctypesTypeOfCFType CFUnsigned8     = "ctypes.c_uint8"
ctypesTypeOfCFType CFUnsigned16    = "ctypes.c_uint16"
ctypesTypeOfCFType CFUnsigned32    = "ctypes.c_uint32"
ctypesTypeOfCFType CFUnsigned64    = "ctypes.c_uint64"
ctypesTypeOfCFType CFString        = "ctypes.c_char_p"
ctypesTypeOfCFType CFDouble        = "ctypes.c_double"
ctypesTypeOfCFType CFChar          = "ctypes.c_char"
ctypesTypeOfCFType n = assert_total $ idris_crash ("INTERNAL ERROR: Unknown FFI type in Python backend: " ++ show n)

export
initFFIStub : PythonFFI -> String
initFFIStub pyFFI@(MkPythonFFI pyModule name argTypes (CFIORes retType)) = initFFIStub (MkPythonFFI pyModule name (concat $ init' argTypes) retType)
initFFIStub pyFFI@(MkPythonFFI pyModule name argTypes retType) = concat [
    "ctypes.c_void_p.in_dll(cdll, \"",
    cName (UN $ "python_" ++ name),
    "\").value = ctypes.cast(ctypes.CFUNCTYPE(",
    concat $ intersperse ", " $ map ctypesTypeOfCFType (retType :: argTypes),
    ")(",
    pyFullName pyFFI,
    "), ctypes.c_void_p).value"
    ]
