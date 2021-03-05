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
    key
    total
    number
    57
    
    key
    page
    list
        object
            key
            firstName
            string
            John

            key
            lastName
            string
            Doe

            key
            age
            number
            25

            key
            active
            true

            key
            hobby
            string
            football
        end
        
        object
            key
            firstName
            string
            Jane

            key
            lastName
            string
            Smith

            key
            age
            number
            24

            key
            active
            false

            key
            hobby
            null
        end
    end
end
```