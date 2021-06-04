import ctypes
import pathlib

cdll = ctypes.CDLL(pathlib.Path(__file__).parent / "main.so")

cdll.main.argtypes = (ctypes.c_int, ctypes.POINTER(ctypes.c_char_p))
