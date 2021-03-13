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

```

```