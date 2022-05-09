import Address
from Matrix import Matrix

class AbstractPattern:
    def __init__(self, group_id, matrix_size):
        # Determine the sizes of all the matrices (these are the same) and
        # use it to assign addresses to each of them.
        matrices_size = Matrix.calculate_size(4, matrix_size, matrix_size)
        address_A, address_B, address_C = Address.assign_object_sizes(group_id, [matrices_size, matrices_size, matrices_size])

        # Construct actual matrices on assigned addresses.
        self.matrix_A = Matrix(address_A, 4, matrix_size, matrix_size)
        self.matrix_B = Matrix(address_B, 4, matrix_size, matrix_size)
        self.matrix_C = Matrix(address_C, 4, matrix_size, matrix_size)

class Pattern0(AbstractPattern):
    def simulate(self, cache):
        for iii in range(self.matrix_A.nr_of_rows):
            for jjj in range(self.matrix_A.nr_of_cols):
                # B[ i ][ j ] = A[ i ][ j ]
                cache.do_request('A', self.matrix_A.get_elem_address(iii, jjj))
                cache.do_request('B', self.matrix_B.get_elem_address(iii, jjj))

class Pattern1(AbstractPattern):
    def simulate(self, cache):
        for iii in range(self.matrix_A.nr_of_rows):
            for jjj in range(self.matrix_A.nr_of_cols):
                # B[ j ][ i ] = A[ i ][ j ]
                cache.do_request('A', self.matrix_A.get_elem_address(iii, jjj))
                cache.do_request('B', self.matrix_B.get_elem_address(jjj, iii))

class Pattern2(AbstractPattern):
    def simulate(self, cache):
        for iii in range(self.matrix_A.nr_of_rows):
            for jjj in range(self.matrix_A.nr_of_cols):
                # B[ j ][ i ] = A[ j ][ i ]
                cache.do_request('A', self.matrix_A.get_elem_address(jjj, iii))
                cache.do_request('B', self.matrix_B.get_elem_address(jjj, iii))

class Pattern3(AbstractPattern):
    def simulate(self, cache):
        for iii in range(self.matrix_A.nr_of_rows):
            for jjj in range(self.matrix_A.nr_of_cols):
                # B[ i ][ j ] = A[ j ][ i ]
                cache.do_request('A', self.matrix_A.get_elem_address(jjj, iii))
                cache.do_request('B', self.matrix_B.get_elem_address(iii, jjj))

class RowMajor(AbstractPattern):
    def simulate(self, cache):
        for iii in range(self.matrix_A.nr_of_rows):
            for jjj in range(self.matrix_A.nr_of_cols):
                # B[ i ][ j ] = A[ i ][ j ]*2
                cache.do_request('A', self.matrix_A.get_elem_address(iii, jjj))
                cache.do_request('B', self.matrix_B.get_elem_address(iii, jjj))

class ColumnMajor(AbstractPattern):
    def simulate(self, cache):
        for iii in range(self.matrix_A.nr_of_rows):
            for jjj in range(self.matrix_A.nr_of_cols):
                # B[ j ][ i ] = A[ j ][ i ]*2
                cache.do_request('A', self.matrix_A.get_elem_address(jjj, iii))
                cache.do_request('B', self.matrix_B.get_elem_address(jjj, iii))

class MatrixMultiply(AbstractPattern):
    def simulate(self, cache):
        for iii in range(self.matrix_C.nr_of_rows):
            for jjj in range(self.matrix_C.nr_of_cols):
                for kkk in range(self.matrix_A.nr_of_cols):
                    # C[ i ][ j ] = C[ i ][ j ]+ A[ i ][ k ]* B[ k ][ j ]
                    cache.do_request('Cread', self.matrix_C.get_elem_address(iii, jjj))
                    cache.do_request('A', self.matrix_A.get_elem_address(iii, kkk))
                    cache.do_request('B', self.matrix_B.get_elem_address(kkk, jjj))
                    cache.do_request('Cwrite', self.matrix_C.get_elem_address(iii, jjj))

class MatrixTiledMultiply(AbstractPattern):
    def simulate(self, cache):
        tilesize = 2
        for iii0 in range(0, self.matrix_C.nr_of_rows, tilesize):
            for jjj0 in range(0, self.matrix_C.nr_of_cols, tilesize):
                for kkk0 in range(0, self.matrix_A.nr_of_cols, tilesize):
                    for iii in range(iii0, iii0 + tilesize):
                        for jjj in range(jjj0, jjj0 + tilesize):
                            for kkk in range(kkk0, kkk0 + tilesize):
                                # C[ i ][ j ] = C[ i ][ j ]+ A[ i ][ k ]* B[ k ][ j ]
                                cache.do_request('Cread', self.matrix_C.get_elem_address(iii, jjj))
                                cache.do_request('A', self.matrix_A.get_elem_address(iii, kkk))
                                cache.do_request('B', self.matrix_B.get_elem_address(kkk, jjj))
                                cache.do_request('Cwrite', self.matrix_C.get_elem_address(iii, jjj))

def get_types():
    return AbstractPattern.__subclasses__()
