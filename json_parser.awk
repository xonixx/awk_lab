BEGIN {
    Json="{\"a\":\"b\"}"
    Pos=1

    print tryParse("{"), Pos
}

function tryParse(s,    l) {
    l=length(s);
    if(substr(Json,Pos,l)==s) { Pos += l; return 1 }
    return 0
}


