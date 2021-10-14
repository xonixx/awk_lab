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

  # https://www.cs.ait.ac.th/~on/O/oreilly/unix/upt/ch08_19.htm
  test("a*b", "'a*b'")
  test("a$b", "'a$b'")
  test("a&b", "'a&b'")
  test("a|b", "'a|b'")
  test("a(b", "'a(b'")
  test("a)b", "'a)b'")
  test("a#b", "'a#b'")
  test("a!b", "'a!b'")
  test("a;b", "'a;b'")
  test("a\"b", "'a\"b'")
  test("a`b", "'a`b'")
  test("a?b", "'a?b'")
  test("a^b", "'a^b'")
  test("a>b", "'a>b'")
  test("a<b", "'a<b'")
  test("a~b", "'a~b'")
  test("a{b", "'a{b'") # echo test{1,2,3} -> test1 test2 test3
  ###
  test("@a.,b_c+-=d/e", "@a.,b_c+-=d/e")
  test("@a.,b_c+-=d/e", "'@a.,b_c+-=d/e'",1)
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
    return force || s ~ /[^a-zA-Z0-9.,@_\/=+-]/ ? "'" s "'" : s
}
