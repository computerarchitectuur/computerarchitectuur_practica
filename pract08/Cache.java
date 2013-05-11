/**
 * Interface implemented by any type of cache.
 */
public interface Cache {
    
    /**
     * Simuleert een cache-aanvraag voor een specifiek adres.  
     * Indien de aanvraag resulteert in een cachemiss, geef false als waarde terug en 
     * veronderstel dat het geheugenblok dat het specifieke adres bevat in het 
     * geheugen zal worden geladen. Indien het adres in een cachehit resulteert,
     * geef true terug.
     * 
     * @param address het adres van de aanvraag.
     * @return true bij een cachehit, false bij een cachemis.
     */
    boolean request(int address);
    
    /**
     * Print de inhoud van de cache op het scherm.
     * De inhoud wordt geprint volgens het volgende formaat:
     * <pre>
     * Block 0: [valid] [tag]
     * Block 1: [valid] [tag]
     * </pre>
     * [valid] indicatie (true of false) of het blok geldig is.
     * [tag] is de decimale waarde van de tag van de cacheblok.
     */
    void dump();
}
