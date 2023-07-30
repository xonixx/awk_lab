BEGIN {
  #  Trace=1
}

function runTestFile(file) {
  while (getline < file) {
    if (/^\|/) {
      if (!/\|$/) print "error: must end '|'"
      gsub(/\\t/,"\t",$0)
      #      print(substr($0,2,length-2))
      testCli_N(substr($0,2,length-2))
    }
  }
}

function testCli_N(line,   l,err,res,i) {
  print "================="
  l=line; gsub(/\t/,"\\t",l); print "|" l "|"
  print "-----------------"
  err = parseAbstract(line, res)
  if (err)
    print "error: " err
  else {
    for (i=0; i in res; i++) {
      print i ": " res[i]
    }
  }
  print "."
}