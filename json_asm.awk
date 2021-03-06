BEGIN {
    Depth = 0
    split("",Stack)
    Mode = ""
    WasPrev = 0
    Open["object"]="{"
    Open["list"]="["
}

isComplex($1)  && !isString() { Mode=$1; Stack[++Depth]=$1;  p((WasPrev ? ",":"") Open[$1]); WasPrev=0; next; }
"string" == $1 && !isString() { Mode=$1;                                                                next; }
"number" == $1 && !isString() { Mode=$1;                                                                next; }
isSingle($1)   && !isString() { p((WasPrev ? ",":"") $1);                                    WasPrev=1; next; }
"key"    == $1 && !isString() { Mode=$1;                                                                next; }
"end"    == $1 && !isString() { p(Stack[Depth--]=="object" ? "}" : "]");                     WasPrev=1; next; }
               Mode=="key"    { p((WasPrev ? "," : "") $1 ":"); Mode="";                     WasPrev=0; next; }
Mode=="number"||Mode=="string"{ p((WasPrev ? ",":"")$1); Mode="";                            WasPrev=1; next; }
               !$1            {                                                                         next; }
                              { print "Error at " FILENAME ":" NR; exit 1                                     }

function isString() { return Mode=="key" || Mode=="string" }
function isSingle(s) { return "true"==s || "false"==s || "null"==s }
function isComplex(s) { return "object"==s || "list"==s }
function p(s) { printf "%s", s }