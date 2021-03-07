BEGIN {
    Json="{\"a\":\"b\"}"
    Pos=1
    QUOTE="\""
    split("", States)
    Depth=0

    # print tryParse("{"), Pos

    for(;;) {
        if (tryParse("{")) {
            json_asm("object");
            States[++Depth] = "object"
            StateKey=1
        } else if (tryParse("}")) {
            json_asm("end");
            Depth--
        } else if (tryParse(QUOTE)) {
            str=QUOTE
            while(nextChar() != QUOTE) { str = str advance1(); }
            str=str advance1()
            json_asm(StateKey=1 ? "key" : "string")
            json_asm(str)
        } else if (tryParse(":")) {
            StateKey = 0;
        }
    }
}

function currentState(s) { return States[Depth] == s }
function tryParse(s,    l) {
    l=length(s);
    if(substr(Json,Pos,l)==s) { Pos += l; return 1 }
    return 0
}
function nextChar() { return substr(Json,Pos,1) }
function advance1(  c) { c = nextChar(); Pos++; return c }

function json_asm(s) { print s }


