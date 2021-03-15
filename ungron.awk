BEGIN {
    split("", Asm)

    while (getline > 0)
        arrPush(Asm, $0)

    for (i=0; i<arrLen(Asm); i++) {
        Instr = Asm[i];

        if("record" == Instr) {
            split("",Path)
            split("",Types)
            split("",Value) # [ type, value ]
        }
        else if (isSegmentType(Instr)) { arrPush(Types, Instr); arrPush(Path, Asm[++i]) }
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
function processRecord(    i,j,to_close,to_open) {
    print "=================="
    # 1. diff with prev
    # 2. find what removed -> generate end
    # 3. find what added   -> generate opens

    for (i=0; PrevPath[i] == Path[i]; i++) {}
    print "i " i
    for (j=i; j<arrLen(PrevPath); j++) arrPush(to_close,PrevPath[j])
    for (j=i; j<arrLen(    Path); j++) arrPush(to_open, Path[j])

    dbgA("PrevPath",PrevPath)
    dbgA("Path",Path)
    dbgA("to_close",to_close)
    dbgA("to_open",to_open)
    #dbgA("PrevTypes",PrevTypes)
    #dbgA("Types",Types)
    dbgA("Value",Value)

    arrSet(PrevPath,Path)
    arrSet(PrevTypes,Types)
}
function arrPush(arr, e) { arr[arr[-7]++] = e }
function arrLen(arr) { return arr[-7] }
function arrSet(target, source,    i) { split("",target); for(i in source) target[i] = source[i] }
function dbgA(name, arr,    i) { print "--- " name ": "; for (i=0; i<arrLen(arr); i++) print i " : " arr[i] }
