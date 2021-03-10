## JSON assembler
   
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
        
### JSON asm
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