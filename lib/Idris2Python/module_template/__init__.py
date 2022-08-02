import ctypes
import pathlib

from .idris2 import foreign_python, refc_types

cdll = ctypes.CDLL(pathlib.Path(__file__).parent / "main.so")

# Python doesn't seem to like casting typed pointers to void pointers, while
# the other way around is fine.
# So expect to see lots of void pointers where you'd expect to see Idris types

cdll.newArglist.argtypes = (ctypes.c_int, ctypes.c_int)
cdll.newArglist.restype = ctypes.c_void_p

cdll.makeClosureFromArglist.argtypes = (refc_types.fun_ptr_t, ctypes.c_void_p)
cdll.makeClosureFromArglist.restype = ctypes.c_void_p

cdll.makeGCPointer.argtypes = (ctypes.py_object, ctypes.c_void_p)
cdll.makeGCPointer.restype = ctypes.c_void_p

cdll.makeWorld.argtypes = ()
cdll.makeWorld.restype = ctypes.POINTER(refc_types.Value_World)

cdll.newReference.argtypes = (ctypes.POINTER(refc_types.Value),)
cdll.newReference.restype = ctypes.POINTER(refc_types.Value)

cdll.removeReference.argtypes = (ctypes.POINTER(refc_types.Value),)
cdll.removeReference.restype = ctypes.POINTER(refc_types.Value)

cdll.apply_closure.argtypes = (ctypes.POINTER(refc_types.Value_Closure), ctypes.POINTER(refc_types.Value))
cdll.apply_closure.restype = ctypes.c_void_p

cdll.main.argtypes = (ctypes.c_int, ctypes.POINTER(ctypes.c_char_p))

foreign_python.cdll = cdll
