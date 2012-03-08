
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.IOException;

import org.apache.commons.cli.*;

/**
 * Cachesimulator. Execute with an unknow argument to get help :-p
 */
public class CacheSim {

  public static boolean isPowerOf2(int n) {
    if (n == 1) {
      return true;
    }

    if (n % 2 != 0) {
      return false;
    }
    else {
      return isPowerOf2(n / 2);
    }
  }

  public static void main(String[] args) {


    Option cacheOpt    = OptionBuilder.withArgName("cache")
                                      .hasArgs()
                                      .withDescription("Type of cache. One of DirectMapped, FullyAssociative, NWaySetAssociative")
                                      .create("cache");
    Option blocksOpt   = OptionBuilder.withArgName("blocks")
                                      .hasArg()
                                      .isRequired()
                                      .withDescription("")
                                      .create("blocks");
    Option linesizeOpt = OptionBuilder.withArgName("linesize")
                                      .hasArg()
                                      .isRequired()
                                      .withDescription("")
                                      .create("linesize");
    Option assocOpt    = OptionBuilder.withArgName("assoc")
                                      .hasArg()
                                      .withDescription("Associativity of the cache. Ignored for a direct mapped cache and a fully associative cache.")
                                      .create("assoc");
    Option patternOpt  = OptionBuilder.withArgName("pattern")
                                      .hasArg()
                                      .isRequired()
                                      .withDescription("Address pattern to simulate. Can by one of patroon1, patroon2 or patroon3")
                                      .create("pattern");

    Options options = new Options();
    options.addOption(cacheOpt);
    options.addOption(blocksOpt);
    options.addOption(linesizeOpt);
    options.addOption(assocOpt);
    options.addOption(patternOpt);

    HelpFormatter formatter = new HelpFormatter();

    CommandLineParser parser = new GnuParser();
    CommandLine line = null;
    try {
      line = parser.parse(options, args);
    }
    catch( ParseException exp ) {
      System.err.println("Parsing of the command line has failed. Here's why: " + exp.getMessage());
      formatter.printHelp("CacheSim", options);
      System.exit(-1);
    }

    // The cache should be one of the specified types.
    Cache cache = null;
    try {
      int blocks = Integer.parseInt(line.getOptionValue("blocks"));
      int linesize = Integer.parseInt(line.getOptionValue("linesize"));
      if(! isPowerOf2(blocks) || ! isPowerOf2(linesize)) {
        throw new Exception("Whoops. blocks and linesize must be powers of 2.");
      }
      String ctype = line.getOptionValue("cache");
      if(ctype.equals("DirectMapped")) {
        cache = new DirectMappedCache(blocks, linesize);
      }
      else if(ctype.equals("FullyAssociative")) {
        cache = new FullyAssociativeCache(blocks, linesize);
      }
      else if(ctype.equals("NWaySetAssociative")) {
        int assoc = Integer.parseInt(line.getOptionValue("assoc"));
        if(blocks % assoc != 0) {
          throw new Exception("Whoops. blocks should be a multiple of the associativity in a n-way set associative cache");
        }
        cache = new NWayAssociativeCache(blocks / assoc, linesize, assoc);
      }
      else {
        throw new Exception("Just because I can.");
      }

      String pattern = line.getOptionValue("pattern");
      if(pattern.equals("patroon1")) {
        pattern1(cache, 32);
      }
      else if(pattern.equals("patroon2")) {
        pattern2(cache, 32);
      }
      else if(pattern.equals("patroon3")) {
        pattern3(cache, 32);
      }
      else {
        throw new Exception("Yo dawg, put a known pattern in your pattern so I can cache while I cache.");
      }
    }
    catch(Exception exp) {
      System.err.println(exp.getMessage());
      formatter.printHelp("CacheSim", options);
      System.exit(-1);
    }

  }


  private static boolean sendCacheRequest(Cache cache, String matrix, int i, int j, int size) {
    // different matrices are located in different places in the memory, this
    // is modelled by using a matrix-specific base address.
    int base = 0;
    if (matrix.compareTo("A")==0)
      base = 0;
    else if (matrix.compareTo("B")==0)
      base = 4*size*size + 64;
    else if (matrix.compareTo("C")==0)
      base = 8*size*size + 96 ;
    else
    {
      System.err.println("Matrix " + matrix + "not recognized, please use A, B or C");
      System.exit(-1);
    }


    // Address is calculated (multiply by 4 assumes int equals 4B).
    int address = base + 4*((i * size) + j);

    boolean hit = cache.request(address);

    // Print out the address  (comment out the following line if needed)
    //System.out.println(matrix + ": " +  address + (hit ? "" : " *"));

    return hit;
  }


