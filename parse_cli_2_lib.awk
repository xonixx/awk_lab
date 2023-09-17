#
# parses: arg 'arg with spaces' $'arg with \' single quote' "arg ${WITH} $VARS"
#
## res[-7] = res len
## res - 0-based
## returns error if any
function parseCli_2(line, vars, res,   pos,c,c1,isDoll,q,var,inDef,defVal,val,w,i) {
  for (pos = 1; ;) {
    trace(0,line,pos)
    while ((c = substr(line,pos,1)) == " " || c == "\t") pos++ # consume spaces
    trace(1,line,pos)
    if (c == "#" || c == "")
      return
    else {
      if ((isDoll = substr(line,pos,2) == "$'") || c == "'" || c == "\"") { # start of string
        if (isDoll)
          pos++
        q = isDoll ? "'" : c # quote
        # consume quoted string
        w = ""
        while ((c = substr(line,++pos,1)) != q) { # closing ' or "
          trace(2,line,pos)
          if (c == "")
            return "unterminated argument"
          else if (c == "\\" && ((c1 = substr(line,pos + 1,1)) == "'" && isDoll || c1 == c || q == "\"" && (c1 == q || c1 == "$"))) { # escaped ' or \ or "
            c = c1; pos++
          } else if (c == "$" && q == "\"") {
            var = ""
            inDef = 0
            defVal = ""
            if ((c1 = substr(line,pos + 1,1)) == "{") {
              for (pos++; (c = substr(line,++pos,1)) != "}";) { # till closing '}'
                if (c == "")
                  return "unterminated argument"
                if (!inDef && ":" == c && "-" == substr(line,pos + 1,1)) {
                  inDef = 1
                  c = substr(line,pos += 2,1)
                }
                if (inDef) {
                  if ("}" == c)
                    break
                  if ("\\" == c && ((c1 = substr(line,pos+1,1)) == "$" || c1 == "\\" || c1 == "}" || c1 == "\"")) {
                    c = c1; pos++
                  }
                  defVal = defVal c
                } else
                  var = var c
              }
            } else
              for (; (c = substr(line,pos + 1,1)) ~ /[_A-Za-z0-9]/; pos++)
                var = var c
            #            print "var="var
            if (var !~ /^[_A-Za-z][_A-Za-z0-9]*$/)
              return "wrong var: '" var "'"
            w = w ((val = vars[var]) != "" ? val : defVal)
            continue
          }
          w = w c
        }
        res[i=+res[-7]++,"quote"] = isDoll ? "$" : q
        res[i] = w
        trace(3,line,pos)
        if ((c = substr(line,++pos,1)) != "" && c != " " && c != "\t")
          return "joined arguments"
      } else {
        # consume unquoted argument
        w = c
        while ((c = substr(line,++pos,1)) != "" && c != " " && c != "\t") { # whitespace denotes the end of arg
          trace(4,line,pos)
          w = w c
        }
        if (w !~ /^[_A-Za-z0-9@]+$/)
          return "wrong unquoted: '" w "'"
        res[i=+res[-7]++,"quote"] = "u"
        res[i] = w
      }
    }
  }
}

function trace(m,t,pos) { if (Trace) printf "%10s pos %d: %s\n", m, pos, substr(t,pos,10) "..." }
