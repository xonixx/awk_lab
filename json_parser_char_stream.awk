# https://www.json.org/json-en.html
BEGIN {
  Trace="Trace" in ENVIRON

  split("", Asm)
  AsmLen=0

  if (ELEMENT()) {
    if ("" != getChar())
      die("Can't advance at pos " Pos ": " showPos())

    # print "Parsed: "
    for (i=0; i<AsmLen; i++)
      print Asm[i]
  } else
    die("Can't advance at pos " Pos ": " showPos())

    # print tryParseExact("{"), Pos
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
    tryParse1("\"",res) && asm(isKey ? "key" : "string") &&
    tryParseCharacters(res) &&
    tryParse1("\"",res) &&
    asm(res[0]))
}
function WS() {
  return attempt("WS") && checkRes("WS", tryParse("\t\n\r ")) || 1
}
function VALUE() {
  return attempt("VALUE") && checkRes("VALUE",
    OBJECT() ||
    ARRAY()  ||
    STRING() ||
    NUMBER() ||
    tryParseExact("true") && asm("true") ||
    tryParseExact("false") && asm("false") ||
    tryParseExact("null") && asm("null"))
}
function OBJECT() {
  return attempt("OBJECT") && checkRes("OBJECT",
    tryParse1("{") && asm("object") &&

    (WS() && tryParse1("}") ||

    MEMBERS() && tryParse1("}")) &&

    asm("end_object"))
}
function ARRAY() {
  return attempt("ARRAY") && checkRes("ARRAY",
    tryParse1("[") && asm("array") &&

    (WS() && tryParse1("]") ||

    ELEMENTS() && tryParse1("]")) &&

    asm("end_array"))
}
function MEMBERS() {
  return attempt("MEMBERS") && checkRes("MEMBERS", MEMBER() && (tryParse1(",") ? MEMBERS() : 1))
}
function ELEMENTS() {
  return attempt("ELEMENTS") && checkRes("ELEMENTS", ELEMENT() && (tryParse1(",") ? ELEMENTS() : 1))
}
function MEMBER() {
  return attempt("MEMBER") && checkRes("MEMBER", WS() && STRING(1) && WS() && tryParse1(":") && ELEMENT())
}
function ELEMENT() {
  return attempt("ELEMENT") && checkRes("ELEMENT", WS() && VALUE() && WS())
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
function die(msg) { print msg; exit 1 }
