BEGIN {
    split("", Asm)

    while (getline Instr > 0)
        arrPush(Asm, Instr)

    for (i=0; i<arrLen(Asm); i++) {
        Instr = Asm[i];

        if("record" == Instr) {
            split("",Path)
            split("",Types)
            split("",Value) # [ type, value ]
            Depth=0
        }
        else if (isSegmentType(Instr)) { Types[++Depth]=Instr; Instr = Asm[++i]; Path[Depth]=Instr; }
        else if ("value" == Instr) {
            Instr = Asm[++i];
            split("",Value)
            Value[0] = Instr
            if (isValueHolder(Instr))
                Value[1] = Asm[++i]
        } else if ("end" == Instr) { processRecord() }
    }
}

function isSegmentType(s) { return "field" ==s || "index" ==s }
function isValueHolder(s) { return "string"==s || "number"==s }
function processRecord() {
    print "=================="
    dbgA("Path",Path)
    dbgA("Types",Types)
    dbgA("Value",Value)
}
function arrPush(arr, e) { arr[arr[-7]++] = e }
function arrLen(arr) { return arr[-7] }
function arrSet(target, source,    i) { split("",target); for(i in source) target[i] = source[i] }
function dbgA(name, arr,    i) { print "--- " name ": "; for (i in arr) print i " : " arr[i] }
