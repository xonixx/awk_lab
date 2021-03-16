BEGIN {
    Trace="Trace" in ENVIRON

    split("", Asm)

    while (getline > 0)
        arrPush(Asm, $0)

    split("", AddrType)  # addr -> type
    split("", AddrValue) # addr -> value
    split("", AddrCount) # addr -> segment count
    split("", AddrKey)   # addr -> last segment name

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
    generateAsm()
    if (Trace) print "--- JSON asm ---"
    for (i=0; i<AsmLen; i++)
        print Asm[i]
}

function isComplex(s) { return "object"==s || "array"==s }
function isSegmentType(s) { return "field" ==s || "index" ==s }
function isValueHolder(s) { return "string"==s || "number"==s }
function processRecord(   l, addr, type, value, i) {
    if (Trace) print "=================="
    dbgA("Path",Path)
    dbgA("Types",Types)
    dbgA("Value",Value)
    l = arrLen(Path)
    addr=""
    for (i=0; i<l; i++) {
        # build addr
        addr = addr (i>0?",":"") (Types[i] == "index" ? sprintf("%010d",Path[i]) : Path[i]) # proper sorting for index values
        type = i<l-1 ? (Types[i+1] == "field" ? "object" : "array") : Value[0]
        value = i<l-1 ? "" : Value[1]
        if (addr in AddrType && type != AddrType[addr]) {
            die("Conflicting types for " addr ": " type " and " AddrType[addr])
        }
        AddrType[addr] = type
        AddrValue[addr] = value
        AddrCount[addr] = i+1
        AddrKey[addr] = Path[i]
    }
}
function generateAsm(   i,j,l, a,a1, addrs) {
    dbg("AddrType",AddrType)
    dbg("AddrValue",AddrValue)
    dbg("AddrCount",AddrCount)
    dbg("AddrKey",AddrKey)

    for (a in AddrType) arrPush(addrs, a)
    quicksort(addrs, 0, (l=arrLen(addrs))-1)
    for (i=0; i<l; i++) {
        a = addrs[i]
        if (i>0) {
            for (j=0; j<AddrCount[addrs[i-1]]-AddrCount[a]; j++)
                asm("end")
            # determine the type of current container (object/array) - for array should not issue "key"
            for (j=i; AddrCount[a]-AddrCount[a1=addrs[j]] != 1; j--) {} # descend to addr of prev segment
            if ("array" != AddrType[a1]) {
                asm("key")
                asm(AddrKey[a]) # last segment in addr
            } else if (isComplex(AddrType[addrs[i-1]]) && AddrCount[addrs[i-1]]==AddrCount[a]) # close empty [] {} list element
                asm("end")
        }
        asm(AddrType[a])
        if (isValueHolder(AddrType[a]))
            asm(AddrValue[a])
        if (i==l-1) { # last
            for (j=0; j<AddrCount[a] - (isComplex(AddrType[a])?0:1); j++)
                asm("end")
        }
    }
}
function asm(inst) { Asm[AsmLen++]=inst; return 1 }
function arrPush(arr, e) { arr[arr[-7]++] = e }
function arrLen(arr) { return 0 + arr[-7] }
function die(msg) { print msg; exit 1 }
function dbgA(name, arr,    i) {
    if (!Trace) return
    print "--- " name " ---";
    for (i=0; i<arrLen(arr); i++) print i " : " arr[i]
}
function dbg(name, arr,    i, j, k, maxlen, keys) {
    if (!Trace) return
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
