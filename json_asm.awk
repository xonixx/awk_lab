
BEGIN {
    Depth = 0
    split("",Stack)
    Mode = ""
    WasVal = 0
    WasEnd = 0
}

"object" == $1 && !isString() { Mode=$1; WasVal=0; Stack[++Depth]="object"; p((WasEnd ? ",":"") "{"); WasEnd=0; next; }
"list"   == $1 && !isString() { Mode=$1; WasVal=0; Stack[++Depth]="list";   p((WasEnd ? ",":"") "["); WasEnd=0; next; }
"string" == $1 && !isString() { Mode=$1;                                     next; }
"number" == $1 && !isString() { Mode=$1;                                     next; }
"true"   == $1 && !isString() { p("true");                                next; }
"false"  == $1 && !isString() { p("false");                               next; }
"null"   == $1 && !isString() { p("null");                                next; }
"key"    == $1 && !isString() { Mode=$1;                                     next; }
"end"    == $1 && !isString() { p(Stack[Depth--]=="object" ? "}" : "]"); WasEnd=1; next; }
               Mode=="key"    { p((WasVal ? "," : "") $1 ":"); Mode="";   next; }
Mode=="number"||Mode=="string"{ p($1); Mode="";                 WasVal=1; next; }
               !$1            {                                              next; }
                              { print "Error at " FILENAME ":" NR; exit 1          }

function isString() { return Mode=="key" || Mode=="string" }
function p(s) { printf "%s", s }