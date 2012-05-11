
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

  private static class OptionError extends Exception {
    public OptionError(String s) { super(s); }
  }

  public static void main(String[] args) {


    Option cacheOpt    = OptionBuilder.withArgName("cache")
                                      .hasArgs()
                                      .withDescription("Type of cache. One of DirectMapped, FullyAssociative, NWaySetAssociative")
                                      .isRequired()
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
                                      .withDescription("Address pattern to simulate. Can by one of rowMajor, columnMajor, matrixMultiply or matrixTiledMultiply")
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
      System.err.println("Parsing of the command line has failed. Here's why: ");
      System.err.println(exp.getMessage());
      formatter.printHelp("CacheSim", options);
      System.exit(-1);
    }

    // The cache should be one of the specified types.
    Cache cache = null;
    try {
      int blocks = Integer.parseInt(line.getOptionValue("blocks"));
      int linesize = Integer.parseInt(line.getOptionValue("linesize"));
      if(! isPowerOf2(blocks) || ! isPowerOf2(linesize)) {
        throw new OptionError("Whoops. blocks and linesize must be powers of 2.");
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
          throw new OptionError("Whoops. blocks should be a multiple of the associativity in a n-way set associative cache");
        }
        cache = new NWayAssociativeCache(blocks / assoc, linesize, assoc);
      }
      else {
        throw new OptionError("Unknown cache type.");
      }

      String pattern = line.getOptionValue("pattern");
      if(pattern.equals("rowMajor")) {
        rowMajor(cache, 32);
      }
      else if(pattern.equals("columnMajor")) {
        columnMajor(cache, 32);
      }
      else if(pattern.equals("matrixMultiply")) {
        matrixMultiply(cache, 32);
      }
      else if(pattern.equals("matrixTiledMultiply")) {
        matrixTiledMultiply(cache, 32);
      }
      else {
        throw new OptionError("Unknown pattern type.");
      }
    }
    catch(OptionError exp) {
      System.err.println(exp.getMessage());
      exp.printStackTrace();
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


	// This function generates the access pattern.
	private static void rowMajor(Cache cache, int size)
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

		// Print matrix (for verification)
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		//System.out.println("/////////////////////////////// Input Matrix ///////////////////////////////////");
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		// A
		//System.out.println("A=\t");
		//for (int i=0;i<size;i++)
		//{	
			//System.out.println("\t");
			//for (int j=0;j<size;j++)
			//{
				//System.out.print(A[ i ][ j ]);
				//System.out.print("\t");
			//}
			//System.out.println();
		//}

		// Now do B = A*2
		for (int i=0;i<size;i++)
		{	
			for (int j=0;j<size;j++)
			{
				B[ i ][ j ] = A[ i ][ j ]*2;

				// Forward the access to the cache.
				requests++;
				if (sendCacheRequest(cache, "A", i, j, size)) 
				{
					hits++;
				}
				requests++;
				if (sendCacheRequest(cache, "B", i, j, size)) 
				{
					hits++;
				}

			}
		}

		// Print matrix (for verification)
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		//System.out.println("/////////////////////////////// Output Matrix //////////////////////////////////");
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		// B 
		//System.out.println("A=\t");

		//for (int i=0;i<size;i++)
		//{	
			//System.out.println("\t");
			//for (int j=0;j<size;j++)
			//{
			//	System.out.print(B[ i ][ j ]);
			//	System.out.print("\t");
			//}
			//System.out.println();
		//}
		//System.out.println();

		// Force a cache dump (optional)
		//cache.request(-1);
		
		// Report the results of the simulation.
		System.out.println("////////////////////////////////////////////////////////////////////////////////");
		System.out.println("//////////////////////////////// Statistics ////////////////////////////////////");
		System.out.println("////////////////////////////////////////////////////////////////////////////////");
		System.out.println("Total Requests: " + requests);
		System.out.println("    Cache Hits: " + hits);
		System.out.println("      Hit Rate: " + ((double) hits)/ requests);
		System.out.println();
		System.out.println("////////////////////////////////////////////////////////////////////////////////");

	}



	// This function generates the access pattern.
	private static void columnMajor(Cache cache, int size)
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

		// Print matrix (for verification)
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		//System.out.println("/////////////////////////////// Input Matrix ///////////////////////////////////");
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		// A
		//System.out.println("A=\t");
		//for (int i=0;i<size;i++)
		//{	
		//	System.out.println("\t");
		//	for (int j=0;j<size;j++)
		//	{
		//		System.out.print(A[ i ][ j ]);
		//		System.out.print("\t");
		//	}
		//	System.out.println();
		//}

		// Now do B = A*2
		for (int i=0;i<size;i++)
		{	
			for (int j=0;j<size;j++)
			{
				B[ j ][ i ] = A[ j ][ i ]*2;

				// Forward the access to the cache.
				requests++;
				if (sendCacheRequest(cache, "A", j, i, size)) 
				{
					hits++;
				}
				requests++;
				if (sendCacheRequest(cache, "B", j, i, size)) 
				{
					hits++;
				}

			}
		}

		// Print matrix (for verification)
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		//System.out.println("/////////////////////////////// Output Matrix //////////////////////////////////");
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		// B 
		//System.out.println("A=\t");

		//for (int i=0;i<size;i++)
		//{	
		//	System.out.println("\t");
		//	for (int j=0;j<size;j++)
		//	{
		//		System.out.print(B[ i ][ j ]);
		//		System.out.print("\t");
		//	}
		//	System.out.println();
		//}
		//System.out.println();

		// Force a cache dump (optional)
		//cache.request(-1);
		
		// Report the results of the simulation.
		System.out.println("////////////////////////////////////////////////////////////////////////////////");
		System.out.println("//////////////////////////////// Statistics ////////////////////////////////////");
		System.out.println("////////////////////////////////////////////////////////////////////////////////");
		System.out.println("Total Requests: " + requests);
		System.out.println("    Cache Hits: " + hits);
		System.out.println("      Hit Rate: " + ((double) hits)/ requests);
		System.out.println();
		System.out.println("////////////////////////////////////////////////////////////////////////////////");

	}


	// This function generates the access pattern for a straightforward matrix multiplication.
	private static void matrixMultiply(Cache cache, int size)
	{
		// Statistics
		int requests = 0;
		int hits = 0;

		// Define matrices for A*B=C
		int A[][] = new int[size][size];
		int B[][] = new int[size][size];
		int C[][] = new int[size][size];

		// Initialize matrix
		for (int i=0;i<size;i++)
		{	
			for (int j=0;j<size;j++)
			{
				A[ i ][ j ] = i;
				B[ i ][ j ] = j;
				C[ i ][ j ] = 0;
			}
		}
	
		// Print matrix (for verification)
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		//System.out.println("/////////////////////////////// Input Matrix ///////////////////////////////////");
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		// A
		//System.out.println("A=\t");
		//for (int i=0;i<size;i++)
		//{
		//	System.out.print("\t");
		//	for (int j=0;j<size;j++)
		//	{
		//		System.out.print(A[ i ][ j ]);
		//		System.out.print("\t");
		//	}
		//	System.out.println();
		//}
		// B
		//System.out.println("B=\t");
		//for (int i=0;i<size;i++)
		//{
		//	System.out.print("\t");
		//	for (int j=0;j<size;j++)
		//	{
		//		System.out.print(B[ i ][ j ]);
		//		System.out.print("\t");
		//	}
		//	System.out.println();
		//}

		// Now do A*B=C
		for (int i=0;i<size;i++)
		{	
			for (int j=0;j<size;j++)
			{
				for (int k=0;k<size;k++)
				{
					C[ i ][ j ] = C[ i ][ j ]+ A[ i ][ k ]* B[ k ][ j ];

					// Read C[k][i]
					requests++;
					if (sendCacheRequest(cache, "C", i, j, size)) 
					{
						hits++;
					}
					
					// Read A[j][i]
					requests++;
					if (sendCacheRequest(cache, "A", i, k, size)) 
					{
						hits++;
					}
					
					// Read B[k][j]
					requests++;
					if (sendCacheRequest(cache, "B", k, i, size)) 
					{
						hits++;
					}
					
					// Write C[k][i]
					requests++;
					if (sendCacheRequest(cache, "Cr", i, j, size)) 
					{
						hits++;
					}

				}
			}
		}

		// Print matrix (for verification)
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		//System.out.println("/////////////////////////////// Output Matrix //////////////////////////////////");
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		// C
		//System.out.println("C=\t");
		//for (int i=0;i<size;i++)
		//{
		//	System.out.print("\t");
		//	for (int j=0;j<size;j++)
		//	{
		//		System.out.print(C[ i ][ j ]);
		//		System.out.print("\t");
		//	}
		//	System.out.println();
		//}

		// Force a cache dump (optional)
		//cache.request(-1);
		
		// Report the results of the simulation.
		System.out.println("////////////////////////////////////////////////////////////////////////////////");
		System.out.println("//////////////////////////////// Statistics ////////////////////////////////////");
		System.out.println("////////////////////////////////////////////////////////////////////////////////");
		System.out.println("Total Requests: " + requests);
		System.out.println("    Cache Hits: " + hits);
		System.out.println("      Hit Rate: " + ((double) hits)/ requests);
		System.out.println();
		System.out.println("////////////////////////////////////////////////////////////////////////////////");

	}





	// This function generates the access pattern for a straightforward matrix multiplication.
	private static void matrixTiledMultiply(Cache cache, int size)
	{
		// Set tilesize
		int tilesize = 2;
		if (size%tilesize != 0)
		{
			System.out.println("tilesize must be N*size!");
			System.exit(-1);
		}

		// Statistics
		int requests = 0;
		int hits = 0;

		// Define matrices for A*B=C
		int A[][] = new int[size][size];
		int B[][] = new int[size][size];
		int C[][] = new int[size][size];

		// Initialize matrix
		for (int i=0;i<size;i++)
		{	
			for (int j=0;j<size;j++)
			{
				A[ i ][ j ] = i;
				B[ i ][ j ] = j;
				C[ i ][ j ] = 0;
			}
		}
	
		// Print matrix (for verification)
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		//System.out.println("/////////////////////////////// Input Matrix ///////////////////////////////////");
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		// A
		//System.out.println("A=\t");
		//for (int i=0;i<size;i++)
		//{
		//	System.out.print("\t");
		//	for (int j=0;j<size;j++)
		//	{
		//		System.out.print(A[ i ][ j ]);
		//		System.out.print("\t");
		//	}
		//	System.out.println();
		//}
		// B
		//System.out.println("B=\t");
		//for (int i=0;i<size;i++)
		//{
		//	System.out.print("\t");
		//	for (int j=0;j<size;j++)
		//	{
		//		System.out.print(B[ i ][ j ]);
		//		System.out.print("\t");
		//	}
		//	System.out.println();
		//}

		// Now do A*B=C
		for (int i0=0;i0<size;i0+=tilesize)
		{	
			for (int j0=0;j0<size;j0+=tilesize)
			{
				for (int k0=0;k0<size;k0+=tilesize)
				{
					for (int i=i0;i<(i0+tilesize);i++)
					{
						for (int j=j0;j<(j0+tilesize);j++)
						{
							for (int k=k0;k<(k0+tilesize);k++)
							{
								C[ i ][ j ] = C[ i ][ j ]+ A[ i ][ k ]* B[ k ][ j ];

								// Read C[i][j]
								requests++;
								if (sendCacheRequest(cache, "C", i, j, size)) 
								{
									hits++;
								}

								// Read A[j][k]
								requests++;
								if (sendCacheRequest(cache, "A", i, k, size)) 
								{
									hits++;
								}

								// Read B[k][j]
								requests++;
								if (sendCacheRequest(cache, "B", k, j, size)) 
								{
									hits++;
								}

								// Write C[i][j]
								requests++;
								if (sendCacheRequest(cache, "Cr", i, j, size)) 
								{
									hits++;
								}
							}
						}
					}
				}
			}
		}

		// Print matrix (for verification)
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		//System.out.println("/////////////////////////////// Output Matrix //////////////////////////////////");
		//System.out.println("////////////////////////////////////////////////////////////////////////////////");
		// C
		//System.out.println("C=\t");
		//for (int i=0;i<size;i++)
		//{
		//	System.out.print("\t");
		//	for (int j=0;j<size;j++)
		//	{
		//		System.out.print(C[ i ][ j ]);
		//		System.out.print("\t");
		//	}
		//	System.out.println();
		//}

		// Force a cache dump (optional)
		//cache.request(-1);
		
		// Report the results of the simulation.
		System.out.println("////////////////////////////////////////////////////////////////////////////////");
		System.out.println("//////////////////////////////// Statistics ////////////////////////////////////");
		System.out.println("////////////////////////////////////////////////////////////////////////////////");
		System.out.println("Total Requests: " + requests);
		System.out.println("    Cache Hits: " + hits);
		System.out.println("      Hit Rate: " + ((double) hits)/ requests);
		System.out.println();
		System.out.println("////////////////////////////////////////////////////////////////////////////////");

	}
}
