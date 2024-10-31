"""
A Python representation of the C types used in the Idris 2 RefC backend

Python types representing C types representing Idris 2 types.

This file will need updating should the Idris 2 file /support/refc/_datatypes.h change.
"""

import ctypes

__all__ = [
    "NO_TAG",
    "BITS32_TAG",
    "BITS64_TAG",
    "INT32_TAG",
    "INT64_TAG",
    "INTEGER_TAG",
    "DOUBLE_TAG",
    "STRING_TAG",

    "CLOSURE_TAG",
    "CONSTRUCTOR_TAG",

    "IOREF_TAG",
    "ARRAY_TAG",
    "POINTER_TAG",
    "GC_POINTER_TAG",
    "BUFFER_TAG",

    "MUTEX_TAG",
    "CONDITION_TAG",

    "Value_header",
    "Value",
    "Value_Bits32",
    "Value_Bits64",
    "Value_Int32",
    "Value_Int64",
    "Value_Integer",
    "Value_Double",
    "Value_String",
    "Value_Constructor",
    "Value_Closure",
    "Value_IORef",
    "Value_Pointer",
    "Value_GCPointer",
    "Value_Array",
    "Buffer",
    "Value_Buffer",
    "Value_Mutex",
    "Value_Condition",
    "Value_World",
]

NO_TAG = 0
BITS32_TAG = 3
BITS64_TAG = 4
INT32_TAG = 7
INT64_TAG = 8
INTEGER_TAG = 9
DOUBLE_TAG = 10
STRING_TAG = 12

CLOSURE_TAG = 15
CONSTRUCTOR_TAG = 17

IOREF_TAG = 20
ARRAY_TAG = 21
POINTER_TAG = 22
GC_POINTER_TAG = 23
BUFFER_TAG = 24

MUTEX_TAG = 30
CONDITION_TAG = 31


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


class Value_Closure(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("f", ctypes.c_void_p),
        ("arity", ctypes.c_uint8),
        ("filled", ctypes.c_uint8),
        ("args", ctypes.POINTER(Value)),
    ]


class Value_IORef(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("v", ctypes.POINTER(Value)),
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


class Buffer(ctypes.Structure):
    _fields_ = [
        ("size", ctypes.c_int),
        ("data", ctypes.c_char_p)
    ]


class Value_Buffer(ctypes.Structure):
    _fields_ = [
        ("header", Value_header),
        ("buffer", Buffer),
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


# Not represented as a value in the C backend
# Used here as a tag to recognize when closures require an additional application
class Value_World(ctypes.Structure):
    _fields_ = []
