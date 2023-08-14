#
# parses: arg 'arg with spaces' $'arg with \' single quote' "arg ${WITH} $VARS"
#

## res[-7] = res len
## res - 0-based
## returns error if any
function parseCli_2(line, vars, res,   pos,c,last,is_doll,c1,q,var) {
  for (pos = 1; ;) {
    trace(0,line,pos)
    while ((c = substr(line,pos,1)) == " " || c == "\t") pos++ # consume spaces
    trace(1,line,pos)
    if (c == "#" || c == "")
      return
    else {
      if ((is_doll = (q = c) == "$") && (q = substr(line,pos + 1,1)) == "'" || q == "'" || q == "\"") { # start of string
        if (is_doll)
          pos++
        # consume quoted string
        res[last = res[-7]++] = ""
        while ((c = substr(line,++pos,1)) != q) { # closing ' or "
          trace(2,line,pos)
          if (c == "")
            return "unterminated argument"
          else if (c == "\\" && ((c1 = substr(line,pos + 1,1)) == "'" && is_doll || c1 == c || q == "\"" && (c1 == q || c1 == "$"))) { # escaped ' or \ or "
            c = c1; pos++
          } else if (c == "$" && q == "\"") {
            var = ""
            if ((c1 = substr(line,pos + 1,1)) == "{") {
              pos++
              while ((c = substr(line,++pos,1)) != "}") # closing }
                var = var c
            } else {
              while ((c = substr(line,++pos,1)) ~ /[_A-Za-z0-9]/)
                var = var c
              pos--
            }
#            print "var="var
            if (var !~ /^[_A-Za-z][_A-Za-z0-9]*$/)
              return "wrong var"
            res[last] = res[last] vars[var]
            continue
          }
          res[last] = res[last] c
        }
        trace(3,line,pos)
        if ((c = substr(line,++pos,1)) != "" && c != " " && c != "\t")
          return "joined arguments"
      } else {
        # consume unquoted argument
        res[last = res[-7]++] = c
        while ((c = substr(line,++pos,1)) != "" && c != " " && c != "\t") { # whitespace denotes end of arg
          trace(4,line,pos)
          if (c == "'")
            return "joined arguments"
          res[last] = res[last] c
        }
      }
    }
  }
}

function trace(m,t,pos) { if (Trace) printf "%10s pos %d: %s\n", m, pos, substr(t,pos,10) "..." }
