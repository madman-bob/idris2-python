import ctypes
import pathlib

from .idris2 import foreign_python, refc_types

cdll = ctypes.CDLL(pathlib.Path(__file__).parent / "main.so")

# Python doesn't seem to like casting typed pointers to void pointers, while
# the other way around is fine.
# So expect to see lots of void pointers where you'd expect to see Idris types

cdll.idris2_mkClosure.argtypes = (ctypes.c_void_p, ctypes.c_uint8, ctypes.c_uint8)
cdll.idris2_mkClosure.restype = ctypes.c_void_p

cdll.idris2_makeGCPointer.argtypes = (ctypes.py_object, ctypes.c_void_p)
cdll.idris2_makeGCPointer.restype = ctypes.c_void_p

cdll.idris2_newReference.argtypes = (ctypes.POINTER(refc_types.Value),)
cdll.idris2_newReference.restype = ctypes.POINTER(refc_types.Value)

cdll.idris2_removeReference.argtypes = (ctypes.POINTER(refc_types.Value),)
cdll.idris2_removeReference.restype = ctypes.c_void_p

cdll.idris2_apply_closure.argtypes = (ctypes.POINTER(refc_types.Value_Closure), ctypes.POINTER(refc_types.Value))
cdll.idris2_apply_closure.restype = ctypes.c_void_p

cdll.main.argtypes = (ctypes.c_int, ctypes.POINTER(ctypes.c_char_p))

foreign_python.cdll = cdll
