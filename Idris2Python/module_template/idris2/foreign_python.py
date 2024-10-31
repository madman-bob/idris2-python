from ctypes import CFUNCTYPE, POINTER, c_char_p, c_void_p, cast, py_object, pythonapi
from dataclasses import dataclass

from .refc_types import GC_POINTER_TAG, Value, Value_Closure, Value_GCPointer, Value_Pointer, Value_World, fun_ptr_t

__all__ = ["to_idris_obj", "from_idris_obj", "to_idris_func", "register_py_func"]

cdll = None  # Backpatched to actual Idris cdll by the time this module is used

pythonapi.Py_IncRef.argtypes = (py_object,)
pythonapi.Py_IncRef.restype = c_void_p

pythonapi.Py_DecRef.argtypes = (py_object,)
pythonapi.Py_DecRef.restype = c_void_p


def is_cfunc_type(obj_type):
    return hasattr(obj_type, "argtypes")


@fun_ptr_t
def on_collect_idris_obj(idris_arglist):
    py_obj = cast(
        cast(idris_arglist.contents.args[0], POINTER(Value_Pointer)).contents.p,
        py_object
    ).value
    pythonapi.Py_DecRef(py_obj)


def to_idris_obj(py_obj, obj_type):
    if obj_type is py_object:
        pythonapi.Py_IncRef(py_obj)
        return cdll.makeGCPointer(
            py_object(py_obj),
            cdll.makeClosureFromArglist(on_collect_idris_obj, cdll.newArglist(2, 2))
        )

    if is_cfunc_type(obj_type):
        return to_idris_func(py_obj, obj_type._restype_, *obj_type._argtypes_)

    if obj_type is c_char_p:
        return cast(py_obj, c_void_p).value

    return py_obj


def from_idris_obj(idris_obj, obj_type):
    if obj_type is py_object:
        if idris_obj is None:
            return None

        gc_pointer = cast(c_void_p(idris_obj), POINTER(Value_GCPointer)).contents

        if gc_pointer.header.tag != GC_POINTER_TAG:
            # RefC sometimes uses makeInt64(0) to represent (), instead of NULL
            # If we get here, we're in that case
            return None

        return cast(gc_pointer.p.contents.p, py_object).value

    if is_cfunc_type(obj_type):
        return from_idris_func(idris_obj, obj_type._restype_, *obj_type._argtypes_)

    return idris_obj


def to_idris_args(args, ret_type, arg_type):
    args = iter(args)

    while True:
        if arg_type is POINTER(Value_World):
            yield cast(None, POINTER(Value)), ret_type
        else:
            yield cast(to_idris_obj(next(args), arg_type), POINTER(Value)), ret_type

        if not is_cfunc_type(ret_type):
            try:
                next(args)
            except StopIteration:
                return

            raise TypeError(
                f"Idris object is not a function: {ret_type}"
            )

        ret_type, arg_type = ret_type._restype_, *ret_type._argtypes_


def to_idris_func(py_func, ret_type, *arg_types):
    idris_type = lambda c_type: (
        c_void_p
        if c_type is py_object or is_cfunc_type(c_type) else
        c_type
    )

    arg_types = tuple(filter(lambda c_type: c_type is not POINTER(Value_World), arg_types))

    @CFUNCTYPE(idris_type(ret_type) if ret_type is not c_char_p else c_void_p, *map(idris_type, arg_types))
    def idris_func(*args):
        return to_idris_obj(py_func(*(
            from_idris_obj(arg, arg_type)
            for arg, arg_type in zip(args, arg_types)
        )), ret_type)

    return idris_func


@dataclass(frozen=True)
class IdrisFunction:
    idris_func: POINTER(Value_Closure)
    ret_type: type
    arg_type: type

    def __post_init__(self):
        cdll.newReference(cast(self.idris_func, POINTER(Value)))

    def __call__(self, *args):
        result = self.idris_func
        result_type = self.ret_type

        for arg, result_type in to_idris_args(args, self.ret_type, self.arg_type):
            result = cdll.apply_closure(
                cast(result, POINTER(Value_Closure)),
                arg
            )

        return from_idris_obj(result, result_type)

    def __del__(self):
        cdll.removeReference(cast(self.idris_func, POINTER(Value)))


def from_idris_func(idris_func, ret_type, arg_type):
    return IdrisFunction(cast(idris_func, POINTER(Value_Closure)), ret_type, arg_type)


# Keep a list of Python-side references to the generated Idris functions, so
# they don't get prematurely GCed
idris_funcs = []


def register_py_func(c_name, py_func, ret_type, *arg_types):
    idris_func = to_idris_func(py_func, ret_type, *arg_types)
    idris_funcs.append(idris_func)
    c_void_p.in_dll(cdll, c_name).value = cast(idris_func, c_void_p).value
