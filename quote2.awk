BEGIN {
  test("aaa", "aaa")
  test("aaa b", "'aaa b'")
  test("aaa \tb", "'aaa \tb'")
  test("aaa'b", "$'aaa\\'b'")
}

function test(str,expected,   res) {
  res = quote2(str)
  if (res != expected) {
    print "FAIL: [" str "] -> [" res "] expected:(" expected ")"
  } else
    print "OK  : [" str "] -> [" expected "]"
}

function quote2(s) {
  if (index(s,"'")) {
    gsub(/\\/,"\\\\",s)
    gsub(/'/,"\\'",s)
    return "$'" s "'"
  } else if (s ~ /[ \t]/) {
    return "'" s "'"
  } else
    return s
}
