from NWayAssociativeCache import NWayAssociativeCache

class DirectMappedCache(NWayAssociativeCache):
    def __init__(self, blocks, linesize):
        super().__init__(blocks, linesize, 1)
