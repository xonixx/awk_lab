BEGIN {
    Json="[123,\"Hello world\",true,false,null,{}]"
    # Json="{\"a\":\"b\",\"c\":{},\"d\":{\"e\":\"f\"}}"
    Pos=1
    QUOTE="\""
    split("", States)
    Depth=0

    # print tryParse("{"), Pos

    while(nextChar() != "") {
        if (tryParse("{")) {
            json_asm("object");
            States[++Depth] = "object"
            StateKey=1
        } else if (tryParse("[")) {
            json_asm("list");
            States[++Depth] = "list"
        } else if (tryParse("}") || tryParse("]")) {
            json_asm("end");
            Depth--
        } else if (tryParse(QUOTE)) {
            str=QUOTE
            while(nextChar() != QUOTE) { str = str advance1(); } # TODO naive
            str=str advance1()
            json_asm(StateKey==1 ? "key" : "string")
            json_asm(str)
        } else if (tryParse(":")) {
            StateKey = 0;
        } else if (tryParse(",")) {
            if (currentState("object")) StateKey = 1;
        } else if (tryParse("true")) {
            json_asm("true")
        } else if (tryParse("false")) {
            json_asm("false")
        } else if (tryParse("null")) {
            json_asm("null")
        } else if (tryParseNumber(res)) {
            json_asm("number")
            json_asm(res[0])
        } else { print "Can't advance at pos " Pos; exit 1 }
    }
}

function currentState(s) { return States[Depth] == s }
function tryParse(s,    l) {
    l=length(s);
    if(substr(Json,Pos,l)==s) { Pos += l; return 1 }
    return 0
}
function tryParseNumber(res,  c,num) {
    num=""
    while (index("0123456789", c = nextChar()) > 0) {
        num = num c
        Pos++
    }
    res[0]=num
    return num != ""
}
function nextChar() { return substr(Json,Pos,1) }
function advance1(  c) { c = nextChar(); Pos++; return c }

function json_asm(s) { print s }


