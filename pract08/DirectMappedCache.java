
public class DirectMappedCache implements Cache {

  NWayAssociativeCache cache = null;

  public DirectMappedCache(int sets, int linesize) {
    cache = new NWayAssociativeCache(sets, linesize, 1);
  }

  public boolean request(int address) {
    return cache.request(address);
  }

  public void dump() {
    cache.dump();
  }

}
