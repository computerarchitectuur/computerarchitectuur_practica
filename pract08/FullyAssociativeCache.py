from NWayAssociativeCache import NWayAssociativeCache

class FullyAssociativeCache(NWayAssociativeCache):
    def __init__(self, blocks, linesize):
        super().__init__(blocks, linesize, blocks)
