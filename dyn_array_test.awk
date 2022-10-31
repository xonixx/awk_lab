
BEGIN {
  test()
}

function test(   a,it) {
  a = arrNew()
#  print "size0: " arrSize(a)
  assertEquals(0, arrSize(a), "wrong arrSize")

  assertEquals("",       arrSet(a, 1, 2))
  assertEquals("",       arrSet(a, "b", "BBB111"))
  assertEquals("BBB111", arrSet(a, "b", "BBB"))

  assertEquals(2, arrSize(a), "wrong arrSize 2")
  assertEquals(2, arrGet(a,1), "wrong arrGet 1")
  assertEquals("BBB", arrGet(a,"b"), "wrong arrGet b")
#  print "size: " arrSize(a)
#  print "1 -> " arrGet(a,1)
#  print "b -> " arrGet(a,"b")

  it = iterator(a)

  assertEquals(1, itNext(it))
  assertEquals(1, itGetKey(it), "key 1")
  assertEquals(2, itGetVal(it), "val 1")

  assertEquals(1, itNext(it))
  assertEquals("b", itGetKey(it), "key 2")
  assertEquals("BBB", itGetVal(it), "val 2")

  assertEquals(0, itNext(it))

#  for (it = iterator(a); itNext(it);) {
#    print itGetKey(it) " -> " itGetVal(it)
    #    print (key = itGetKey(it)) " -> " arrGet(a, key)
#  }
}