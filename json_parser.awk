# https://www.json.org/json-en.html
BEGIN {
    #Json="[123,-234.56E+10,\"Hello world\",true,false,null,{}]"
    #Json="{\"a\":\"b\",\"c\":{},\"d\":{\"e\":\"f\"}}"
    #Json="{\"a\":\"b\"}"
    Json="{\"a\":\"b\",\"c\":{},\"d\":{\"e\":\"f\"},\"g\":[123,-234.56E+10,\"Hello \\u1234 world\",true,false,null,{}]}"
    #Json = "\"Hello world\""
    #Json = "{}a"
    #Json = "---1...2"
    #Json = "-1."
    #Json = "\"\n\""
    #Json="[ [[[[],    {}]]]   ,[[{}]] ]"
    Pos=1
    Trace="Trace" in ENVIRON

    split("", Asm)
    AsmLen=0

    if (ELEMENT()) {
        if (Pos <= length(Json)) {
            print "Can't advance at pos " Pos ": " substr(Json,Pos,10) "..."
            exit 1
        }
        # print "Parsed: "
        for (i=0; i<AsmLen; i++)
            print Asm[i]
    } else
        print "Can't advance at pos " Pos ": " substr(Json,Pos,10) "..."

    # print tryParseExact("{"), Pos
}

function tryParseDigitOptional(res) { tryParse("0123456789", res); return 1 }
function NUMBER(    res) {
    d("NUMBER")
    return checkRes("NUMBER",
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
    d("STRING" isKey)
    return checkRes("STRING" isKey,
        tryParse1("\"",res) && asm(isKey ? "key" : "string") &&
        tryParseCharacters(res) &&
        tryParse1("\"",res) &&
        asm(res[0]))
}
function WS() {
    d("WS")
    return checkRes("WS", tryParse("\t\n\r ")) || 1
}
function VALUE() {
    d("VALUE")
    return checkRes("VALUE",
        OBJECT() ||
        ARRAY()  ||
        STRING() ||
        NUMBER() ||
        tryParseExact("true") && asm("true") ||
        tryParseExact("false") && asm("false") ||
        tryParseExact("null") && asm("null"))
}
function OBJECT() {
    d("OBJECT")
    return checkRes("OBJECT",
        tryParse1("{") && asm("object") &&

        (WS() && tryParse1("}") ||

        MEMBERS() && tryParse1("}")) &&

        asm("end"))
}
function ARRAY() {
    d("ARRAY")
    return checkRes("ARRAY",
        tryParse1("[") && asm("list") &&

        (WS() && tryParse1("]") ||

        ELEMENTS() && tryParse1("]")) &&

        asm("end"))
}
function MEMBERS() {
    d("MEMBERS")
    return checkRes("MEMBERS", MEMBER() && (tryParse1(",") ? MEMBERS() : 1))
}
function ELEMENTS() {
    d("ELEMENTS")
    return checkRes("ELEMENTS", ELEMENT() && (tryParse1(",") ? ELEMENTS() : 1))
}
function MEMBER() {
    d("MEMBER")
    return checkRes("MEMBER", WS() && STRING(1) && WS() && tryParse1(":") && ELEMENT())
}
function ELEMENT() {
    d("ELEMENT")
    return checkRes("ELEMENT", WS() && VALUE() && WS())
}
# lib
function tryParseExact(s,    l) {
    l=length(s);
    if(substr(Json,Pos,l)==s) { Pos += l; return 1 }
    return 0
}
function tryParse1(chars, res) { return tryParse(chars,res,1) }
function tryParse(chars, res, atMost,    i,c,s) {
    s=""
    while (index(chars, c = nextChar()) > 0 &&
            (atMost==0 || i++ < atMost) &&
            Pos <= length(Json)) {
        s = s c
        Pos++
    }
    res[0] = res[0] s
    return s != ""
}
function nextChar() { return substr(Json,Pos,1) }
function checkRes(rule, r) { r ? s(rule) : f(rule); return r }
function d(rule) { if (Trace){ printf "%10s pos %d: %s\n", rule "?", Pos, substr(Json,Pos,10) "..."} }
function s(rule) { if (Trace){ printf "%10s pos %d: %s\n", rule "+", Pos, substr(Json,Pos,10) "..." }; return 1 }
function f(rule) { if (Trace){ printf "%10s pos %d: %s\n", rule "-", Pos, substr(Json,Pos,10) "..." }; return 0 }

function asm(inst) { Asm[AsmLen++]=inst; return 1 }
