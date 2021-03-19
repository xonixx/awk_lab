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

    listCreate("b")
    listPush("a", "b")

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

function listCreate(var_name,   list_addr, refs_addr) {
    Vars[var_name] = list_addr = HeapTop
    _listCreate(0)
    refs_addr = HeapTop
    _listCreate(1)
    _setRefAddr(list_addr, refs_addr)
    _setRefAddr(refs_addr, list_addr)
}

function _setRefAddr(list_addr, refs_addr) { Heap[list_addr+3] = refs_addr }
function _getRefAddr(list_addr) { return Heap[list_addr+3] }

function _listCreate(is_refs) {
    Heap[HeapTop++] = is_refs ? "refs" : "list"
    Heap[HeapTop++] = 0              # length
    Heap[HeapTop++] = InitialBuffer  # current allocation buffer
    HeapTop++                        # list ref
    HeapTop += InitialBuffer
}

function typeOf(var_name) {
    return _typeOf(addrOf(var_name))
}

function _typeOf(var_addr) { return Heap[var_addr] }
function _valOf(var_addr) { return _typeOf(var_addr) == "list" ? var_addr : Heap[var_addr+1] }

function listLen(var_name) {
    return Heap[addrOf(var_name)+1]
}

function listPush(list_name, var_name,   list_addr, var_addr) {
    list_addr = addrOf(list_name)
    var_addr = addrOf(var_name)

    _listPush(list_addr, _typeOf(var_addr), _valOf(var_addr))
}

function _listPush(list_addr, type, val,   l, i) {
    print ">>> ", list_addr, type, val
    l = Heap[list_addr+1]++  # length
    Heap[i = list_addr + ListServiceLen   + 2*l] = type
    Heap[i+1] = val

    if (type == "list")
        _listPush(_getRefAddr(val), "primitive", i+1)

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
