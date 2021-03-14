BEGIN {
    split("", Asm)
    while ((getline Instr)>0)
        Asm[AsmLen++] = Instr

    Depth = 0
    split("",Stack)
    Mode = ""
    WasPrev = 0
    Open["object"]="{" ; Close["object"]="}"
    Open["array"]="["   ; Close["array"]="]"

    for (i=0; i<AsmLen; i++) {
        Instr = Asm[i];
        if(isComplex(Instr))           { Mode=Instr; Stack[++Depth]=Instr;  p1(Open[Instr]); WasPrev=0; }
        else if (isValueHolder(Instr)) { Mode=Instr;                                                    }
        else if (isSingle(Instr))      { p1(Instr);                                    WasPrev=1;       }
        else if ("end" == Instr)       { p(Close[Stack[Depth--]]);                  WasPrev=1; }
        else if (Mode=="key")       { p1(Instr ":"); Mode="";                       WasPrev=0; }
        else if (Mode=="number"||Mode=="string") { p1(Instr);     Mode="";          WasPrev=1; }
        else                        { print "Error at " FILENAME ":" i; exit 1             }
    }
}

function isSingle(s) { return "true"==s || "false"==s || "null"==s }
function isComplex(s) { return "object"==s || "array"==s }
function isValueHolder(s) { return "string"==s || "number"==s || "key"==s }
function p(s) { printf "%s", s }
function p1(s) { p((WasPrev ? "," : "") s) }