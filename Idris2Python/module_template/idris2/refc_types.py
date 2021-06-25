"""
A Python representation of the C types used in the Idris 2 RefC backend

Python types representing C types representing Idris 2 types.

This file will need updating should the Idris 2 file /support/refc/datatypes.h change.
"""

import ctypes

__all__ = [
    "Value_header",
    "Value",
    "Value_Bits8",
    "Value_Bits16",
    "Value_Bits32",
    "Value_Bits64",
    "Value_Int8",
    "Value_Int16",
    "Value_Int32",
    "Value_Int64",
    "Value_Integer",
    "Value_Double",
    "Value_Char",
    "Value_String",
    "Value_Constructor",
    "Value_Arglist",
    "fun_ptr_t",
    "Value_Closure",
    "Value_IORef",
    "Value_Pointer",
    "Value_GCPointer",
    "Value_Array",
    "Value_Buffer",
    "Value_Mutex",
    "Value_Condition",
    "IORef_Storage",
    "Value_World",
]


class Value_header(ctypes.Structure):
    _fields_ = [
        ("refCounter", ctypes.c_int),
        ("tag", ctypes.c_int),
    ]


class Value(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("payload", ctypes.c_char * 25),
    ]


class Value_Bits8(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("ui8", ctypes.c_uint8),
    ]


class Value_Bits16(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("ui16", ctypes.c_uint16),
    ]


class Value_Bits32(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("ui32", ctypes.c_uint32),
    ]


class Value_Bits64(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("ui64", ctypes.c_uint64),
    ]


class Value_Int8(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("i8", ctypes.c_int8),
    ]


class Value_Int16(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("i16", ctypes.c_int16),
    ]


class Value_Int32(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("i32", ctypes.c_int32),
    ]


class Value_Int64(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("i64", ctypes.c_int64),
    ]


class Value_Integer(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("i", ctypes.c_void_p),  # mpz_t
    ]


class Value_Double(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("d", ctypes.c_double),
    ]


class Value_Char(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("c", ctypes.c_ubyte),
    ]


class Value_String(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("str", ctypes.c_char_p),
    ]


class Value_Constructor(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("total", ctypes.c_int32),
        ("tag", ctypes.c_int32),
        ("name", ctypes.c_char_p),
        ("args", ctypes.POINTER(ctypes.POINTER(Value))),
    ]


class Value_Arglist(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("total", ctypes.c_int32),
        ("filled", ctypes.c_int32),
        ("args", ctypes.POINTER(ctypes.POINTER(Value))),
    ]


# Return type is actually Value*, but Python doesn't like returning that
fun_ptr_t = ctypes.CFUNCTYPE(ctypes.c_void_p, ctypes.POINTER(Value_Arglist))


class Value_Closure(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("f", fun_ptr_t),
        ("arglist", ctypes.POINTER(Value_Arglist)),
    ]


class Value_IORef(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("index", ctypes.c_int32),
    ]


class Value_Pointer(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("p", ctypes.c_void_p),
    ]


class Value_GCPointer(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("p", ctypes.POINTER(Value_Pointer)),
        ("onCollectFct", ctypes.POINTER(Value_Closure)),
    ]


class Value_Array(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("capacity", ctypes.c_int),
        ("arr", ctypes.POINTER(ctypes.POINTER(Value))),
    ]


class Value_Buffer(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("len", ctypes.c_size_t),
        ("buffer", ctypes.c_char_p),
    ]


class Value_Mutex(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("mutex", ctypes.c_void_p),  # pthread_mutex_t*
    ]


class Value_Condition(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("cond", ctypes.c_void_p),  # pthread_cond_t*
    ]


class IORef_Storage(ctypes.Structure):
    _fields_ = [
        ("refs", ctypes.POINTER(ctypes.POINTER(Value))),
        ("filled", ctypes.c_int),
        ("total", ctypes.c_int),
    ]


class Value_World(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("listIORefs", ctypes.POINTER(IORef_Storage)),
    ]
