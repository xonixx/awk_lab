BEGIN {
  #  Trace=1

  while (getline < "parse_cli_1.txt") {
    if (/^\|/) {
      if (!/\|$/) print "error: must end '|'"
#      print(substr($0,2,length-2))
      testCli_1(substr($0,2,length-2))
    }
  }

#  testCli_1("#comment")
#  testCli_1("a")
#  testCli_1("a#comment")
#  testCli_1(" 'aaa'\t  'bbb ccc'    # comment ")
#  testCli_1(" $'aaa'\t  $'bbb ccc'    # comment ")
#  testCli_1(" aaa bbbb\t  ccccc")
#  testCli_1(" $'aaa\\'\\'\"bbb'   ")
#  testCli_1(" 'aaa\\bbb'   ")
#  testCli_1(" 'aaa#bbb'   ")
#  testCli_1(" 'aaa\\'   ")
#  testCli_1(" $'aaa\\\\\\''   ")
#  # errors
#  testCli_1(" 'aaa   ")
#  testCli_1(" $'aaa\\'   ")
#  testCli_1("$'aa\\'a  # comment comment1")
#  testCli_1(" aaa'   ")
#  testCli_1("aaa'bb")
#  testCli_1("aaa'bb'   ")
#  testCli_1(" 'aaa''bb'")
#  testCli_1(" 'aaa'$'bb'")
#  testCli_1(" $'aaa''bb'")
#  testCli_1("'aaa'bb   ")
#  testCli_1("$'aaa'bb   ")
}

function testCli_1(line,   l,err,res,i) {
  print "================="
  l=line; gsub(/\t/,"\\t",l); print "|" l "|"
  print "-----------------"
  err = parseCli_1(line, res)
  if (err)
    print "error: " err
  else {
    for (i=0; i in res; i++) {
      print i ": " res[i]
    }
  }
  print "."
}