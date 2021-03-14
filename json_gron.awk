BEGIN {
    split("", Asm); split("", LineNums)
    while ((getline Instr)>0) {
        Instr = trim(Instr)
        if (Instr!="") { Asm[AsmLen++] = Instr; LineNums[AsmLen] = NR }
    }

    split("",Stack)
    split("",PathStack)
    Depth = 0
    Mode = ""

    for (i=0; i<AsmLen; i++) {
        if (isComplex(Instr = Asm[i]))               { Mode=Instr;
                                                        p("object"==Instr?"{}":"[]");
                                                        Stack[++Depth]=Instr;
                                                        if (inArr()) { PathStack[Depth]=0 } }
else if (isValueHolder(Instr)             ) { Mode=Instr;                                   }
else if (isSingle(Instr)                  ) { p(Instr);          incArrIdx();               }
else if ("end" == Instr                   ) { Depth--;        incArrIdx();               }
else if (Mode=="key"                   ) { PathStack[Depth]=Instr;         Mode="";      }
else if (Mode=="number"||Mode=="string") { p(Instr);          incArrIdx(); Mode="";      }
        else { print "Error at " FILENAME ":" LineNums[i] ": " Instr; exit 1 }
    }
}

#isComplex($1)                  { Mode=$1;
#                                 p("object"==$1?"{}":"[]");
#                                 Stack[++Depth]=$1;
#                                 if (inArr()) { PathStack[Depth]=0 }        next; }
#isValueHolder($1)              { Mode=$1;                                   next; }
#isSingle($1)                   { p($1);          incArrIdx();               next; }
#"end" == $1                    { Depth--;        incArrIdx();               next; }
#Mode=="key"                    { PathStack[Depth]=$0;         Mode="";      next; }
#Mode=="number"||Mode=="string" { p($0);          incArrIdx(); Mode="";      next; }
#!$1                            {                                            next; }
#                               { print "Error at " FILENAME ":" NR; exit 1        }

function isSingle(s) { return "true"==s || "false"==s || "null"==s }
function isComplex(s) { return "object"==s || "array"==s }
function isValueHolder(s) { return "string"==s || "number"==s || "key"==s }
function inArr() { return "array"==Stack[Depth] }
function incArrIdx() { if (inArr()) PathStack[Depth]++ }

function p(v,    row,i,by_idx,segment,segment_unq) {
    row="json"
    for(i=1; i<=Depth; i++) {
        segment = PathStack[i]
        segment_unq = stringUnquote(segment)
        by_idx = "array"==Stack[i] || segment_unq !~ /^[[:alpha:]$_][[:alnum:]$_]*$/
        row= row (i==0||by_idx?"":".") (by_idx ? "[" segment "]" : segment_unq)
    }
    row=row "=" v # ";"
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

function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s; }