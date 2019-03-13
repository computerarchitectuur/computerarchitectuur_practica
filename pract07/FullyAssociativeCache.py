from Cache import AbstractCache

class FullyAssociativeCache(AbstractCache):
    def __init__(self, blocks, linesize):
        super().__init__()

    def request(self, address):
        return False

    def dump(self):
        pass
