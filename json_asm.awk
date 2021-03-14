BEGIN {
    split("", Asm)
    while ((getline Instr)>0) {
        Instr = trim(Instr)
        if (Instr) Asm[AsmLen++] = Instr
    }

    Depth = 0
    split("",Stack)
    WasPrev = 0
    Open["object"]="{" ; Close["object"]="}"
    Open["array"]="["   ; Close["array"]="]"

    for (i=0; i<AsmLen; i++) {
        Instr = Asm[i];
        if(isComplex(Instr))           { Stack[++Depth]=Instr;  p1(Open[Instr]); WasPrev=0; }
        else if ("key"==Instr)       { p1(Asm[++i] ":"); Mode="";                       WasPrev=0; }
        else if ("number"==Instr||"string"==Instr) { p1(Asm[++i]);     Mode="";          WasPrev=1; }
        else if (isSingle(Instr))      { p1(Instr);                                    WasPrev=1;       }
        else if ("end" == Instr)       { p(Close[Stack[Depth--]]);                  WasPrev=1; }
        else                        { print "Error at " FILENAME ":" i ": " Instr; exit 1             }
    }
}

function isSingle(s) { return "true"==s || "false"==s || "null"==s }
function isComplex(s) { return "object"==s || "array"==s }
function p(s) { printf "%s", s }
function p1(s) { p((WasPrev ? "," : "") s) }
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s; }