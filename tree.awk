#!/usr/bin/awk -f

function assert(cond, emsg)
{
    if (!cond) {
        print "error:", emsg > "/dev/stderr"
        exit 42
    }
}

function tree_new(tree)
{
    delete tree
    tree["#"] = tree["%"] = 0
}

function tree_del(tree)
{
    delete tree
}

function tree_node_new(tree, parent, key,       i, k)
{
    if (tree["%"]) {
        k = --tree["%"]
        i = tree["%", k]
        delete tree["%", k]
    } else {
        i = ++tree["#"]
    }

    tree[i, "k"] = key
    tree[i, "p"] = parent
    tree[i, "l"] = 0
    tree[i, "r"] = 0

    return i
}

function tree_node_del(tree, node,      i)
{
    delete tree[node, "l"]
    delete tree[node, "p"]
    delete tree[node, "r"]
    delete tree[node, "k"]
    # collect unused indices in % namespace
    i = tree["%"]++
    tree["%", i] = node
}

function tree_build_(tree, parent, arr, lo, hi,      node, mi)
{
    if (lo > hi)
        return 0

    mi = int((lo + hi) / 2)

    node = tree_node_new(tree, parent, arr[mi])
    tree[node, "l"] = tree_build_(tree, node, arr, lo, mi - 1)
    tree[node, "r"] = tree_build_(tree, node, arr, mi + 1, hi)

    return node
}

function tree_build(tree, parent, arr, num)
{
    return tree_build_(tree, parent, arr, 0, num - 1)
}

function tree_first_post(tree, node)
{
    while (tree[node, "l"] || tree[node, "r"]) {
        if (tree[node, "l"])
            node = tree[node, "l"]
        else if (tree[node, "r"])
            node = tree[node, "r"]
        else
            break
    }

    return node
}

function tree_next_post(tree, node)
{
    if (!tree[node, "p"])
        return 0

    if (node == tree[tree[node, "p"], "r"])
        return tree[node, "p"]

    # node is the left child but the parent has no its right child
    if (!tree[tree[node, "p"], "r"])
        return tree[node, "p"]

    node = tree[tree[node, "p"], "r"]

    while (tree[node, "l"] || tree[node, "r"]) {
        if (tree[node, "l"])
            node = tree[node, "l"]
        else if (tree[node, "r"])
            node = tree[node, "r"]
        else
            break
    }

    return node
}

function tree_first_pre(tree, node)
{
    return node
}

function tree_next_pre(tree, node)
{
    if (tree[node, "l"]) {
        node = tree[node, "l"]
    } else if (tree[node, "r"]) {
        node = tree[node, "r"]
    } else {
        while (tree[node, "p"]) {
            if (node == tree[tree[node, "p"], "l"]) {
                if (tree[tree[node, "p"], "r"])
                    return tree[tree[node, "p"], "r"]
                else
                    node = tree[node, "p"]
            } else {
                node = tree[node, "p"]
            }
        }
        node = tree[node, "p"]
    }

    return node
}

function tree_first_in(tree, node)
{
    while (tree[node, "l"])
        node = tree[node, "l"]

    return node
}

function tree_next_in(tree, node)
{
    if (tree[node, "r"]) {
        node = tree[node, "r"]
        while (tree[node, "l"])
            node = tree[node, "l"]
    } else {
        if (tree[node, "p"] && node == tree[tree[node, "p"], "l"]) {
            node = tree[node, "p"]
        } else {
            while (tree[node, "p"] && node == tree[tree[node, "p"], "r"])
                node = tree[node, "p"]
            node = tree[node, "p"]
        }
    }

    return node
}

function tree_first(tree, node, how)
{
    if (how == TREE_IN_ORDER)
        node = tree_first_in(tree, node)
    else if (how == TREE_PRE_ORDER)
        node = tree_first_pre(tree, node)
    else if (how == TREE_POST_ORDER)
        node = tree_first_post(tree, node)
    else
        assert(0, "tree_first(): unknown how argument " how)

    return node
}

function tree_next(tree, node, how)
{
    if (how == TREE_IN_ORDER)
        node = tree_next_in(tree, node)
    else if (how == TREE_PRE_ORDER)
        node = tree_next_pre(tree, node)
    else if (how == TREE_POST_ORDER)
        node = tree_next_post(tree, node)
    else
        assert(0, "tree_next(): unknown how argument " how)

    return node
}

