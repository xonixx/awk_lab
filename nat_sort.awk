# s1 > s2 -> 1
# s1== s2 -> 0
# s1 < s2 -> -1
function natOrder(s1,s2, i1,i2,   c1, c2, n1,n2) {
  #  print s1, s2, i1, i2
  if (_digit(c1 = substr(s1,i1,1)) && _digit(c2 = substr(s2,i2,1))) {
    n1 = +c1; while(_digit(c1 = substr(s1,++i1,1))) { n1 = n1 * 10 + c1 }
    n2 = +c2; while(_digit(c2 = substr(s2,++i2,1))) { n2 = n2 * 10 + c2 }

    return n1 == n2 ? natOrder(s1, s2, i1, i2) : _cmp(n1, n2)
  }

  # consume till equal substrings
  while ((c1 = substr(s1,i1,1)) == (c2 = substr(s2,i2,1)) && c1 != "" && !_digit(c1)) {
    i1++; i2++
  }

  return _digit(c1) && _digit(c2) ? natOrder(s1, s2, i1, i2) : _cmp(c1, c2)
}

function _cmp(v1, v2) { return v1 > v2 ? 1 : v1 < v2 ? -1 : 0 }
function _digit(c) { return c >= "0" && c <= "9" }

function quicksort(data, left, right,   i, last) {
  if (left >= right)
    return
  quicksortSwap(data, left, int((left + right) / 2))
  last = left
  for (i = left + 1; i <= right; i++)
    if (natOrder(data[i], data[left],1,1) < 1)
      quicksortSwap(data, ++last, i)
  quicksortSwap(data, left, last)
  quicksort(data, left, last - 1)
  quicksort(data, last + 1, right)
}
function quicksortSwap(data, i, j,   temp) {
  temp = data[i]
  data[i] = data[j]
  data[j] = temp
}
