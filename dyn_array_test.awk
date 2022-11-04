
BEGIN {
  test()
}

function test(   a,it) {
  a = arrNew()
#  print "size0: " arrSize(a)
  assertEquals(0, arrSize(a), "wrong arrSize")

  assertEquals("",       arrSet(a, 1, 2))
#  dump(DYN_ARR_KEYS_NEXT,"DYN_ARR_KEYS_NEXT")
#  dump(DYN_ARR_KEYS_PREV,"DYN_ARR_KEYS_PREV")
  assertEquals("",       arrSet(a, "b", "BBB111"))
#  dump(DYN_ARR_KEYS_NEXT,"DYN_ARR_KEYS_NEXT")
#  dump(DYN_ARR_KEYS_PREV,"DYN_ARR_KEYS_PREV")
  assertEquals("BBB111", arrSet(a, "b", "BBB"))

  assertEquals(2, arrSize(a), "wrong arrSize 2")
  assertEquals(2, arrGet(a,1), "wrong arrGet 1")
  assertEquals("BBB", arrGet(a,"b"), "wrong arrGet b")
#  print "size: " arrSize(a)
#  print "1 -> " arrGet(a,1)
#  print "b -> " arrGet(a,"b")

  it = iterator(a)

  assertEquals(1, itNext(it), "next 0")
  assertEquals(1, itGetKey(it), "key 1")
  assertEquals(2, itGetVal(it), "val 1")

  assertEquals(1, itNext(it), "next 1")
  assertEquals("b", itGetKey(it), "key 2")
  assertEquals("BBB", itGetVal(it), "val 2")

  assertEquals(0, itNext(it), "next 2")

  assertEquals("BBB", arrDel(a, "b"), "wrond arrDel return val")
  assertEquals(1, arrSize(a))
  assertEquals(2, arrGet(a,1), "wrong arrGet 1 #2")
  assertEquals("", arrGet(a,"b"), "wrong arrGet b #2")

#  for (it = iterator(a); itNext(it);) {
#    print itGetKey(it) " -> " itGetVal(it)
    #    print (key = itGetKey(it)) " -> " arrGet(a, key)
#  }
}