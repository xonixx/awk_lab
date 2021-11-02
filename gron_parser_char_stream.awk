BEGIN {
  Trace="Trace" in ENVIRON

  split("", Asm)
  AsmLen=0

  if (STATEMENTS()) {
    if ("" != getChar()) {
      print "Can't advance at pos " Pos ": " showPos()
      exit 1
    }
    # print "Parsed: "
    for (i=0; i<AsmLen; i++)
      print Asm[i]
  } else
    print "Can't advance at pos " Pos ": " showPos()
}

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
  c = getChar()
  # https://github.com/antlr/grammars-v4/blob/master/json/JSON.g4#L56
  # \x00 at end since looks like this is line terminator in macos awk(bwk?)
  if (0 == index("\"\\\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F\x00",c)) {
    advance()
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
function VALUE() {
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
  for(;;) {
    STATEMENT()
    if (!tryParse1("\n"))
      break
  }
  return 1
}
function STATEMENT() {
  return attempt("STATEMENT") && checkRes("STATEMENT",
    asm("record") && PATH() && tryParse1("=") && asm("value") && VALUE() && asm("end"))
}
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
function tryParseExact(s,    l, i) {
  #  if(substr(In,Pos,l=length(s))==s) { Pos += l; return 1 }
  #  return 0
  l=length(s)
  for (i=1;i<=l;i++) {
    if (getChar()!=substr(s,i,1))
      return 0
    advance()
  }
  return 1
}
function tryParse1(chars, res) { return tryParse(chars,res,1) }
function tryParse(chars, res, atMost,    i,c,s) {
  s=""
  while (index(chars, c = getChar()) > 0 &&
         (atMost==0 || i++ < atMost) &&
         "" != c) {
    s = s c
    advance()
  }
  res[0] = res[0] s
  return s != ""
}
function checkRes(rule, r) { trace(rule (r?"+":"-")); return r }
function attempt(rule) { trace(rule "?"); return 1 }
function trace(x) { if (Trace){ printf "%10s pos %d: %s\n", x, PosInLine, showPos()} } # TODO showPos() is wrong here
function showPos(   s,i) {
  for (i=0;i<10;i++) { s = s sprintf("%s", getChar()); advance() }
  return s "..."
}

function asm(inst) { Asm[AsmLen++]=inst; return 1 }
