# Run with: awk -f h.awk -f h_test.awk

function ht_assert(ok, message) {
    if (!ok) {
        print "FAIL: " message > "/dev/stderr"
        exit 1
    }
    ht_checks++
}

# The reference map uses AWK's built-in composite array keys.
function ht_put(h, k, v) {
    hput(h, k, v)
    ht_model[h, k] = v
}

function ht_del(h, k) {
    hdel(h, k)
    delete ht_model[h, k]
    ht_assert(hhas(h, k) == 0, "deleted key is still present")
    ht_assert(hget(h, k) == "", "deleted key still has a value")
}

function ht_verify(h,    prefix, entry, k, expected_size, actual_size, keys) {
    prefix = h SUBSEP
    keys["__stale__"] = 1
    hkeys(h, keys)

    expected_size = 0
    for (entry in ht_model) {
        if (index(entry, prefix) == 1) {
            k = substr(entry, length(prefix) + 1)
            expected_size++
            ht_assert(hhas(h, k) == 1, "missing membership: " k)
            ht_assert(hget(h, k) == ht_model[entry], "incorrect value: " k)
            ht_assert(k in keys, "missing enumerated key: " k)
        }
    }

    actual_size = 0
    for (k in keys) {
        actual_size++
        ht_assert((h SUBSEP k) in ht_model, "unexpected enumerated key: " k)
    }
    ht_assert(actual_size == expected_size, "incorrect enumeration size")
    ht_assert(hsize(h) == expected_size, "incorrect map size")
}

BEGIN {
    # Multiple handles, including 1 and 10, must remain independent.
    for (ht_i = 1; ht_i <= 12; ht_i++) {
        ht_handles[ht_i] = hnew()
        for (ht_j = 1; ht_j < ht_i; ht_j++)
            ht_assert(ht_handles[ht_i] != ht_handles[ht_j], "reused handle")
        ht_verify(ht_handles[ht_i])
    }
    ht_h = ht_handles[1]

    # Missing reads and repeated deletion must leave an empty map empty.
    ht_assert(hget(ht_h, "absent") == "", "missing key returned a value")
    ht_assert(hhas(ht_h, "absent") == 0, "missing key is present")
    ht_del(ht_h, "absent")
    ht_verify(ht_h)

    # Overwrites do not add entries. Deleting b moves d; deleting d next
    # exercises the reverse index of the moved key.
    ht_put(ht_h, "a", "first")
    ht_put(ht_h, "b", "second")
    ht_put(ht_h, "c", "third")
    ht_put(ht_h, "d", "fourth")
    ht_put(ht_h, "a", "overwrite")
    ht_verify(ht_h)
    ht_del(ht_h, "b")
    ht_verify(ht_h)
    ht_del(ht_h, "d")
    ht_verify(ht_h)
    ht_del(ht_h, "c")
    ht_verify(ht_h)
    ht_del(ht_h, "a")
    ht_verify(ht_h)
    ht_del(ht_h, "a")
    ht_put(ht_h, "a", "reinserted")
    ht_verify(ht_h)

    # Empty keys/values, zero, separators, and numeric-looking strings.
    ht_test_keys[1] = ""
    ht_test_keys[2] = "a:b:c"
    ht_test_keys[3] = SUBSEP "key" SUBSEP
    ht_test_keys[4] = "01"
    ht_test_keys[5] = "1"
    ht_test_keys[6] = "__stale__"
    for (ht_i = 1; ht_i <= 6; ht_i++) {
        ht_put(ht_h, ht_test_keys[ht_i], (ht_i % 2) ? "" : 0)
        ht_put(ht_handles[10], ht_test_keys[ht_i], "other map")
    }
    ht_assert(hhas(ht_h, "") == 1, "empty key with empty value is absent")
    ht_assert(hget(ht_h, "") == "", "empty value changed")
    ht_assert(hget(ht_h, "a:b:c") == 0, "zero value changed")
    ht_put(ht_h, 7, "numeric key")
    ht_assert(hget(ht_h, "7") == "numeric key", "numeric/string key mismatch")
    ht_verify(ht_h)
    ht_verify(ht_handles[10])

    # hkeys replaces its destination, including when reused for another map.
    ht_reused["leftover"] = 1
    hkeys(ht_h, ht_reused)
    ht_assert(!("leftover" in ht_reused), "destination was not cleared")
    hkeys(ht_handles[2], ht_reused)
    ht_reused_size = 0
    for (ht_k in ht_reused)
        ht_reused_size++
    ht_assert(ht_reused_size == 0, "empty map left destination keys behind")

    # Internal indexing must continue to work after SUBSEP changes.
    ht_saved_subsep = SUBSEP
    SUBSEP = "changed"
    ht_assert(hhas(ht_h, ht_test_keys[3]) == 1, "SUBSEP changed membership")
    ht_assert(hget(ht_handles[10], ht_test_keys[3]) == "other map",
              "SUBSEP changed retrieval")
    hkeys(ht_h, ht_reused)
    ht_assert(ht_test_keys[3] in ht_reused, "SUBSEP changed enumeration")
    hput(ht_h, "under-changed-subsep", "new value")
    hdel(ht_h, ht_test_keys[3])
    SUBSEP = ht_saved_subsep
    ht_model[ht_h, "under-changed-subsep"] = "new value"
    delete ht_model[ht_h, ht_test_keys[3]]
    ht_verify(ht_h)
    ht_verify(ht_handles[10])

    # Repeatable within each AWK implementation; rand() differs between them.
    srand(12345)
    for (ht_step = 1; ht_step <= 1000; ht_step++) {
        ht_h = ht_handles[1 + int(rand() * 12)]
        ht_k = ht_test_keys[1 + int(rand() * 6)]
        ht_operation = int(rand() * 3)
        if (ht_operation == 0)
            ht_put(ht_h, ht_k, "value-" ht_step)
        else if (ht_operation == 1)
            ht_del(ht_h, ht_k)
        else {
            ht_assert(hhas(ht_h, ht_k) == ((ht_h SUBSEP ht_k) in ht_model),
                      "random membership mismatch at step " ht_step)
            if ((ht_h SUBSEP ht_k) in ht_model)
                ht_assert(hget(ht_h, ht_k) == ht_model[ht_h, ht_k],
                          "random value mismatch at step " ht_step)
            else
                ht_assert(hget(ht_h, ht_k) == "",
                          "random missing read at step " ht_step)
        }
        ht_verify(ht_h)
    }
    for (ht_i = 1; ht_i <= 12; ht_i++)
        ht_verify(ht_handles[ht_i])

    print "PASS: " ht_checks " checks"
    exit 0
}