function tree_draw(tree, node, h,      sp)
{
    sp = 4 * h

    if (!node) {
        # print nullptr as *
        printf "%*s %*s*\n", sp, "",  4, ""
        return
    }

    tree_draw(tree, tree[node, "r"], h + 1)
    printf "%*s %5d\n", sp, "", tree[node, "k"]
    tree_draw(tree, tree[node, "l"], h + 1)
}

function tree_find(tree, root, key)
{
    while (root) {
        if (tree[root, "k"] > key)
            root = tree[root, "l"]
        else if (tree[root, "k"] < key)
            root = tree[root, "r"]
        else
            return root
    }

    return 0
}

function tree_insert(tree, root, key)
{
    if (!root)
        return tree_node_new(tree, root, key)

    while (root) {
        if (tree[root, "k"] > key) {
            if (!tree[root, "l"])
                tree[root, "l"] = tree_node_new(tree, root, key)
            root = tree[root, "l"]
        } else if (tree[root, "k"] < key) {
            if (!tree[root, "r"])
                tree[root, "r"] = tree_node_new(tree, root, key)
            root = tree[root, "r"]
        } else {
            break
        }
    }

    return root
}

function tree_collect_rec(tree, root, how, arr,        l, r, k)
{
    if (!root)
        return

    l = tree[root, "l"]
    r = tree[root, "r"]
    k = tree[root, "k"]

    if (how == TREE_IN_ORDER) {
        tree_collect_rec(tree, l, how, arr);
        arr[arr["#"]++] =  k
        tree_collect_rec(tree, r, how, arr);
    } else if (how == TREE_PRE_ORDER) {
        arr[arr["#"]++] =  k
        tree_collect_rec(tree, l, how, arr);
        tree_collect_rec(tree, r, how, arr);
    } else if (how == TREE_POST_ORDER) {
        tree_collect_rec(tree, l, how, arr);
        tree_collect_rec(tree, r, how, arr);
        arr[arr["#"]++] =  k
    } else {
        assert(0, "tree_collect_rec(): unknown how argument " how)
    }
}

function tree_collect(tree, root, how, arr,         iter)
{
    for (iter = tree_first(tree, root, how); iter; iter = tree_next(tree, iter, how))
        arr[arr["#"]++] = tree[iter, "k"]
}

function arr_cmp(a1, a2,        i, n)
{
    if (a1["#"] != a2["#"])
        return 0

    n = a1["#"]

    for (i = 0; i < n; i++)
        if (a1[i] != a2[i])
            return 0

    return 1
}

function arr_reset(arr)
{
    delete arr
    arr["#"] = 0
}

function arr_print(arr,       i, n)
{
   n = arr["#"]
   for (i = 0; i < n; i++)
       printf arr[i]  " "
   print ""
}

function TEST(cond, txt,    t)
{
    printf "%-40s: %s\n", txt, (cond ? "\033[32mPASS\033[0m" : "\033[31mFAIL\033[0m")
}

function order2str(how)
{
    return how == TREE_IN_ORDER ? "IN_ORDER" :
           how == TREE_PRE_ORDER ? "PRE_ORDER" :
           how == TREE_POST_ORDER ? "POST_ORDER" : "UNKNOWN_ORDER"
}

BEGIN {
    TREE_IN_ORDER = 1
    TREE_PRE_ORDER = 2
    TREE_POST_ORDER = 3

    srand()

    TESTS = 10000
    NODES = 100

    for (i = 0; i < TESTS; i++) {
        tree_new(tree)
        root = 0
        # insert random values, it's not BST
        root = tree_insert(tree, root, int(1000 * rand()))

        for (j = 0; j < NODES; j++)
            tree_insert(tree, root, int(1000 * rand()))

        for (how = TREE_IN_ORDER; how <= TREE_POST_ORDER; how++) {
            arr_reset(a1)
            arr_reset(a2)

            # check that iterative functions are correct
            # compare recursive and iteration results with
            # random input
            tree_collect(tree, root, how, a1)
            tree_collect_rec(tree, root, how, a2)

            num = sprintf("%5d/" TESTS, i + 1)

            ok = arr_cmp(a1, a2)
            TEST(ok, "Fuzz order " num ": " order2str(how))
            if (!ok) {
                tree_draw(tree, root)
                printf "iter: "; arr_print(a1)
                printf "rec: "; arr_print(a2)
                exit(1)
            }
        }

        tree_del(tree)
    }

    print "\nBuild and show BST (the root is on the left, leafs are on the right, * is nullptr):"

    N = 10
    for (i = 0; i < N; i++)
        arr[i] = 42 + i

    root = 0
    tree_new(tree)
    root = tree_build(tree, root, arr, N)
    tree_draw(tree, root, 0)
}

