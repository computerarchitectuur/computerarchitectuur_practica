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
            offset = hash((2019, group_id)) % 1024
            offset = align(offset, 128)
            address += offset

    return addresses
