BEGIN {
    json_init()
    json_object_start()
    json_key("name")
    json_string("John \"Dirty\" Smith")
    json_key("age")
    json_number(27)
    json_key("hobbies")
    json_list_start()
    json_string("football")
    json_string("chess")
    json_string("cinema")
    json_end()
    json_key("married")
    json_false()
    json_end()
    json_print()
}

function json_init() {
    split("",Asm)
    AsmLen = 0
}
function json_object_start() { json_asm("object") }
function json_list_start()   { json_asm("list") }
function json_end()          { json_asm("end") }
function json_key(k)         { json_asm("key")   ; json_asm(quote_js(k)) }
function json_string(s)      { json_asm("string"); json_asm(quote_js(s)) }
function json_number(n)      { json_asm("number"); json_asm(n) }
function json_true()         { json_asm("true") }
function json_false()        { json_asm("false") }
function json_null()         { json_asm("null") }
function json_print(  i)     { for (i=0;i<AsmLen;i++) print Asm[i] }
function json_asm(instr)     { Asm[AsmLen++] = instr }
function quote_js(s) { gsub("\n", "\\n", s); gsub("\"", "\\\"", s); return "\"" s "\""} # TODO this is naive

