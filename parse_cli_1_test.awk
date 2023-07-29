BEGIN {
  #  Trace=1

  while (getline < "parse_cli_1.txt") {
    if (/^\|/) {
      if (!/\|$/) print "error: must end '|'"
      gsub(/\\t/,"\t",$0)
#      print(substr($0,2,length-2))
      testCli_1(substr($0,2,length-2))
    }
  }
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