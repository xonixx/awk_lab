
BEGIN {
    Depth = 0
    split("",Stack)
    Mode = ""
}

"object" == $1 && !isString() { Mode=$1; Stack[++Depth]="object"; print "{"; next; }
"list"   == $1 && !isString() { Mode=$1; Stack[++Depth]="list";   print "["; next; }
"string" == $1 && !isString() { Mode=$1;                                     next; }
"number" == $1 && !isString() { Mode=$1;                                     next; }
"true"   == $1 && !isString() { print "true";                                next; }
"false"  == $1 && !isString() { print "false";                               next; }
"null"   == $1 && !isString() { print "null";                                next; }
"key"    == $1 && !isString() { Mode=$1;                                     next; }
"end"    == $1 && !isString() { print(Stack[Depth--]=="object" ? "}" : "]"); next; }
                   isString() { print $1 (Mode=="key" ? ":" : ""); Mode="";        next; }
               Mode=="number" { print $1; Mode="";        next; }
               !$1            {                                             next; }
                              { print "Error at " FILENAME ":" NR; exit 1 }

function isString() { return Mode=="key" || Mode=="string" }