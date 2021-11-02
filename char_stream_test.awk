BEGIN {
  test()
}

function test(   c) {
  while ((c=getChar())!="") {
    print "[" c "]"
    advance()
  }
}