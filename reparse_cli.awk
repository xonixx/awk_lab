BEGIN {
  Pos
  Line
}

{ dbgLine("before"); reparseCli(); dbgLine("after") }

function dbgLine(name, arr,   i) { print "--- " name ": "; for (i=1; i<=NF; i++) print i " : " $i }

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
    pos = _consumeSpaces(line, pos)
    if ((c = substr(line,pos,1))=="#" || c=="")
      return
    else if (c == "'") { # consume string
      res[last = res[-7]++] = ""
      while((c = substr(line,++pos,1)) != "'") { # closing '
        if (c=="")
          return "unterminated argument"
        res[last] = res[last] c
      }
      if((c = substr(line,pos+1,1) != "" && c != " " && c != "\t"))
        return "joined arguments"
    }
  }
}

#function _addResChar(res, c) { res[res[-7]] =  }

function _consumeSpaces(line, pos,   c) {
  while((c = substr(line,pos,1))==" " || c == "\t") pos++;
  return pos;
}

function reparseCli_(res,   resIdx,state,pos,c,nxt,i) {
  Line = $0

  # States:
  #  external = 0
  #  inside ' = 1
  #  after \  = 2 <-- only inside string
  #


  state = 0
  pos = 1
  len = length(Line)
  resIdx = 0
  nxt = substr(Line,pos,1)
  for (pos=1; pos<=len; pos++) {
    c = nxt
    nxt = substr(Line,pos+1,1)

    if (0 == state) {
      if ("\\" == c) {
        state = 1
        resIdx++
      }
    } else if (1 == state) {

    } else if (2 == state) {

    }

    ###
    if ("\\" == c) {
      if (2 == state) {
        res[resIdx] = res[resIdx] c
      }
      else if (1 != state) { error("\\ outside string") }
      else {
        state = 2
      }
    }
    if ("\"" == c) {
      if (0 == state) {
        state = 1
        resIdx++
      } else if (1 == state) {
        state = 0
        if (pos<len) {
          pos++
          c = substr(Line,pos,1)
          if (" " != c && "\t" != c) error("should have space after \"")
        }
      } else if (2 == state) {
        res[resIdx] = res[resIdx] c
      } else error("unhandled state " state)
    } else {

    }
  }
  if (0 != state) { error("unbalanced string") }
}

function error(msg) { print msg | "cat 1>&2" }

#function reparseCli() {
#  Line = $0
#
#  Pos=1
#  Trace="Trace" in ENVIRON
#
#  if (LINE()) {
#    if (Pos <= length(Line)) {
#      print "Can't advance at pos " Pos ": " substr(Line,Pos,10) "..."
#      exit 1
#    }
#  } else
#    print "Can't advance at pos " Pos ": " substr(Line,Pos,10) "..."
#}

# LINE      ::= SPACES? ( (LINE_PART SPACES)* LINE_PART SPACES? )?
# LINE_PART ::= STRING | WORD
# SPACE     ::= ' ' | '\t'
# SPACES    ::= SPACE+
# WORD      ::= [^ \t]+

function WORD(res,   c,s) {
  while ((c = nextChar()) != " " && c != "\t") {
    s = s c
  }
  res[0] = s
  return s != ""
}

function LINE_PART(res) {
  return attempt("LINE_PART") && checkRes("LINE_PART", STRING(res) || WORD(res))
}

function LINE() {
  return attempt("LINE") && checkRes("LINE",
    optional(SPACES()) &&
    LINE_REST()) # TODO
}

function LINE_REST() {
  # can't consume LINE_PART -> 1
  # consume LINE_PART
  #   -> can't consume SPACES -> 1
  #   -> consume SPACES
  #        -> LINE_REST
  if (!LINE_PART(res)) return 1
  else {
    if (!SPACES()) return 1
    else return LINE_REST()
  }
}


function SPACES() {
  return attempt("SPACES") && checkRes("SPACES", tryParse("\t "))
}

function STRING(res) {
  return attempt("STRING") && checkRes("STRING",
    tryParse1("\"",res) &&
    tryParseCharacters(res) &&
    tryParse1("\"",res))
}

function tryParseHex(res) { return tryParse1("0123456789ABCDEFabcdef", res) }
function tryParseCharacters(res) { return tryParseCharacter(res) && tryParseCharacters(res) || 1 }
function tryParseCharacter(res) { return tryParseSafeChar(res) || tryParseEscapeChar(res) }
function tryParseEscapeChar(res) {
  return tryParse1("\\", res) &&
    (tryParse1("\\/bfnrt", res) || tryParse1("u", res) && tryParseHex(res) && tryParseHex(res) && tryParseHex(res) && tryParseHex(res))
}
function tryParseSafeChar(res,   c) {
  c = nextChar()
  # https://github.com/antlr/grammars-v4/blob/master/json/JSON.g4#L56
  # \x00 at end since looks like this is line terminator in macos awk(bwk?)
  if (0 == index("\"\\\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F\x00",c)) {
    Pos++
    res[0] = res[0] c
    return 1
  }
  return 0
}

# lib
function tryParseExact(s,    l) {
  l=length(s);
  if(substr(Line,Pos,l)==s) { Pos += l; return 1 }
  return 0
}
function tryParse1(chars, res) { return tryParse(chars,res,1) }
function tryParse(chars, res, atMost,    i,c,s) {
  s=""
  while (index(chars, c = nextChar()) > 0 &&
         (atMost==0 || i++ < atMost) &&
         Pos <= length(Line)) {
    s = s c
    Pos++
  }
  res[0] = res[0] s
  return s != ""
}
function nextChar() { return substr(Line,Pos,1) }
function checkRes(rule, r) { trace(rule (r?"+":"-")); return r }
function attempt(rule) { trace(rule "?"); return 1 }
function trace(x) { if (Trace){ printf "%10s pos %d: %s\n", x, Pos, substr(Line,Pos,10) "..."} }
function optional(r) { return 1 }

###

function stringUnquote(text,    len)
{
  len  = length(text);
  text = len == 2 ? "" : substr(text, 2, len-2)

  gsub(/\\\\/, "\\", text)
  gsub(/\\"/,  "\"", text)
  gsub(/\\b/,  "\b", text)
  gsub(/\\f/,  "\f", text)
  gsub(/\\n/,  "\n", text)
  gsub(/\\r/,  "\r", text)
  gsub(/\\t/,  "\t", text)

  return text
}