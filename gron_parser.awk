BEGIN {
  Trace="Trace" in ENVIRON

  split("", Asm)
  AsmLen=0
  Pos=1
  while (getline line > 0)
    In = In line "\n"
  if (STATEMENTS()) {
    if (Pos <= length(In))
      dieAtPos("Can't parse GRON")
      # print "Parsed: "
    for (i=0; i<AsmLen; i++)
      print Asm[i]
  } else
    dieAtPos("Can't parse GRON")
}

function die(msg) { print msg; exit 1 }
function dieAtPos(msg) { die(msg " at pos " Pos ": " posStr()) }
function esc(s) { gsub(/\n/, "\\n",s); return s }

function tryParseDigitOptional(res) { tryParse("0123456789", res); return 1 }
function NUMBER(    res) {
  return attempt("NUMBER") && checkRes("NUMBER",
    (tryParse1("-", res) || 1) &&
    (tryParse1("0", res) || tryParse1("123456789", res) && tryParseDigitOptional(res)) &&
    (tryParse1(".", res) && tryParseDigitOptional(res) || 1) &&
    (tryParse1("eE", res) && (tryParse1("-+",res)||1) && tryParseDigitOptional(res) || 1) &&
    asm("number") && asm(res[0]))
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
  if (0 == index("\"\\\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F",c)) {
    Pos++
    res[0] = res[0] c
    return 1
  }
  return 0
}
function STRING(isKey,    res) {
  return attempt("STRING" isKey) && checkRes("STRING" isKey,
    tryParse1("\"",res) && asm(isKey ? "field" : "string") &&
    tryParseCharacters(res) &&
    tryParse1("\"",res) &&
    asm(res[0]))
}
function VALUE_GRON() {
  return attempt("VALUE") && checkRes("VALUE",
    STRING() ||
    NUMBER() ||
    tryParseExact("true") && asm("true") ||
    tryParseExact("false") && asm("false") ||
    tryParseExact("null") && asm("null") ||
    tryParseExact("{}") && asm("object") ||
    tryParseExact("[]") && asm("array"))

}
function STATEMENTS() {
  attempt("STATEMENTS")
  for(tryParse("\n");nextChar();tryParse("\n")) {
    if (!STATEMENT())
      return checkRes("STATEMENTS",0)
  }
  return checkRes("STATEMENTS",1)
}
function STATEMENT() {
  return attempt("STATEMENT") && checkRes("STATEMENT",
    asm("record") &&
    PATH() && WS1() && tryParse1("=") && WS1() && asm("value") && VALUE_GRON() && (tryParse1(";")||1) &&
    asm("end"))
}
function WS1() { return tryParse("\t ") || 1 }
function PATH() {
  return attempt("PATH") && checkRes("PATH", BARE_WORD() && SEGMENTS())
}
function BARE_WORD(    word) {
  return attempt("BARE_WORD") && checkRes("BARE_WORD",
    tryParse1("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$_", word) &&
    (tryParse( "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$_0123456789", word) || 1) &&
    asm("field") && asm("\"" word[0] "\""))
}
function SEGMENTS() {
  return attempt("SEGMENTS") && checkRes("SEGMENTS", SEGMENT() && SEGMENTS()) || 1
}
function SEGMENT() {
  return attempt("SEGMENT") && checkRes("SEGMENT",
    tryParse1(".") && BARE_WORD() ||
    tryParse1("[") && KEY() && tryParse1("]"))
}
function KEY(    idx) {
  return attempt("KEY") && checkRes("KEY",
    tryParse("0123456789", idx) &&
    asm("index") && asm(idx[0]) ||
    STRING(1))
}
# lib
function tryParseExact(s,    l) {
  l=length(s)
  if(substr(In,Pos,l)==s) { Pos += l; return 1 }
  return 0
}
function tryParse1(chars, res) { return tryParse(chars,res,1) }
function tryParse(chars, res, atMost,    i,c,s) {
  s=""
  while (index(chars, c = nextChar()) > 0 &&
         (atMost==0 || i++ < atMost) &&
         "" != c) {
    s = s c
    Pos++
  }
  res[0] = res[0] s
  return s != ""
}
function nextChar() { return substr(In,Pos,1) }
function checkRes(rule, r) { trace(rule (r?"+":"-")); return r }
function attempt(rule) { trace(rule "?"); return 1 }
function trace(x) { if (Trace){ printf "%10s pos %d: %s\n", x, Pos, posStr()} }
function posStr(   s) { return esc(s = substr(In,Pos,10)) (10==length(s)?"...":"") }

function asm(inst) { Asm[AsmLen++]=inst; return 1 }
