## Gron

See https://github.com/tomnomnom/gron

### Gron
```
json={}
json.a={}
json.a.b="c"
json.a[" d "]="e"
json.a["f\nf"]=[]
json.a["f\nf"][0]="a"
json.a["f\nf"][1]="BBB"
json.a["f\nf"][2]=true
json.a["f\nf"][3]=123
```
         
### Gron asm
```
record  #
field   # a || ["a"]
index   # [3]
value   # = value
object  # {}
array   # []
string  # "value"
number  # 123
true    #
false   #
null    #
end     #
```
            
### Grammar
```
Input         ::= '--'* Statement (Statement | '--')*
Statement     ::= Path Space* "=" Space* Value ";" "\n"
Path          ::= (BareWord) ("." BareWord | ("[" Key "]"))*
Value         ::= String | Number | "true" | "false" | "null" | "[]" | "{}"
BareWord      ::= (UnicodeLu | UnicodeLl | UnicodeLm | UnicodeLo | UnicodeNl | '$' | '_') (UnicodeLu | UnicodeLl | UnicodeLm | UnicodeLo | UnicodeNl | UnicodeMn | UnicodeMc | UnicodeNd | UnicodePc | '$' | '_')*
Key           ::= [0-9]+ | String
String        ::= '"' (UnescapedRune | ("\" (["\/bfnrt] | ('u' Hex))))* '"'
UnescapedRune ::= [^#x0-#x1f"\]
```

```
Statement
    Path "=" Value
Path
    BareWord Segments
Segments
    ""
    Segment Segments
Segment
    "." BareWord 
    "[" Key "]"
Value
    String
    Number
    "true"
    "false"
    "null"
    "[]"
    "{}"
BareWord
    [a-zA-Z$_][a-zA-Z0-9$_]* # TODO
Key
    [0-9]+
    String
```