  // Data1 access pattern: .
  private static void pattern2(Cache cache, int size)
  {
    // Statistics
    int requests = 0;
    int hits = 0;

    // Input matrix
    int A[][] = new int[size][size];
    int B[][] = new int[size][size];

    // Initialize matrix
    int counter = 1;
    for (int i=0;i<size;i++)
    {	
      for (int j=0;j<size;j++)
      {
        A[ i ][ j ] = counter++;
        B[ i ][ j ] = 0;
      }
    }

    // Now fill B such that B[i][j] equals the sum of all elements of row i and column j of A
    for (int i=0;i<size;i++)
    {	
      for (int j=0;j<size;j++)
      { 
        // assuming this fits in a registers and does not generate a cache access.
        int sum = -A[i][j];
        for (int ii=0;ii<size;ii++)
        {
          sum+= A[ii][j];
          requests++;
          if (sendCacheRequest(cache, "A", ii, j, size)) hits++ ;
        }
        for (int jj=0;jj<size;jj++)
        {
          sum += A[i][jj];
          requests++;
          if (sendCacheRequest(cache, "A", i, jj, size)) hits++ ;
        }

        B[ i ][ j ] = sum;
        requests++;
        if(sendCacheRequest(cache, "B", i, j, size)) hits++ ;
      }
    }

    // Force a cache dump (put the following line in comment to prevent the dump).
    cache.request(-1);

    // Report the results of the simulation.
    System.out.println("Total Requests: " + requests);
    System.out.println("    Cache Hits: " + hits);
    System.out.println("      Hit Rate: " + ((double) hits)/ requests);

  }


  // transpose access pattern: .
  private static void pattern1(Cache cache, int size)
  {
    // Statistics
    int requests = 0;
    int hits = 0;

    // Input matrix
    int A[][] = new int[size][size];
    int B[][] = new int[size][size];

    // Initialize matrix
    int counter = 1;
    for (int i=0;i<size;i++)
    {	
      for (int j=0;j<size;j++)
      {
        A[ i ][ j ] = counter++;
        B[ i ][ j ] = 0;
      }
    }

    // Now fill B such that B[i][j] equals A[i][j];
    for (int i=0;i<size;i++)
    {	
      for (int j=0;j<size;j++)
      { 
        B[ i ][ j ] = A[ j ][ i ];
        requests++;
        if(sendCacheRequest(cache, "A", j, i, size)) hits++ ;
        requests++;
        if(sendCacheRequest(cache, "B", i, j, size)) hits++ ;
      }
    }

    // Force a cache dump (put the following line in comment to prevent the dump).
    cache.request(-1);

    // Report the results of the simulation.
    System.out.println("Total Requests: " + requests);
    System.out.println("    Cache Hits: " + hits);
    System.out.println("      Hit Rate: " + ((double) hits)/ requests);

  }

  // Matrix increment access pattern
  private static void pattern3(Cache cache, int size)
  {
    // Statistics
    int requests = 0;
    int hits = 0;

    // Input matrix
    int A[][] = new int[size][size];

    // Initialize matrix
    int counter = 1;
    for (int i=0;i<size;i++)
    {	
      for (int j=0;j<size;j++)
      {
        A[ i ][ j ] = counter++;
      }
    }

    for (int i=0;i<size;i++)
    {	
      for (int j=0;j<size;j++)
      { 
        A[ i ][ j ] = A[ i ][ j ]++;
        // read
        requests++;
        if(sendCacheRequest(cache, "A", j, i, size)) hits++ ;
        //write
        requests++;
        if(sendCacheRequest(cache, "A", j, i, size)) hits++ ;
      }
    }

    // Force a cache dump (put the following line in comment to prevent the dump).
    cache.request(-1);

    // Report the results of the simulation.
    System.out.println("Total Requests: " + requests);
    System.out.println("    Cache Hits: " + hits);
    System.out.println("      Hit Rate: " + ((double) hits)/ requests);

  }


}
