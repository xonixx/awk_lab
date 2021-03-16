## AWK Lab

- [json_compile.awk](json_compile.awk) - JSON asm → JSON
- [json_parser.awk](json_parser.awk) - JSON → JSON asm
- [json_gen_asm.awk](json_gen_asm.awk) - AWK routines to generate JSON asm
- [json_gron.awk](json_gron.awk) - JSON asm → [Gron](gron_asm.md)
- [gron_parser.awk](gron_parser.awk) - Gron → [Gron asm](gron_asm.md#gron-asm)
- [ungron.awk](ungron.awk) - Gron asm → JSON asm 
   
### JSON
```json
{
  "total": 57,
  "page": [
    {
      "firstName": "John",
      "lastName": "Doe",
      "age": 25,
      "active": true,
      "hobby": "football"
    },
    {
      "firstName": "Jane",
      "lastName": "Smith",
      "age": 24,
      "active": false,
      "hobby": null
    }
  ]
}
```
        
### JSON assembler
```
object
    key
    "total"
    number
    57

    key
    "page"
    array
        object
            key
            "firstName"
            string
            "John"

            key
            "lastName"
            string
            "Doe"

            key
            "age"
            number
            25

            key
            "active"
            true

            key
            "hobby"
            string
            "football"
        end

        object
            key
            "firstName"
            string
            "Jane"

            key
            "lastName"
            string
            "Smith"

            key
            "age"
            number
            24

            key
            "active"
            false

            key
            "hobby"
            null
        end
    end
end
```

### Keywords

```
object
array
string
number
true
false
null
key
end
```

## Links

- https://github.com/Andy753421/rhawk/blob/master/json.awk
- https://github.com/step-/JSON.awk
- https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form
- https://www.crockford.com/mckeeman.html
- https://www.compart.com/en/unicode/category
- https://github.com/tomnomnom/gron

### Test the whole thing

```shell
cat 1.json | awk -f json_parser.awk | awk -f json_gron.awk | grep "org." | awk -f gron_parser.awk | awk -f ungron.awk | awk -f json_compile.awk | jsqry 
```