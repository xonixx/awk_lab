BEGIN {
  test("aaa", "aaa")
  test("aaa", "'aaa'",1)
  test("aaa b", "'aaa b'")
  test("aaa b", "'aaa b'",1)
  test("aaa \tb", "'aaa \tb'")
  test("aaa'b", "$'aaa\\'b'")
  test("aaa'b", "$'aaa\\'b'",1)
  test("'", "$'\\''")
  test("a\\b", "'a\\b'")
  test("\\'", "$'\\\\\\''")
}

function test(str,expected,force,   res, str1, script) {
  res = quote2(str,force)
  if (res != expected) {
    print "FAIL: [" str "] -> [" res "] expected:(" expected ")"
  } else {
    print "OK  : [" str "] -> [" expected "]"
    # check back
    script = "bash -c " quoteArg("echo " res)
#    print script
    script | getline str1
    close(script)
    if (str != str1) {
      print "  FAIL(back)  : expected[" str "]  actual[" str1 "]"
    }
  }
}

function quoteArg(a) { gsub("'", "'\\''", a); return "'" a "'" }

function quote2(s,force) {
  if (index(s,"'")) {
    gsub(/\\/,"\\\\",s)
    gsub(/'/,"\\'",s)
    return "$'" s "'"
  } else
    return force || s ~ /[ \t\\]/ ? "'" s "'" : s
}
