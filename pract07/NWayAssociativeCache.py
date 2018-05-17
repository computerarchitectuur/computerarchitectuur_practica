from Cache import AbstractCache

class NWayAssociativeCache(AbstractCache):
    def __init__(self, blocks, linesize, associativity):
        super().__init__()

    def request(self, address):
        return False

    def dump(self):
        pass
