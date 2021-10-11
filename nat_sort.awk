# s1 > s2 -> 1
# s1== s2 -> 0
# s1 < s2 -> -1
function natOrder(s1,s2, i1,i2,   c1, c2, n1,n2, l1, l2) {
  l1 = length(s1); l2 = length(s2)

  if (i1 == l1+1 || i2 == l2+1)
    return _cmp(l1-i1, l2-i2)

  while ((c1 = substr(s1,i1,1)) == (c2 = substr(s2,i2,1))) {
    i1++; i2++
    if (i1>l1 || i2>l2)
      return _cmp(l1-i1, l2-i2)
  }

  if (!_digit(c1) || !_digit(c2))
    return _cmp(c1, c2)

  n1 = 0; while(_digit(c1 = substr(s1,i1++,1))) { n1 = n1 * 10 + c1 }
  n2 = 0; while(_digit(c2 = substr(s2,i2++,1))) { n2 = n2 * 10 + c2 }

  return n1 == n2 ? natOrder(s1, s2, i1, i2) : _cmp(n1, n2)
}

function _cmp(v1, v2) { return v1 > v2 ? 1 : v1 < v2 ? -1 : 0 }
function _digit(c) { return c >= "0" && c <= "9" }

function quicksort(data, left, right,   i, last) {
  if (left >= right)
    return
  quicksortSwap(data, left, int((left + right) / 2))
  last = left
  for (i = left + 1; i <= right; i++)
    if (natOrder(data[i], data[left]) < 1)
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

#-----------------------------
function _resToOp(r) { return r == 1 ? ">" : r == 0 ? "=" : "<" }
function check(s1, expectedOp, s2,   op) {
  op = _resToOp(natOrder(s1, s2, 1, 1))
  print (expectedOp == op ? "OK     " : "FAIL(" op ")") ": " s1 " " expectedOp " " s2
}

function _testDigit(c, expectedRes,   res) {
  res = _digit(c)
  print (expectedRes == res ? "OK  " : "FAIL") ": " c
}

function arrPush(arr, e) { arr[arr[-7]++] = e }
function arrLen(arr) { return +arr[-7] }

function dbgA(name, arr,    i) {
  print "--- " name " ---";
  for (i=0; i in arr; i++) printf "%2s : %s\n", i, arr[i]
}

BEGIN {
  if (0){

    #  _testDigit("a",0)
    #  _testDigit("A",0)
    #  _testDigit("0",1)
    #  _testDigit("7",1)

    check("aaa", "=", "aaa")
    check("bbb", ">", "aaa")
    check("aaa", "<", "aaaa")
    check("aaaa", ">", "aaa")

    check("aaa1", "=", "aaa01")
    #  check("1", "=", "01")

    check("aaa2", ">", "aaa1")
    check("aaa2", ">", "aaa01")
    check("aaa2", "<", "aaa10")
    check("aaa20.txt", ">", "aaa10.txt")
    check("aaa20.txt", "<", "aaa100.txt")
    #  check("2", "<", "10")

    check("aaa1.20", ">", "aaa01.5")
    check("aaa1.20", "<", "aaa01.50")
    check("aaa1.01.1", "=", "aaa01.001.0001")
    check("aaa1.01.2", ">", "aaa01.001.0001")

    arrPush(files, "file10.txt")
    arrPush(files, "file1.txt")
    arrPush(files, "file100.txt")
    arrPush(files, "file20.txt")
    arrPush(files, "file20.1.txt")
    arrPush(files, "file2.txt")
    arrPush(files, "file003.txt")

    dbgA("before", files)
    quicksort(files, 0, arrLen(files)-1)
    dbgA("after", files)
  }
  arrPush(files1, "0_basic.tush")
  arrPush(files1, "10_define.tush")
  arrPush(files1, "11_goal_glob.tush")
  arrPush(files1, "12_errors.tush")
  arrPush(files1, "13_doc.tush")
  arrPush(files1, "14_private.tush")
  arrPush(files1, "15_lib.tush")
  arrPush(files1, "16_prelude_fail.tush")
  arrPush(files1, "17_empty_prelude.tush")
  arrPush(files1, "18_vars_priority.tush")
  arrPush(files1, "19_optimize_goals.tush")
  arrPush(files1, "1_goals.tush")
  arrPush(files1, "20_list_goals.tush")
  arrPush(files1, "21_parsing.tush")
  arrPush(files1, "2_mydir.tush")
  arrPush(files1, "3_loop.tush")
  arrPush(files1, "4_trace.tush")
  arrPush(files1, "5_shell.tush")
  arrPush(files1, "6_reached_if.tush")
  arrPush(files1, "7_options.tush")
  arrPush(files1, "8_timing.tush")
  arrPush(files1, "9_prelude.tush")

  dbgA("before", files1)
  quicksort(files1, 0, arrLen(files1)-1)
  dbgA("after", files1)
}