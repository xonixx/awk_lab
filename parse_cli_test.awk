BEGIN {
  #  Trace=1
  testCli("a")
  testCli(" 'aaa'\t  'bbb ccc'    # comment ")
  testCli(" aaa bbbb\t  ccccc")
  testCli(" 'aaa\\'\\'\"bbb'   ")
  testCli(" 'aaa\\bbb'   ")
  testCli(" 'aaa#bbb'   ")
}

function testCli(line,   l,err,res,i) {
  print "================="
  l=line; gsub(/\t/,"\\t",l); print "|" l "|"
  print "-----------------"
  err = parseCli(line, res)
  if (err)
    print "error: " err
  else {
    for (i=0; i in res; i++) {
      print i ": " res[i]
    }
  }
}