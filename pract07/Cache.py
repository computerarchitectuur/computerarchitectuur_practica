class AbstractCache:
    def __init__(self):
        self.debug = False
        self.nr_of_requests = 0
        self.nr_of_hits = 0

    def do_request(self, name, address):
        # Do the actual request
        hit = self.request(address)

        # Print out debugging information if requested
        if self.debug:
            print(name + ': ' + str(address) + (' *' if hit else ''))

        # Update statistics
        if hit:
            self.nr_of_hits += 1
        self.nr_of_requests += 1

        return hit

    # Output the results
    def output_results(self):
        # Dump the contents
        self.dump()

        # Print statistics
        print('Total requests: ' + str(self.nr_of_requests))
        print('Cache hits: ' + str(self.nr_of_hits))
        hit_rate = (self.nr_of_hits / self.nr_of_requests) if self.nr_of_requests else 1
        print('Hit rate: ' + str(hit_rate))

from DirectMappedCache import DirectMappedCache
from FullyAssociativeCache import FullyAssociativeCache
from NWayAssociativeCache import NWayAssociativeCache

def get_all_subclasses(cls):
    all_subclasses = []

    for subclass in cls.__subclasses__():
        all_subclasses.append(subclass)
        all_subclasses.extend(get_all_subclasses(subclass))

    return all_subclasses

def get_types():
    return get_all_subclasses(AbstractCache)
