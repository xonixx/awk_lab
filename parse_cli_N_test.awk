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

function testCli_N(line,   l,err,res,i,resBash,a,v,script,scriptBashed) {
  print "================="
  l = line; gsub(/\t/,"\\t",l); print "|" l "|"
  print "-----------------"
  err = parseAbstract(line, res)
  if (err)
    print "error: " err
  else {
    for (i = 0; i in res; i++) {
      print i ":" ((i SUBSEP "quote") in res ? res[i,"quote"]":" : "") " " res[i]
    }
    if (CompareToBash) {
      delete resBash
      for (v in Vars) {
        script = script v "=" Vars[v] "; "
      }
      script = script "./parse_cli_N_bashChecker.sh " line
      scriptBashed = "bash -c " quoteArg(script)
#      print "script: " script
      while (scriptBashed | getline a) {
        resBash[length(resBash)] = a
      }
      close(script)
      compareArrays(res,resBash,script)
    }
  }
  print "."
}
function quoteArg(a) { gsub("'", "'\\''", a); return "'" a "'" }
function compareArrays(res, resBash, script,   s1,s2) {
  s1 = arrToStr(res)
  s2 = arrToStr(resBash)
  if (s1 != s2) {
    print "NOT_MATCH:"
    print "  awk : " s1
    print "  bash: " s2
    print "script: " script
  }
}
function arrToStr(arr,   s,i) {
  for (i = 0; i in arr; i++)
    s = s arr[i] ","
  return s
}