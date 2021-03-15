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
    print "JSON asm:"
    for (i=0; i<AsmLen; i++)
        print Asm[i]
}

function isSegmentType(s) { return "field" ==s || "index" ==s }
function isValueHolder(s) { return "string"==s || "number"==s }
function processRecord(    i,j, to_close,to_close_types, to_open,to_open_types) {
    print "=================="
    # 1. diff with prev
    # 2. find what removed -> generate to_close
    # 3. find what added   -> generate to_open

    for (i=0; PrevPath[i] == Path[i]; i++) {}
    # print "i " i
    for (j=i; j<arrLen(PrevPath); j++) { arrPush(to_close,PrevPath[j]); arrPush(to_close_types,PrevTypes[j]); }
    for (j=i; j<arrLen(    Path); j++) { arrPush(to_open, Path[j])    ; arrPush(to_open_types, Types[j]); }

    dbgA("PrevPath",PrevPath)
    dbgA("Path",Path)
    dbgA("to_close",to_close)
    dbgA("to_open",to_open)
    #dbgA("PrevTypes",PrevTypes)
    dbgA("Types",Types)
    dbgA("Value",Value)

    for (i=0; i<arrLen(to_close); i++) {

    }
    for (i=0; i<arrLen(to_open); i++) {

    }

    arrSet(PrevPath,Path)
    arrSet(PrevTypes,Types)
}
function asm(inst) { Asm[AsmLen++]=inst; return 1 }
function arrPush(arr, e) { arr[arr[-7]++] = e }
function arrLen(arr) { return arr[-7] }
function arrSet(target, source,    i) { split("",target); for(i in source) target[i] = source[i] }
function dbgA(name, arr,    i) { print "--- " name ": "; for (i=0; i<arrLen(arr); i++) print i " : " arr[i] }
