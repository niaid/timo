# timo

The heart of the algorithm has now been moved to a separate module, analyzer.  And now we use cython to greatly improve performance.  To use analyzer, it must be pre-built before it can be used.

To build the analyzer module enter the following command:

    sh build.sh
    
or, on biowolf the command is:

    sh build_biowulf.sh
