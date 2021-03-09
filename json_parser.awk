# https://www.json.org/json-en.html
BEGIN {
    # Json="[123,-234.56E+10,\"Hello world\",true,false,null,{}]"
    # Json="{\"a\":\"b\",\"c\":{},\"d\":{\"e\":\"f\"}}"
    Json="{\"a\":\"b\",\"c\":{},\"d\":{\"e\":\"f\"},\"g\":[123,-234.56E+10,\"Hello world\",true,false,null,{}]}"
    # Json = "\"Hello world\""
    Pos=1
    QUOTE="\""
    split("", States)
    Depth=0

    # print tryParseExact("{"), Pos

    while(nextChar() != "") {
        res[0]=""

        if (tryParseExact("{")) {
            json_asm("object");
            States[++Depth] = "object"
            StateKey=1
        } else if (tryParseExact("[")) {
            json_asm("list");
            States[++Depth] = "list"
        } else if (tryParseExact("}") || tryParseExact("]")) {
            json_asm("end");
            Depth--
        } else if (tryParseString(res)) {
            json_asm(StateKey==1 ? "key" : "string")
            json_asm(res[0])
        } else if (tryParseExact(":")) {
            StateKey = 0;
        } else if (tryParseExact(",")) {
            if (currentState("object")) StateKey = 1;
        } else if (tryParseExact("true")) {
            json_asm("true")
        } else if (tryParseExact("false")) {
            json_asm("false")
        } else if (tryParseExact("null")) {
            json_asm("null")
        } else if (tryParseNumber(res)) {
            json_asm("number")
            json_asm(res[0])
        } else { print "Can't advance at pos " Pos ": " substr(Json,Pos,10) "..."; exit 1 }
    }
}

function currentState(s) { return States[Depth] == s }
function tryParseExact(s,    l) {
    l=length(s);
    if(substr(Json,Pos,l)==s) { Pos += l; return 1 }
    return 0
}
function tryParse1(chars, res) { return tryParse(chars,res,1) }
function tryParse(chars, res, atMost,    i,c,s) {
    s=""
    while (index(chars, c = nextChar()) > 0 && (atMost==0 || i++ < atMost)) {
        s = s c
        Pos++
    }
    res[0] = res[0] s
    return s != ""
}
function tryParseDigitOptional(res) { tryParse("0123456789", res); return 1 }
function tryParseNumber(res) {
    # https://stackoverflow.com/a/13340826/104522
    return (tryParse("-", res) || 1) &&
        (tryParse("0", res) || tryParse("123456789", res, 1) && tryParseDigitOptional(res)) &&
        (tryParse(".", res) && tryParseDigitOptional(res) || 1) &&
        (tryParse("eE", res, 1) && (tryParse("-+",res,1)||1) && tryParseDigitOptional(res) || 1)
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
function tryParseString(res) {
    return tryParse1(QUOTE,res) && tryParseCharacters(res) && tryParse1(QUOTE,res)
}
function nextChar() { return substr(Json,Pos,1) }
function advance1(  c) { c = nextChar(); Pos++; return c }
function d(rule) { print rule ": pos " Pos ": " substr(Json,Pos,10) "..."}

function json_asm(s) { print s }


