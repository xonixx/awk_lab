# https://www.json.org/json-en.html
BEGIN {
    # Json="[123,-234.56E+10,\"Hello world\",true,false,null,{}]"
    # Json="{\"a\":\"b\",\"c\":{},\"d\":{\"e\":\"f\"}}"
    Json="{\"a\":\"b\"}"
    # Json="{\"a\":\"b\",\"c\":{},\"d\":{\"e\":\"f\"},\"g\":[123,-234.56E+10,\"Hello \\u1234 world\",true,false,null,{}]}"
    # Json = "\"Hello world\""
    Pos=1
    split("", States)
    Depth=0

    split("", Asm)
    AsmLen=0

    if (ELEMENT()) {
        if (Pos < length(Json)) {
            print "Can't advance at pos " Pos ": " substr(Json,Pos,10) "..."
            exit 1
        }
        print "Parsed: "
        for (i=0; i<AsmLen; i++)
            print Asm[i]
    }

    # print tryParseExact("{"), Pos

#    while(nextChar() != "") {
#        res[0]=""
#
#        if (tryParseExact("{")) {
#            json_asm("object");
#            States[++Depth] = "object"
#            StateKey=1
#        } else if (tryParseExact("[")) {
#            json_asm("list");
#            States[++Depth] = "list"
#        } else if (tryParseExact("}") || tryParseExact("]")) {
#            json_asm("end");
#            Depth--
#        } else if (STRING(res)) {
#            json_asm(StateKey==1 ? "key" : "string")
#            json_asm(res[0])
#        } else if (tryParseExact(":")) {
#            StateKey = 0;
#        } else if (tryParseExact(",")) {
#            if (currentState("object")) StateKey = 1;
#        } else if (tryParseExact("true")) {
#            json_asm("true")
#        } else if (tryParseExact("false")) {
#            json_asm("false")
#        } else if (tryParseExact("null")) {
#            json_asm("null")
#        } else if (NUMBER(res)) {
#            json_asm("number")
#            json_asm(res[0])
#        } else { print "Can't advance at pos " Pos ": " substr(Json,Pos,10) "..."; exit 1 }
#    }
}

function tryParseDigitOptional(res) { tryParse("0123456789", res); return 1 }
function NUMBER() {
    # https://stackoverflow.com/a/13340826/104522
    return (tryParse("-", res) || 1) &&
        (tryParse("0", res) || tryParse1("123456789", res) && tryParseDigitOptional(res)) &&
        (tryParse(".", res) && tryParseDigitOptional(res) || 1) &&
        (tryParse1("eE", res) && (tryParse1("-+",res)||1) && tryParseDigitOptional(res) || 1) &&
        asm("number") && asm(res[0])
}
function tryParseHex(res) { return tryParse1("0123456789ABCDEFabcdef", res) }
function tryParseCharacters(res) { return tryParseCharacter(res) && tryParseCharacters(res) || 1 }
function tryParseCharacter(res) { return tryParseNonEscapeChar(res) || tryParseEscapeChar(res) }
function tryParseEscapeChar(res) {
    return tryParse1("\\", res) &&
        (tryParse1("\\/bfnrt", res) || tryParse1("u", res) && tryParseHex(res) && tryParseHex(res) && tryParseHex(res) && tryParseHex(res))
}
function tryParseNonEscapeChar(res,   c) {
    c = nextChar()
    if (c != "\\" && c != "\"") { # TODO '0020' . '10FFFF' - '"' - '\'
        Pos++
        res[0] = res[0] c
        return 1
    }
    return 0
}
function STRING(isKey) {
    d("STRING" isKey)
    return tryParse1("\"",res) && asm(isKey ? "key" : "string") &&
        tryParseCharacters(res) &&
        tryParse1("\"",res) &&
        asm(res[0])
}
function WS() {
    d("WS")
    return tryParse("\t\n\r ") || 1
}
function VALUE() {
    d("VALUE")
    return OBJECT() ||
        ARRAY() ||
        STRING() ||
        NUMBER() ||
        tryParseExact("true") && asm("true") ||
        tryParseExact("false") && asm("false") ||
        tryParseExact("null") && asm("null")
}
function OBJECT() {
    d("OBJECT")
    return (save_pos() &&
        tryParse1("{") && asm("object") &&
        WS() &&
        tryParse1("}") &&
        asm("end") ||

        rewind() &&
        tryParse1("{") && asm("object") &&
        MEMBERS() &&
        (MEMBERS()) &&
        tryParse1("}") &&
        asm("end")) && s("OBJECT") || f("OBJECT")
}
function MEMBERS() {
    d("MEMBERS")
    return MEMBER() && (tryParse1(",") ? MEMBERS() : 1)
}
function MEMBER() {
    d("MEMBER")
    return WS() && STRING(1) && WS() && tryParse1(":") && ELEMENT()
}
function ARRAY() {
    return tryParse1("[") && asm("list") &&
        (WS() || ELEMENTS()) &&
        tryParse1("]") &&
        asm("end")
}
function ELEMENTS() {
    return ELEMENT() && (tryParse1(",") && ELEMENTS() || 1)
}
function ELEMENT() {
    d("ELEMENT")
    return WS() && VALUE() && WS() && s("ELEMENT") || f("ELEMENT")
}
# lib
function currentState(s) { return States[Depth] == s }
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
function advance1(  c) { c = nextChar(); Pos++; return c }
function save_pos() { PosSaved = Pos; return 1 }
function rewind() { Pos = PosSaved; return 1 }
function d(rule) { printf "%10s: pos %d: %s\n", rule, Pos, substr(Json,Pos,10) "..."}
function s(rule) { printf "%10s: pos %d: %s\n", "+" rule, Pos, substr(Json,Pos,10) "..."; return 1}
function f(rule) { printf "%10s: pos %d: %s\n", "-" rule, Pos, substr(Json,Pos,10) "..."; return 0}

function json_asm(s) { print s }
function asm(inst) { Asm[AsmLen++]=inst; return 1 }


