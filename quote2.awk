BEGIN {
  test("aaa", "aaa")
  test("aaa", "'aaa'",1)
  test("aaa b", "'aaa b'")
  test("aaa b", "'aaa b'",1)
  test("aaa \tb", "'aaa \tb'")
  test("aaa'b", "$'aaa\\'b'")
  test("aaa'b", "$'aaa\\'b'",1)
  test("'", "$'\\''")
}

function test(str,expected,force,   res) {
  res = quote2(str,force)
  if (res != expected) {
    print "FAIL: [" str "] -> [" res "] expected:(" expected ")"
  } else
    print "OK  : [" str "] -> [" expected "]"
}

function quote2(s,force) {
  if (index(s,"'")) {
    gsub(/\\/,"\\\\",s)
    gsub(/'/,"\\'",s)
    return "$'" s "'"
  } else if (force || s ~ /[ \t]/) {
    return "'" s "'"
  } else
    return s
}
