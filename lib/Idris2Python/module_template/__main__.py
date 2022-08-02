import ctypes
import sys

from . import cdll

argc = len(sys.argv)
argv = (ctypes.c_char_p * argc)(*map(str.encode, sys.argv))

cdll.main(argc, argv)
