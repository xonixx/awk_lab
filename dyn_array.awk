BEGIN {
  DYN_ARR_IDX = 0
  split("", DYN_ARR_SIZE) # i     -> keys_count
  split("", DYN_ARR_KEYS) # i,j   -> key
  split("", DYN_ARR)      # i,key -> val
}

function newArr() { return ++DYN_ARR_IDX }
function arrSize(arr) { return DYN_ARR_SIZE[arr] }
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

function iterator(arr) {}
function itNext(it) {}
function itGetKey(it) {}
function itGetVal(it) {}


BEGIN {
  test()
}

function test(   a,it) {
  a = newArr()
  arrSet(a, 1, 2)
  arrSet(a, "b", "BBB")

  print "size: " arrSize(a)

  for (it = iterator(a); itNext(it);) {
    print itGetKey(it) " -> " itGetVal(it)
  }
}