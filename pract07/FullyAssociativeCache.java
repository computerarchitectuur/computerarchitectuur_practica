public class FullyAssociativeCache implements Cache {

  public FullyAssociativeCache(int blocks, int linesize) {
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
