BEGIN {
    Depth = 0
    split("",Stack)
    Mode = ""
    WasPrev = 0
}

"object" == $1 && !isString() { Mode=$1; Stack[++Depth]="object"; p((WasPrev ? ",":"") "{"); WasPrev=0; next; }
"list"   == $1 && !isString() { Mode=$1; Stack[++Depth]="list";   p((WasPrev ? ",":"") "["); WasPrev=0; next; }
"string" == $1 && !isString() { Mode=$1;                                                                next; }
"number" == $1 && !isString() { Mode=$1;                                                                next; }
"true"   == $1 && !isString() { p((WasPrev ? ",":"")"true");                                 WasPrev=1; next; }
"false"  == $1 && !isString() { p((WasPrev ? ",":"")"false");                                WasPrev=1; next; }
"null"   == $1 && !isString() { p((WasPrev ? ",":"")"null");                                 WasPrev=1; next; }
"key"    == $1 && !isString() { Mode=$1;                                     next; }
"end"    == $1 && !isString() { p(Stack[Depth--]=="object" ? "}" : "]");                     WasPrev=1; next; }
               Mode=="key"    { p((WasPrev ? "," : "") $1 ":"); Mode="";                     WasPrev=0; next; }
Mode=="number"||Mode=="string"{ p((WasPrev ? ",":"")$1); Mode="";                            WasPrev=1; next; }
               !$1            {                                              next; }
                              { print "Error at " FILENAME ":" NR; exit 1          }

function isString() { return Mode=="key" || Mode=="string" }
function p(s) { printf "%s", s }