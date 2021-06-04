import ctypes
import pathlib

cdll = ctypes.CDLL(pathlib.Path(__file__).parent / "main.so")
