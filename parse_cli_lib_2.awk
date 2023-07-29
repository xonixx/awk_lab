#
# parses: arg 'arg with spaces' $'arg with \' single quote'
#

## res[-7] = res len
## res - 0-based
## returns error if any
function parseCli_1(line, res,   pos,c,last,is_doll,c1) {
  for(pos=1;;) {
    trace(0,line,pos)
    while((c = substr(line,pos,1))==" " || c == "\t") pos++ # consume spaces
    trace(1,line,pos)
    if ((c = substr(line,pos,1))=="#" || c=="")
      return
    else {
      if ((is_doll = c == "$") && substr(line,pos+1,1)=="'" || c == "'") { # start of string
        if(is_doll)
          pos++
        # consume quoted string
        res[last = res[-7]++] = ""
        while((c = substr(line,++pos,1)) != "'") { # closing '
          trace(2,line,pos)
          if (c=="")
            return "unterminated argument"
          else if (is_doll && c=="\\" && ((c1=substr(line,pos+1,1))=="'" || c1==c)) { # escaped ' or \
            c = c1; pos++
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
          if(c=="'")
            return "joined arguments"
          res[last] = res[last] c
        }
      }
    }
  }
}

function trace(m,t,pos) { if (Trace) printf "%10s pos %d: %s\n", m, pos, substr(t,pos,10) "..." }
