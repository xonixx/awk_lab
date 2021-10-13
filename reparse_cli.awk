{
  dbgLine("before")
  reparseCli()
  dbgLine("after")
}

function dbgLine(name,   i) { print "--- " name ": "; for (i=1; i<=NF; i++) print i " : " $i }

function reparseCli(   res,i,err) {
  err = parseCli($0, res)
  if (err)
    print "error: " err
  else
    for (i=NF=0; i in res; i++)
      $(++NF)=res[i]
}
