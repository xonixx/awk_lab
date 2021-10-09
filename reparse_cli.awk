BEGIN {
#  Trace=1
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
  err = reparseCli(line, res)
  if (err)
    print "error: " err
  else {
    for (i=0; i in res; i++) {
      print i ": " res[i]
    }
  }
}

#{ dbgLine("before"); reparseCli(); dbgLine("after") }

#function dbgLine(name, arr,   i) { print "--- " name ": "; for (i=1; i<=NF; i++) print i " : " $i }

# we will parse
# aaa  'bbb "\' ccc' dd -> [aaa],[bbb "' ccc],[dd]
# 'a\nb' -> [a\nb]      // only ' can be escaped, all rest is literal
# aaa'bbb'              -> error
# 'bbb'aaa              -> error
# 'aaa''bbb'            -> error
# 'bbb                  -> error
# a 'b # c' # comment   -> [a],[b # c] // parse comments

## res[-7] = res len
## res - 0-based
## returns error if any
function reparseCli(line, res,   pos,c,last) {
  for(;;) {
    trace(0,line,pos)
    while((c = substr(line,pos,1))==" " || c == "\t") pos++ # consume spaces
    trace(1,line,pos)
    if ((c = substr(line,pos,1))=="#" || c=="")
      return
    else if (c == "'") { # start of string
      # consume quoted string
      res[last = res[-7]++] = ""
      while((c = substr(line,++pos,1)) != "'") { # closing '
        trace(2,line,pos)
        if (c=="")
          return "unterminated argument"
        else if (c=="\\" && substr(line,pos+1,1)=="'") { # escaped '
          c = "'"; pos++
        }
        res[last] = res[last] c
      }
      trace(3,line,pos)
      if((c = substr(line,++pos,1)) != "" && c != " " && c != "\t")
        return "joined arguments"
    } else {
      # consume unquoted argument
      res[last = res[-7]++] = c
      while((c = substr(line,++pos,1)) != "" && c != " " && c != "\t") { # whitespace denotes end of arg
        trace(4,line,pos)
        res[last] = res[last] c
      }
    }
  }
}

function trace(m,t,pos) { if (Trace) printf "%10s pos %d: %s\n", m, pos, substr(t,pos,10) "..." }
