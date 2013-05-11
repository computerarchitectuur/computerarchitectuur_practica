
public class FullyAssociativeCache implements Cache {

  NWayAssociativeCache cache = null;

  public FullyAssociativeCache(int blocks, int linesize) {
    cache = new NWayAssociativeCache(1, linesize, blocks);
  }

  public boolean request(int address) {
    return cache.request(address);
  }

  public void dump() {
    cache.dump();
  }

}

