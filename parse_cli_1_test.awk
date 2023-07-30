#include parse_cli_1_lib.awk
#include parse_cli_N_test.awk

BEGIN {
  runTestFile("parse_cli_1.txt")
}

function parseAbstract(line, res) {
  return parseCli_1(line, res)
}