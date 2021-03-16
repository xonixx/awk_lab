BEGIN {
    split("", Asm)

    while (getline > 0)
        arrPush(Asm, $0)

    split("", AddrType)  # addr -> type
    split("", AddrValue) # addr -> value
    split("", AddrCount) # addr -> segment count
    split("", AddrStart) # addr -> segment storage pointer
    split("", Segments)

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
    dbg("AddrType",AddrType)
    dbg("AddrValue",AddrValue)
    dbg("AddrCount",AddrCount)
    dbg("AddrStart",AddrStart)
    dbgA("Segments",Segments)
    print "JSON asm:"
    for (i=0; i<AsmLen; i++)
        print Asm[i]
}

function isSegmentType(s) { return "field" ==s || "index" ==s }
function isValueHolder(s) { return "string"==s || "number"==s }
function processRecord(   l, addr, type, value, i, segments_pos) {
    print "=================="
    dbgA("Path",Path)
    dbgA("Types",Types)
    dbgA("Value",Value)
    l = arrLen(Path)
    addr=""
    segments_pos = arrLen(Segments)
    for (i=0; i<l; i++) {
        # build addr
        addr = addr (i>0?",":"") Path[i]
        type = i<l-1 ? (Types[i+1] == "field" ? "object" : "array") : Value[0]
        value = i<l-1 ? "" : Value[1]
        if (addr in AddrType && type != AddrType[addr]) {
            die("Conflicting types for " addr ": " type " and " AddrType[addr])
        }
        AddrType[addr] = type
        AddrValue[addr] = value
        AddrCount[addr] = i+1
        AddrStart[addr] = segments_pos
        arrPush(Segments, Path[i])
    }
}
function asm(inst) { Asm[AsmLen++]=inst; return 1 }
function arrPush(arr, e) { arr[arr[-7]++] = e }
function arrLen(arr) { return 0 + arr[-7] }
function die(msg) { print msg; exit 1 }
#function arrSet(target, source,    i) { split("",target); for(i in source) target[i] = source[i] }
function dbgA(name, arr,    i) { print "--- " name " ---"; for (i=0; i<arrLen(arr); i++) print i " : " arr[i] }
function dbg(name, arr,    i, j, k, maxlen, keys) {
    print "--- " name " ---";
    for (k in arr) { keys[i++] = k; if (maxlen < (j = length(k))) maxlen = j }
    quicksort(keys,0,i-1)
    for (j=0; j<i; j++) { k = keys[j]; printf "%-" maxlen "s : %s\n", k, arr[k] }
}
function quicksort(data, left, right,   i, last) {
    if (left >= right)
      return

    quicksort_swap(data, left, int((left + right) / 2))
    last = left
    for (i = left + 1; i <= right; i++)
      if (data[i] <= data[left])
        quicksort_swap(data, ++last, i)
    quicksort_swap(data, left, last)
    quicksort(data, left, last - 1)
    quicksort(data, last + 1, right)
}
function quicksort_swap(data, i, j,   temp) {
    temp = data[i]
    data[i] = data[j]
    data[j] = temp
}
