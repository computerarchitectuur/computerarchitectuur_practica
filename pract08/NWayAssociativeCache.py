# Automatically decompiled
# Python bytecode 3.4 (3310)
# Embedded file name: /home/student/computerarchitectuur_practica/pract08//NWayAssociativeCache.py
# Compiled at: 2018-05-17 13:26:30
# Size of source mod 2**32: 1109 bytes
from Cache import AbstractCache

class NWayAssociativeCache(AbstractCache):

    def __init__(self, blocks, linesize, associativity):
        super().__init__()
        self.associativity = associativity
        self.blocks = blocks
        self.sets = blocks // associativity
        self.linesize = linesize
        self.list = [[-1] * self.associativity] * self.sets

    def request(self, address):
        line = address // self.linesize
        tag = line // self.sets
        index = line % self.sets
        for iii in range(self.associativity):
            if self.list[index][iii] == tag:
                self.list[index] = [tag] + self.list[index][:iii] + self.list[index][iii + 1:]
                return True

        self.list[index] = [tag] + self.list[index][:-1]
        return False

    def dump(self):
        for iii in range(self.sets):
            print('Set ' + str(iii) + ':')
            for jjj in range(self.associativity):
                validness = 'true' if self.list[iii][jjj] != -1 else 'false'
                print('Block : ' + validness + ' ' + str(self.list[iii][jjj]))
