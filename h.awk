

# Internal storage uses integer handles and a fixed ':' separator.
# A dense key list and reverse positions keep deletion constant-time.

# creates new map, returns handle h
function hnew(    h) {
    h = ++H_NEXT
    H_COUNT[h] = 0
    return h
}

# stores the value v for the key k
function hput(h, k, v,    id, position) {
    id = h ":" k
    if (!(id in H_DATA)) {
        position = ++H_COUNT[h]
        H_KEY_AT[h ":" position] = k
        H_POS[id] = position
    }
    H_DATA[id] = v
}

# returns the value for the key or ""
function hget(h, k,    id) {
    id = h ":" k
    if (id in H_DATA)
        return H_DATA[id]
    return ""
}

# removes the given key from the map; enumeration order may change
function hdel(h, k,    id, position, last_position, last_key) {
    id = h ":" k
    if (!(id in H_DATA))
        return

    position = H_POS[id]
    last_position = H_COUNT[h]
    if (position != last_position) {
        last_key = H_KEY_AT[h ":" last_position]
        H_KEY_AT[h ":" position] = last_key
        H_POS[h ":" last_key] = position
    }

    delete H_KEY_AT[h ":" last_position]
    delete H_POS[id]
    delete H_DATA[id]
    H_COUNT[h]--
}

# returns 1 if contains, 0 otherwise
function hhas(h, k) {
    return (h ":" k) in H_DATA
}

# size of map
function hsize(h) {
    return H_COUNT[h]
}

# replaces keys; now you can iterate `for (k in keys) {...}`
function hkeys(h, keys,    i, prefix) {
    delete keys

    prefix = h ":"
    for (i = 1; i <= H_COUNT[h]; i++) {
        keys[H_KEY_AT[prefix i]]
    }
}
