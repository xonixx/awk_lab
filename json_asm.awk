BEGIN {
    Depth = 0
    split("",Stack)
    Mode = ""
    WasEnd = 0
}

"object" == $1 && !isString() { Mode=$1; Stack[++Depth]="object"; p((WasEnd ? ",":"") "{"); WasEnd=0; next; }
"list"   == $1 && !isString() { Mode=$1; Stack[++Depth]="list";   p((WasEnd ? ",":"") "["); WasEnd=0; next; }
"string" == $1 && !isString() { Mode=$1;                                     next; }
"number" == $1 && !isString() { Mode=$1;                                     next; }
"true"   == $1 && !isString() { p((WasEnd ? ",":"")"true");  WasEnd=1;       next; }
"false"  == $1 && !isString() { p((WasEnd ? ",":"")"false"); WasEnd=1;       next; }
"null"   == $1 && !isString() { p((WasEnd ? ",":"")"null");  WasEnd=1;       next; }
"key"    == $1 && !isString() { Mode=$1;                                     next; }
"end"    == $1 && !isString() { p(Stack[Depth--]=="object" ? "}" : "]"); WasEnd=1; next; }
               Mode=="key"    { p((WasEnd ? "," : "") $1 ":"); Mode=""; WasEnd=0;  next; }
Mode=="number"||Mode=="string"{ p((WasEnd ? ",":"")$1); Mode="";                 WasEnd=1; next; }
               !$1            {                                              next; }
                              { print "Error at " FILENAME ":" NR; exit 1          }

function isString() { return Mode=="key" || Mode=="string" }
function p(s) { printf "%s", s }