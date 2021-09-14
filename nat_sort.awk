

# s1 > s2 -> 1
# s1== s2 -> 0
# s1 < s2 -> -1
function natOrder(s1,s2, i1,i2,   c1, c2,isD1,isD2, l1, l2) {
  l1 = length(s1)
  l2 = length(s2)

  if (i1 == l1 || i2 == l2)
    return _cmp(l1-i1, l2-i2)

  while ((c1 = substr(s1,i1,1)) == (c2 = substr(s2,i2,1))) {
    i1++; i2++
    if (i1>l1 || i2>l2)
      return _cmp(l1-i1, l2-i2)
  }

  if (!_digit(c1) || !_digit(c2))
    return _cmp(c1, c2)

  n1 = ""; while(_digit(c1 = substr(s1,i1,1))) n1 = n1 c1; gsub(/^0+/,"",n1)
  n2 = ""; while(_digit(c2 = substr(s2,i2,1))) n2 = n2 c2; gsub(/^0+/,"",n2)

  if (0 == n1 - n2) return natOrder(s1, s2, i1, i2)
  return _cmp(n1, n2)
}

function _cmp(v1, v2) { return v1 > v2 ? 1 : v1 == v2 ? 0 : -1 }
function _digit(c) { return d >= "0" && d <= "9" }

function _resToOp(r) { return r == 1 ? ">" : r == 0 ? "=" : "<" }
function check(s1, expectedOp, s2,   op) {
  op = _resToOp(natOrder(s1, s2, 1, 1))
  print (expectedOp == op ? "OK     " : "FAIL(" op ")") ": " s1 " " expectedOp " " s2
}

BEGIN {
#  check("aaa", "=", "aaa")
#  check("bbb", ">", "aaa")
#  check("aaa", "<", "aaaa")

  check("aaa1", "=", "aaa01")
}