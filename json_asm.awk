BEGIN {
    Depth = 0
    split("",Stack)
    Mode = ""
    WasPrev = 0
    Open["object"]="{" ; Close["object"]="}"
    Open["list"]="["   ; Close["list"]="]"
}

isComplex($1)  && !isString() { Mode=$1; Stack[++Depth]=$1;  p1(Open[$1]); WasPrev=0; next; }
"string" == $1 && !isString() { Mode=$1;                                              next; }
"number" == $1 && !isString() { Mode=$1;                                              next; }
isSingle($1)   && !isString() { p1($1);                                    WasPrev=1; next; }
"key"    == $1 && !isString() { Mode=$1;                                              next; }
"end"    == $1 && !isString() { p(Close[Stack[Depth--]]);                  WasPrev=1; next; }
               Mode=="key"    { p1($1 ":"); Mode="";                       WasPrev=0; next; }
Mode=="number"||Mode=="string"{ p1($1); Mode="";                           WasPrev=1; next; }
               !$1            {                                                       next; }
                              { print "Error at " FILENAME ":" NR; exit 1                   }

function isString() { return Mode=="key" || Mode=="string" }
function isSingle(s) { return "true"==s || "false"==s || "null"==s }
function isComplex(s) { return "object"==s || "list"==s }
function p(s) { printf "%s", s }
function p1(s) { p((WasPrev ? "," : "") s) }