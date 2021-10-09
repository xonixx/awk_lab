BEGIN {
  #  Trace=1
  testCli("a")
  testCli(" 'aaa'\t  'bbb ccc'    # comment ")
  testCli(" aaa bbbb\t  ccccc")
  testCli(" 'aaa\\'\\'\"bbb'   ")
  testCli(" 'aaa\\bbb'   ")
  testCli(" 'aaa#bbb'   ")
}