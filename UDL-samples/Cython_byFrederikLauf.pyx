cdef double myVariable = 5.5

cdef int myCyFunction(int i, int j):
    if i == j:
        return 1
    else:
        return 0

cpdef int myOtherCyFunction(int i, int j):
    if i == j:
        return 1
    else:
        return 0

def myPyFunction():
    pass

cdef class MyCythonClass():

    cdef public int invisible_variable

    cdef public double[:] myCyClassMethod(self):
        pass

    def myPyClassMethod(self):
        pass

class MyPythonClass():

    class _invisibleNestedClass:
        def _visibleNestedClassMethod(self):
            pass

    def myPyClassMethod(self):
        pass
