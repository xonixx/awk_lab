#include parse_cli_0_lib.awk
#include parse_cli_N_test.awk

BEGIN {
  runTestFile("parse_cli_0.txt")
}

function parseAbstract(line, res) {
  return parseCli(line, res)
}