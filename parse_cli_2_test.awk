#include parse_cli_2_lib.awk
#include parse_cli_N_test.awk

BEGIN {
  #  Trace=1
  Vars["AAA"] = "aaa"
  Vars["A77"] = "a77"
  Vars["BBB"] = "bbb"
  Vars["CCC_CCC"] = "ccc_ccc"
  Vars["__DDD"] = "__ddd"
  Vars["_333"] = "_ttt"
  runTestFile("parse_cli_2.txt")
}

function parseAbstract(line, res) {
  return parseCli_2(line, Vars, res)
}