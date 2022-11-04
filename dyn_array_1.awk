BEGIN {
  DYN_ARR_IDX = 0              # arr
  split("", DYN_ARR_SIZE)      # arr     -> keys_count
  split("", DYN_ARR_KEYS_NEXT) # arr,key -> key_next
  split("", DYN_ARR_KEYS_PREV) # arr,key -> key_prev
  split("", DYN_ARR_VALS)      # arr,key -> val

  # TODO how we represent null vs ""? For now "" as key is disallowed

  DYN_ARR_ITER_IDX = 0        # it
  split("", DYN_ARR_ITER_ARR) # it  -> arr
  split("", DYN_ARR_ITER_KEY) # it  -> currKey
}

function arrNew() { return ++DYN_ARR_IDX }
function arrSize(arr) { return +DYN_ARR_SIZE[arr] }
function arrGet(arr, key) { return DYN_ARR_VALS[arr,key] }

# returns prev val
function arrDel(arr, key,   oldVal,k,hasKey,a,b) {
  #  a -> key -> b  ---> a -> b
  hasKey = (k = arr SUBSEP key) in DYN_ARR_VALS
  if (hasKey) {
    DYN_ARR_SIZE[arr]--
    oldVal = DYN_ARR_VALS[k = arr SUBSEP key]
    delete DYN_ARR_VALS[k]

    a = DYN_ARR_KEYS_PREV[k]
    b = DYN_ARR_KEYS_NEXT[k]

    DYN_ARR_KEYS_NEXT[arr,a] = b
    DYN_ARR_KEYS_PREV[arr,b] = a

    delete DYN_ARR_KEYS_NEXT[k]
    delete DYN_ARR_KEYS_PREV[k]

    return oldVal
  }
}

# returns prev val
function arrSet(arr, key, val,   k,a,z,hasKey,oldVal) {
  hasKey = (k = arr SUBSEP key) in DYN_ARR_VALS
  oldVal = DYN_ARR_VALS[k]
  if (!hasKey) {   #  "" -> a  ---> "" -> key -> a
    DYN_ARR_SIZE[arr]++
    a = DYN_ARR_KEYS_NEXT[k] = DYN_ARR_KEYS_NEXT[z = arr SUBSEP ""]
    DYN_ARR_KEYS_NEXT[z] = key
    DYN_ARR_KEYS_PREV[k] = ""
    DYN_ARR_KEYS_PREV[a] = key
  }
  DYN_ARR_VALS[k] = val
  return oldVal
}

function iterator(arr,   it) {
  DYN_ARR_ITER_ARR[it = ++DYN_ARR_ITER_IDX] = arr
  DYN_ARR_ITER_KEY[it] = ""
  return it
}
function itNext(it) { return "" != (DYN_ARR_ITER_KEY[it] = DYN_ARR_KEYS_NEXT[DYN_ARR_ITER_KEY[it]])  }
function itGetKey(it) { return DYN_ARR_ITER_KEY[it] }
function itGetVal(it) { return DYN_ARR_VALS[DYN_ARR_ITER_ARR[it],itGetKey(it)] }
