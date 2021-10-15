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
  print "--- " name " ---"
  for (i=0; i in arr; i++) printf "%2s : %s\n", i, arr[i]
}

BEGIN {

  if (1) {
    _testDigit("a",0)
    _testDigit("A",0)
    _testDigit("0",1)
    _testDigit("7",1)


    check("aaa", "=", "aaa")
    check("bbb", ">", "aaa")
    check("aaa", "<", "aaaa")
    check("aaaa", ">", "aaa")

    check("aaa1", "=", "aaa01")
    check("1", "=", "01")
    check("01", "=", "1")

    check("aaa2", ">", "aaa1")
    check("aaa2", ">", "aaa01")
    check("aaa2", "<", "aaa10")
    check("aaa20.txt", ">", "aaa10.txt")
    check("aaa20.txt", "<", "aaa100.txt")
    check("2", "<", "10")
    check("10", ">", "2")

    check("aaa1.20", ">", "aaa01.5")
    check("aaa1.20", "<", "aaa01.50")
    check("aaa1.01.1", "=", "aaa01.001.0001")
    check("aaa1.01.2", ">", "aaa01.001.0001")

    check("1_goals.tush", "<", "20_list_goals.tush")
    check("1_goals.tush", "<", "19_optimize_goals.tush")
    check("1_goals.tush", ">", "0_basic.tush")

    check("tests/1_goals.tush", "<", "tests/19_optimize_goals.tush")
    check("tests/19_goals.tush", ">", "tests/1_optimize_goals.tush")
    check("tests/200_update.tush", ">", "tests/9_update.tush")
    check("tests/9_update.tush", "<", "tests/200_update.tush")

    check("01ca",">","1ba")
  }

  if (1){
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

  if (1) {
    arrPush(files1, "tests/0_basic.tush")
    arrPush(files1, "tests/10_define.tush")
    arrPush(files1, "tests/11_goal_glob.tush")
    arrPush(files1, "tests/12_errors.tush")
    arrPush(files1, "tests/13_doc.tush")
    arrPush(files1, "tests/14_private.tush")
    arrPush(files1, "tests/15_lib.tush")
    arrPush(files1, "tests/16_prelude_fail.tush")
    arrPush(files1, "tests/17_empty_prelude.tush")
    arrPush(files1, "tests/18_vars_priority.tush")
    arrPush(files1, "tests/19_optimize_goals.tush")
    arrPush(files1, "tests/1_goals.tush")
    arrPush(files1, "tests/200_update.tush")
    arrPush(files1, "tests/20_list_goals.tush")
    arrPush(files1, "tests/21_parsing.tush")
    arrPush(files1, "tests/22_nat_order.tush")
    arrPush(files1, "tests/2_mydir.tush")
    arrPush(files1, "tests/3_loop.tush")
    arrPush(files1, "tests/4_trace.tush")
    arrPush(files1, "tests/5_shell.tush")
    arrPush(files1, "tests/6_reached_if.tush")
    arrPush(files1, "tests/7_options.tush")
    arrPush(files1, "tests/8_timing.tush")
    arrPush(files1, "tests/9_prelude.tush")

    dbgA("before", files1)
    quicksort(files1, 0, arrLen(files1)-1)
    dbgA("after", files1)
  }
}