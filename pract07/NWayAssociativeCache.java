import java.util.*;

public class NWayAssociativeCache implements Cache {

  public NWayAssociativeCache(int sets, int linesize, int associativity) {
  }

  /**
   * @param address het adres van de aanvraag.
   * @return true bij een cachehit, false bij een cachemis.
   */
  public boolean request(int address) {
    return true;
  }

  public void dump() {
  }
}
