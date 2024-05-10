#!/usr/bin/python3
import argparse

import Cache
import Pattern

def is_power_of_2(n):
    return (n & (n -1)) == 0

if __name__ == '__main__':
    # Parsing the arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('cache', choices=[s.__name__ for s in Cache.get_types()], help='The type of cache.')
    parser.add_argument('pattern', choices=[s.__name__ for s in Pattern.get_types()], help='The address pattern to simulate.')
    parser.add_argument('-b', '--blocks', required=True, type=int, help='The number of blocks in the cache.')
    parser.add_argument('-l', '--linesize', required=True, type=int, help='The linesize used in the cache.')
    parser.add_argument('-a', '--associativity', type=int, default=1, help='The associativity of the cache.')
    parser.add_argument('-s', '--matrix_size', type=int, default=32, help='The size of the matrices.')
    parser.add_argument('-i', '--id', type=int, default=0, help='The group ID.')
    parser.add_argument('-d', '--debug', action='store_true', help='Dump debug information on the cache requests: the matrix, address, and whether it was a hit.')
    parser.add_argument('-B', '--Bstartaddress', type=int, default=None, help='Override the start address of matrix B.')
    args = parser.parse_args()

    # Do some argument checking
    assert is_power_of_2(args.blocks), 'Blocks must be a power of 2!'
    assert is_power_of_2(args.linesize), 'Linesize must be a power of 2!'
    assert (args.blocks % args.associativity) == 0, 'The number of blocks should be a multiple of the associativity!'

    if args.id != 0:
        assert args.Bstartaddress is None, 'You cannot override the start address of B when the group ID is provided'

    # Construct the cache
    if args.cache == 'DirectMappedCache':
        cache = Cache.DirectMappedCache(args.blocks, args.linesize)
    elif args.cache == 'FullyAssociativeCache':
        cache = Cache.FullyAssociativeCache(args.blocks, args.linesize)
    elif args.cache == 'NWayAssociativeCache':
        cache = Cache.NWayAssociativeCache(args.blocks, args.linesize, args.associativity)

    # Choose the pattern and instantiate it
    for pattern_type in Pattern.get_types():
        if pattern_type.__name__ == args.pattern:
            pattern = pattern_type(args.id, args.matrix_size, args.Bstartaddress)

    # Do the simulation and output the results
    cache.debug = args.debug
    pattern.simulate(cache)
    cache.output_results()
