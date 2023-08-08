BEGIN {
  #  Trace=1
}

function runTestFile(file) {
  while (getline < file) {
    if (/^\|/) {
      if (!/\|$/) print "error: must end '|'"
      gsub(/\\t/,"\t",$0)
      #      print(substr($0,2,length-2))
      testCli_N(substr($0,2,length - 2))
    }
  }
}

function testCli_N(line,   l,err,res,i,resBash,a) {
  print "================="
  l = line; gsub(/\t/,"\\t",l); print "|" l "|"
  print "-----------------"
  err = parseAbstract(line, res)
  if (err)
    print "error: " err
  else {
    for (i = 0; i in res; i++) {
      print i ": " res[i]
    }
    if (CompareToBash) {
      delete resBash
      script = "./parse_cli_N_bashChecker.sh " line
      while (script | getline a) {
        resBash[length(resBash)] = a
      }
      close(script)
      compareArrays(res,resBash)
    }
  }
  print "."
}
function compareArrays(res, resBash,   s1,s2) {
  s1 = arrToStr(res)
  s2 = arrToStr(resBash)
  if (s1 != s2) {
    print "NOT_MATCH:"
    print "  awk : " s1
    print "  bash: " s2
  }
}
function arrToStr(arr,   s,i) {
  for (i = 0; i in arr; i++)
    s = s arr[i] ","
  return s
}