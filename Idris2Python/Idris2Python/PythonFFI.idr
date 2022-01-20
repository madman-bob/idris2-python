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
    name : Name
    pyModule : Maybe Namespace
    pyDef : String
    argTypes : List CFType
    retType : CFType

export
pyFullDef : PythonFFI -> String
pyFullDef (MkPythonFFI _ pyModule pyDef _ _) = show $ mkModuleIdent pyModule pyDef

export
pythonFFIs : List (Name, ANFDef) -> List PythonFFI
pythonFFIs defs = do
    (name, MkAForeign ccs argTypes retType) <- defs
        | _ => []
    let Just (_, pyDef :: opts) = parseCC ["python"] ccs
        | _ => []
    let pyModule = case opts of
            [] => Nothing
            (m :: _) => Just $ mkNamespace m
    pure $ MkPythonFFI name pyModule pyDef argTypes retType

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
ctypesTypeOfCFType CFWorld         = "ctypes.POINTER(refc_types.Value_World)"
ctypesTypeOfCFType (CFFun args rt) = concat [
    "ctypes.CFUNCTYPE(",
    ctypesTypeOfCFType rt,
    ", ",
    ctypesTypeOfCFType args,
    ")"
    ]
ctypesTypeOfCFType (CFIORes t)     = ctypesTypeOfCFType t
ctypesTypeOfCFType (CFUser n args) = "ctypes.py_object"
ctypesTypeOfCFType n = assert_total $ idris_crash ("INTERNAL ERROR: Unknown FFI type in Python backend: " ++ show n)

export
initFFIStub : PythonFFI -> String
initFFIStub pyFFI@(MkPythonFFI name pyModule pyDef argTypes (CFIORes retType)) = initFFIStub (MkPythonFFI name pyModule pyDef (concat $ init' argTypes) retType)
initFFIStub pyFFI@(MkPythonFFI name pyModule pyDef argTypes retType) = concat [
    "foreign_python.register_py_func(\"",
    cName $ NS (mkNamespace "python") name,
    "\", ",
    pyFullDef pyFFI,
    ", ",
    concat $ intersperse ", " $ map ctypesTypeOfCFType (retType :: argTypes),
    ")"
    ]
