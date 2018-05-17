class Matrix:
    def __init__(self, address, element_size, nr_of_rows, nr_of_cols):
        self.address = address
        self.element_size = element_size
        self.nr_of_rows = nr_of_rows
        self.nr_of_cols = nr_of_cols
        self.size = Matrix.calculate_size(self.element_size, self.nr_of_rows, self.nr_of_cols)

    def get_elem_address(self, row_index, col_index):
        assert row_index < self.nr_of_rows, 'Row index out of bounds!'
        assert col_index < self.nr_of_cols, 'Column index out of bounds!'
        
        return self.address + self.element_size * (row_index * self.nr_of_cols + col_index)

    @staticmethod
    def calculate_size(element_size, nr_of_rows, nr_of_cols):
        return element_size * nr_of_rows * nr_of_cols
