## AWK Lab

[![Run tests](https://github.com/xonixx/awk_lab/actions/workflows/run-tests.yml/badge.svg)](https://github.com/xonixx/awk_lab/actions/workflows/run-tests.yml)

- [json_compile.awk](json_compile.awk) - JSON asm → JSON
    - `Indent=N` - JSON asm → JSON pretty-printed
- [json_parser.awk](json_parser.awk) - JSON → JSON asm
- [json_gen_asm.awk](json_gen_asm.awk) - AWK routines to generate JSON asm
- [json_gron.awk](json_gron.awk) - JSON asm → [Gron](gron_asm.md)
- [gron_parser.awk](gron_parser.awk) - Gron → [Gron asm](gron_asm.md#gron-asm)
- [ungron.awk](ungron.awk) - Gron asm → JSON asm 
- [json_structure.awk](json_structure.awk) - JSON asm → [JSON structure](https://news.ycombinator.com/item?id=25009263)
- [nat_sort.awk](nat_sort.awk) - Natural sorting
- CLI
  - [parse_cli_lib.awk](parse_cli_lib.awk) - basic utility to parse CLI `"  aaa 'bbb cc'  'd\'ee' "` -> `["aaa", "bbb cc", "d'ee"]`
    - Not shell-compatible, this is why we came up with `parse_cli_lib_1.awk` 
  - [parse_cli_test.awk](parse_cli_test.awk) - tests for above lib
  - [parse_cli_lib_1.awk](parse_cli_lib_1.awk) - basic utility to parse CLI `"  aaa 'bbb cc'  $'d\'ee' "` -> `["aaa", "bbb cc", "d'ee"]`
  - [parse_cli_test_1.awk](parse_cli_test_1.awk) - tests for above lib
  - [reparse_cli.awk](reparse_cli.awk) - reparses `$0` to make Awk parsing closer to CLI
    - `awk -f parse_cli_lib.awk -f reparse_cli.awk`
   
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
        end_object

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
        end_object
    end_array
end_object
```

### Keywords

```
object       # {
end_object   # }
array        # [
end_array    # ]
key          # "key":
string       # "value"
number       # 123
true         # 
false        # 
null         # 
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
cat test_data/1.json \
  | awk -f json_parser.awk \
  | awk -f json_gron.awk \
  | grep "org." \
  | awk -f gron_parser.awk \
  | awk -f nat_sort.awk -f ungron.awk \
  | Indent=2 awk -f json_compile.awk 
```