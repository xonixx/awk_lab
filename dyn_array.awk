BEGIN {
  DYN_ARR_IDX = 0
  split("", DYN_ARR_SIZE) # arr     -> keys_count
  split("", DYN_ARR_KEYS) # arr,j   -> key
  split("", DYN_ARR)      # arr,key -> val

  DYN_ARR_ITER_IDX = 0
  split("", DYN_ARR_ITER_ARR) # it  -> arr
  split("", DYN_ARR_ITER)     # it  -> currKeyIndex
}

function newArr() { return ++DYN_ARR_IDX }
function arrSize(arr) { return +DYN_ARR_SIZE[arr] }
function arrGet(arr, key) { return DYN_ARR[arr,key] }

# returns prev val
function arrDel(arr, key) {

}

# returns prev val
function arrSet(arr, key, val,   k,hasKey,oldVal) {
  hasKey = (k = arr SUBSEP key) in DYN_ARR
  oldVal = DYN_ARR[k]
  if (!hasKey) {
    DYN_ARR_KEYS[arr,DYN_ARR_SIZE[arr]++] = key
  }
  DYN_ARR[k] = val
  return oldVal
}

function iterator(arr,   it) {
  DYN_ARR_ITER_ARR[it = ++DYN_ARR_ITER_IDX] = arr
  DYN_ARR_ITER[it] = -1
  return it
}
function itNext(it) { return ++DYN_ARR_ITER[it] < DYN_ARR_SIZE[DYN_ARR_ITER_ARR[it]] }
function itGetKey(it,   arr) { return DYN_ARR_KEYS[arr=DYN_ARR_ITER_ARR[it],DYN_ARR_ITER[arr]] }
function itGetVal(it) { return DYN_ARR[DYN_ARR_ITER_ARR[it],itGetKey(it)] }


BEGIN {
  test()
}

function test(   a,it,key) {
  a = newArr()
  print "size0: " arrSize(a)
  arrSet(a, 1, 2)
  arrSet(a, "b", "BBB111")
  arrSet(a, "b", "BBB")

  print "size: " arrSize(a)
  print "1 -> " arrGet(a,1)
  print "b -> " arrGet(a,"b")

  for (it = iterator(a); itNext(it);) {
    print itGetKey(it) " -> " itGetVal(it)
    #    print (key = itGetKey(it)) " -> " arrGet(a, key)
  }
}