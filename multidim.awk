BEGIN {
    resetHeap()

    set("name", "John")
    set("age", 30)
    print get("name")
    print get("age")

    listCreate("a")
    listPush("a", "name")
    listPush("a", "age")

    print listLen("a")
    print typeOf("a")
    print typeOf("name")
    print listGetTypeOf("a", 0) " " listGetTypeOf("a", 1)
    print listGet("a", 0)        " " listGet("a", 1)

    heapDump()
}

function resetHeap() {
    InitialBuffer = 10
    ListServiceLen = 4
    split("", Heap)
    split("", Vars)
    HeapTop = 0
}

# set primitive
function set(var_name, value) {
    Vars[var_name] = HeapTop
    Heap[HeapTop++] = "primitive"
    Heap[HeapTop++] = value
}

# get primitive
function get(var_name) {
    # TODO make sure primitive
    return Heap[addrOf(var_name)+1]
}

function addrOf(var_name) { return Vars[var_name] }

function listCreate(var_name,   l_addr, refs_addr) {
    Vars[var_name] = l_addr = HeapTop
    _listCreate(0)
    refs_addr = HeapTop
    _listCreate(1)
    Heap[l_addr+3] = refs_addr
    Heap[refs_addr+3] = l_addr
}

function _listCreate(is_refs) {
    Heap[HeapTop++] = is_refs ? "refs" : "list"
    Heap[HeapTop++] = 0              # length
    Heap[HeapTop++] = InitialBuffer  # current allocation buffer
    HeapTop++                        # list ref
    HeapTop += InitialBuffer
}

function typeOf(var_name) {
    return Heap[addrOf(var_name)]
}

function listLen(var_name) {
    return Heap[addrOf(var_name)+1]
}

function listPush(list_name, var_name,   pl,pv,l) {
    pl = addrOf(list_name)
    pv = addrOf(var_name)

    l = Heap[pl+1]++  # length
    Heap[pl + ListServiceLen   + 2*l] = Heap[pv]
    Heap[pl + ListServiceLen+1 + 2*l] = Heap[pv+1]

    # TODO re-allocation
}

function listGet(list_name, idx) {
    return Heap[addrOf(list_name) + ListServiceLen + 2*idx + 1]
}

function listGetTypeOf(list_name, idx) {
    return Heap[addrOf(list_name) + ListServiceLen + 2*idx]
}

function heapDump(   i) {
    print "--- HEAP ---"
    for (i=0; i<HeapTop; i++)
        printf "%3d : %s\n", i, Heap[i]
}
