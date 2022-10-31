BEGIN {
  DYN_ARR_IDX = 0         # arr
  split("", DYN_ARR_SIZE) # arr     -> keys_count
  split("", DYN_ARR_KEYS) # arr,j   -> key
  split("", DYN_ARR_VALS) # arr,key -> val

  DYN_ARR_ITER_IDX = 0        # it
  split("", DYN_ARR_ITER_ARR) # it  -> arr
  split("", DYN_ARR_ITER)     # it  -> currKeyIndex
}

function arrNew() { return ++DYN_ARR_IDX }
function arrSize(arr) { return +DYN_ARR_SIZE[arr] }
function arrGet(arr, key) { return DYN_ARR_VALS[arr,key] }

# returns prev val
function arrDel(arr, key) {

}

# returns prev val
function arrSet(arr, key, val,   k,hasKey,oldVal) {
  hasKey = (k = arr SUBSEP key) in DYN_ARR_VALS
  oldVal = DYN_ARR_VALS[k]
  if (!hasKey) {
    DYN_ARR_KEYS[arr,DYN_ARR_SIZE[arr]++] = key
  }
  DYN_ARR_VALS[k] = val
  return oldVal
}

function iterator(arr,   it) {
  DYN_ARR_ITER_ARR[it = ++DYN_ARR_ITER_IDX] = arr
  DYN_ARR_ITER[it] = -1
  return it
}
function itNext(it) { return ++DYN_ARR_ITER[it] < DYN_ARR_SIZE[DYN_ARR_ITER_ARR[it]] }
function itGetKey(it,   arr) { return DYN_ARR_KEYS[arr=DYN_ARR_ITER_ARR[it],DYN_ARR_ITER[arr]] }
function itGetVal(it) { return DYN_ARR_VALS[DYN_ARR_ITER_ARR[it],itGetKey(it)] }
