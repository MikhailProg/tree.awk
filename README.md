
Tree in awk. The implementation uses awk multidimensional array as a C-like structure.

With such approach it's possible to model any dynamic data structures e.g lists, binary search tries (balanced and not balanced).

```
$ chmod a+x tree.awk
$ ./tree.awk
Fuzz order     1/10000: IN_ORDER        : PASS
Fuzz order     1/10000: PRE_ORDER       : PASS
Fuzz order     1/10000: POST_ORDER      : PASS
Fuzz order     2/10000: IN_ORDER        : PASS
Fuzz order     2/10000: PRE_ORDER       : PASS
Fuzz order     2/10000: POST_ORDER      : PASS
...
Fuzz order 10000/10000: IN_ORDER        : PASS
Fuzz order 10000/10000: PRE_ORDER       : PASS
Fuzz order 10000/10000: POST_ORDER      : PASS

Build and show BST (the root is on the left, leafs are on the right, * is nullptr):
                     *
                51
                     *
            50
                 *
        49
                     *
                48
                     *
            47
                 *
    46
                     *
                45
                     *
            44
                 *
        43
                 *
            42
                 *

``` 


