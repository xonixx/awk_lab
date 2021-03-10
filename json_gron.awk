BEGIN {
    Depth = 0
    split("",Stack)
    split("",PathStack)
    #split("",TypeStack) # segment/index
    Mode = ""
    Open["object"]="{" ; Close["object"]="}"
    Open["array"]="["   ; Close["array"]="]"
}

isComplex($1)                  { Mode=$1; p("object"==$1?"{}":"[]"); Stack[++Depth]=$1;   next; }
isValueHolder($1)              { Mode=$1;                                   next; }
isSingle($1)                   { p($1);                                     next; }
"end" == $1                    { Depth--;                                   next; }
Mode=="key"                    { PathStack[Depth]=$0;         Mode="";      next; }
Mode=="number"||Mode=="string" { p($0);                       Mode="";      next; }
!$1                            {                                            next; }
                               { print "Error at " FILENAME ":" NR; exit 1        }

function isSingle(s) { return "true"==s || "false"==s || "null"==s }
function isComplex(s) { return "object"==s || "array"==s }
function isValueHolder(s) { return "string"==s || "number"==s || "key"==s }

function p(v,    row,i) {
    row="json"
    for(i=0; i<=Depth; i++) {
        row= row (i==0?"":".") stringUnquote(PathStack[i])
    }
    row=row "=" v
    print row
}

function stringUnquote(text,    len)
{
	len  = length(text);
	text = len == 2 ? "" : substr(text, 2, len-2)

	gsub(/\\\\/, "\\", text)
	gsub(/\\"/,  "\"", text)
	gsub(/\\b/,  "\b", text)
	gsub(/\\f/,  "\f", text)
	gsub(/\\n/,  "\n", text)
	gsub(/\\r/,  "\r", text)
	gsub(/\\t/,  "\t", text)

    return text
}

# { "a": { "b" : "c", "d":"e" } }
# [ "a"     ,"b"     ]
# [ "object","object"]