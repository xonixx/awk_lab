#include parse_cli_2_lib.awk
#include parse_cli_N_test.awk

BEGIN {
  runTestFile("parse_cli_2.txt")
}

function parseAbstract(line, res) {
  return parseCli_2(line, Vars, res)
}