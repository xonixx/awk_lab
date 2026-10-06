

# Internal storage uses integer handles and a fixed ':' separator.
# A dense key list and reverse positions keep deletion constant-time.

# creates new map, returns handle h
function hnew(    h) {
    h = ++_h_next
    _h_count[h] = 0
    return h
}

# stores the value v for the key k
function hput(h, k, v,    id, position) {
    id = h ":" k
    if (!(id in _h_data)) {
        position = ++_h_count[h]
        _h_key_at[h ":" position] = k
        _h_pos[id] = position
    }
    _h_data[id] = v
}

# returns the value for the key or ""
function hget(h, k,    id) {
    id = h ":" k
    if (id in _h_data)
        return _h_data[id]
    return ""
}

# removes the given key from the map; enumeration order may change
function hdel(h, k,    id, position, last_position, last_key) {
    id = h ":" k
    if (!(id in _h_data))
        return

    position = _h_pos[id]
    last_position = _h_count[h]
    if (position != last_position) {
        last_key = _h_key_at[h ":" last_position]
        _h_key_at[h ":" position] = last_key
        _h_pos[h ":" last_key] = position
    }

    delete _h_key_at[h ":" last_position]
    delete _h_pos[id]
    delete _h_data[id]
    _h_count[h]--
}

# returns 1 if contains, 0 otherwise
function hhas(h, k) {
    return ((h ":" k) in _h_data) ? 1 : 0
}

# size of map
function hsize(h) {
    return _h_count[h]
}

# replaces keys; now you can iterate `for (k in keys) {...}`
function hkeys(h, keys,    i, k, prefix) {
    for (k in keys)
        delete keys[k]

    prefix = h ":"
    for (i = 1; i <= _h_count[h]; i++) {
        k = _h_key_at[prefix i]
        keys[k] = 1
    }
}
