## JSON assembler

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

```
object
    total
    number
    57
    page
    list
        object
            firstName
            string
            John
            lastName
            string
            Doe
            age
            number
            25
            active
            true
            hobby
            string
            football
        end
        
        object
            firstName
            string
            Jane
            lastName
            string
            Smith
            age
            number
            24
            active
            false
            hobby
            null
        end
    end
end
```