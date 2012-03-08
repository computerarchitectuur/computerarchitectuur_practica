class DirectMappedCache implements Cache {
	
  DirectMappedCache(int blocks, int size) {
    // Ga na hoeveel bits er worden gebruikt voor de tag, index en offset. 
  }

  /**
   * @param address het adres van de aanvraag.
   * @return true bij een cachehit, false bij een cachemis.
   */
  public boolean request(int address) {
    // Geef true terug bij een hit en false bij een misser.
    return true;
  }

  public void dump() {
  }
}
