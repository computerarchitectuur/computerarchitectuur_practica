# Custom hashing function, from
# https://docs.python.org/3/library/stdtypes.html#hashing-of-numeric-types
# This ensures that we have the same values everywhere in a reproducible fashion across Python versions and architectures (sizeof long).
# That the produced hashes might not be suited for the underlying architecture is irrelevant in this case.
# It's not exactly what was there before (before we used to hash tuples, now we hash fractions, but close enough, right?)
def my_hash_fraction(m, n):
    """Compute the hash of a rational number m / n.

    Assumes m and n are integers, with n positive.
    Equivalent to hash(fractions.Fraction(m, n)).

    """
    P = 2**61 - 1
    # Remove common factors of P.  (Unnecessary if m and n already coprime.)
    while m % P == n % P == 0:
        m, n = m // P, n // P

    if n % P == 0:
        hash_value = P - 1 # Bart: ehh....
    else:
        # Fermat's Little Theorem: pow(n, P-1, P) is 1, so
        # pow(n, P-2, P) gives the inverse of n modulo P.
        hash_value = (abs(m) % P) * pow(n, P - 2, P) % P
    if m < 0:
        hash_value = -hash_value
    if hash_value == -1:
        hash_value = -2
    return hash_value

# Aligns x to base (21, 16) -> 32
def align(x, base):
    offset = x % base
    if offset == 0:
        return x
    else:
        return x + (base - offset)

def assign_object_sizes(group_id, object_sizes):
    addresses = []
    address = 0
    for size in object_sizes:
        addresses.append(address)
        address += size
        address += 64

        # If there is a group ID, add an offset
        if group_id:
            # Generate the offset, then align it
            offset = my_hash_fraction(2021, group_id) % 1024
            offset = align(offset, 128)
            address += offset

    return addresses
